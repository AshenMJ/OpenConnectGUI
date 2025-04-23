import SwiftUI

/// A view that displays the list of saved VPN configurations,
/// and allows adding or removing configurations.
struct VPNListView: View {
    @ObservedObject var store: VPNConfigurationStore
    @State private var showingAddSheet = false
    @State private var selectedConfig: VPNConfiguration? = nil
    @State private var showingLogsFor: VPNConfiguration? = nil
    @State private var editingConfig: VPNConfiguration? = nil
    @State private var expandedConfigID: UUID?
    @State private var connections: [UUID: VPNConnectionState] = [:]

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Image("HeaderIcon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 32, height: 32)
                    .clipShape(RoundedRectangle(cornerRadius: 6))

                Text("VPN Configurations")
                    .font(.title2)
                    .fontWeight(.semibold)

                Spacer()

                Button(action: { showingAddSheet = true }) {
                    Label("Add VPN", systemImage: "plus")
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal)
            .padding(.vertical, 10)

            Divider()

            List {
                ForEach(store.configurations) { config in
                    let connection = connections[config.id] ?? VPNConnectionState(config: config)

                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.1))

                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text(config.name)
                                    .font(.title3)
                                    .fontWeight(.semibold)

                                Spacer()

                                VPNStatusIndicator(isConnected: connection.isConnected)
                            }

                            Text(config.serverAddress)
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            HStack(spacing: 12) {
                                Label(config.username, systemImage: "person.fill")
                                    .font(.caption)
                                    .foregroundColor(.gray)

                                if let proto = config.protocolType {
                                    Label(proto, systemImage: "network")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }

                            HStack(spacing: 10) {
                                Button {
                                    selectedConfig = config
                                } label: {
                                    Label("Połącz", systemImage: "link")
                                }
                                .buttonStyle(.bordered)

                                Button {
                                    connection.disconnect()
                                } label: {
                                    Label("Rozłącz", systemImage: "xmark.circle")
                                }
                                .buttonStyle(.bordered)

                                Button {
                                    editingConfig = config
                                } label: {
                                    Image(systemName: "pencil")
                                }
                                .buttonStyle(.borderless)
                                .help("Edytuj konfigurację")

                                Button {
                                    showingLogsFor = config
                                } label: {
                                    Image(systemName: "info.circle")
                                }
                                .buttonStyle(.borderless)
                                .help("Pokaż logi")

                                Button {
                                    store.remove(config)
                                } label: {
                                    Image(systemName: "trash")
                                }
                                .buttonStyle(.borderless)
                                .help("Usuń konfigurację")
                            }
                        }
                        .padding()
                    }
                    .padding(.vertical, 4)
                    .onAppear {
                        if connections[config.id] == nil {
                            connections[config.id] = connection
                        }
                    }
                }
                .onDelete(perform: delete)
            }
            .listStyle(.plain)
        }
        .sheet(isPresented: $showingAddSheet) {
            AddVPNView(store: store)
        }
        .sheet(item: $selectedConfig) { config in
            let connection = connections[config.id] ?? VPNConnectionState(config: config)
            let savedSudoPassword = KeychainService.loadSudoPassword() ?? ""

            if config.rememberCredentials,
               let savedPassword = KeychainService.loadPassword(for: config) {
                AutoConnectView(config: config, password: savedPassword) {
                    connection.connect(with: savedPassword, sudoPassword: savedSudoPassword)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        selectedConfig = nil
                    }
                }
            } else {
                ConnectVPNView(config: config) { vpnPassword, sudoPassword, rememberVpn, rememberSudo in
                    if rememberVpn {
                        KeychainService.savePassword(vpnPassword, for: config)
                    }
                    if rememberSudo {
                        KeychainService.saveSudoPassword(sudoPassword)
                    }
                    connection.connect(with: vpnPassword, sudoPassword: sudoPassword)

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        selectedConfig = nil
                    }
                }
            }
        }
        .sheet(item: $showingLogsFor) { config in
            if let logs = connections[config.id]?.logs {
                VPNLogsView(logs: logs)
            } else {
                VPNLogsView(logs: ["Brak logów dla tej konfiguracji."])
            }
        }
        .sheet(item: $editingConfig) { config in
            EditVPNView(store: store, config: config)
        }
        .frame(minWidth: 600, minHeight: 400)
    }

    private func delete(at offsets: IndexSet) {
        offsets.map { store.configurations[$0] }.forEach(store.remove)
    }
}
