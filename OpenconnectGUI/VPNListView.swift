import SwiftUI

/// A view that displays the list of saved VPN configurations,
/// and allows adding or removing configurations.
struct VPNListView: View {
    @ObservedObject var store: VPNConfigurationStore
       @StateObject private var connectionStore = ConnectionStore()
       @State private var showingAddSheet = false
       @State private var selectedConfig: VPNConfiguration?
       @State private var showingLogsFor: VPNConfiguration?
       @State private var editingConfig: VPNConfiguration?
    
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
                               // Pobierz instancję z ConnectionStore
                               let connection = connectionStore.connection(for: config)

                               ConnectionRow(
                                   config: config,
                                   connection: connection,
                                   onConnect: { selectedConfig = config },
                                   onDisconnect: { connection.disconnect() },
                                   onEdit: { editingConfig = config },
                                   onShowLogs: { showingLogsFor = config },
                                   onDelete: {
                                       store.remove(config)
                                       connectionStore.remove(config)
                                   }
                               )
                           }
                           .onDelete { offsets in
                               let toDelete = offsets.map { store.configurations[$0] }
                               toDelete.forEach { cfg in
                                   store.remove(cfg)
                                   connectionStore.remove(cfg)
                               }
                           }
                       }
                       .listStyle(.plain)
        }
        .sheet(isPresented: $showingAddSheet) {
            AddVPNView(store: store)
        }
         .sheet(item: $selectedConfig) { config in
           let connection = connectionStore.connection(for: config)
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
                    let logs = connectionStore.connection(for: config).logs
                    VPNLogsView(logs: logs)
                }
        .sheet(item: $editingConfig) { config in
            EditVPNView(store: store, config: config)
        }
        .frame(minWidth: 600, minHeight: 400)
    }

   

      private func delete(at offsets: IndexSet) {
        let toDelete = offsets.map { store.configurations[$0] }
        toDelete.forEach {
          store.remove($0)
        }
      }
}
