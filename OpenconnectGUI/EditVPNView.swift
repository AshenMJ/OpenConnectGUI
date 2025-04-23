//
//  EditVPNView.swift
//  OpenconnectGUI
//
//  Created by Mikołaj Jucha on 23/04/2025.
//
import SwiftUI

/// A view for editing an existing VPN configuration.
struct EditVPNView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store: VPNConfigurationStore
    @State var config: VPNConfiguration

    var body: some View {
        VStack(spacing: 16) {
            Text("Edytuj konfigurację VPN")
                .font(.title2)
                .padding(.top)

            TextField("Nazwa połączenia", text: $config.name)
            TextField("Adres serwera", text: $config.serverAddress)
            TextField("Nazwa użytkownika", text: $config.username)

            Picker("Protokół", selection: $config.protocolType) {
                Text("AnyConnect").tag("anyconnect" as String?)
                Text("GlobalProtect").tag("gp" as String?)
                Text("Pulse").tag("pulse" as String?)
                Text("F5").tag("f5" as String?)
            }

            Toggle("Zapamiętaj poświadczenia", isOn: $config.rememberCredentials)

            HStack {
                Button("Anuluj") {
                    dismiss()
                }

                Spacer()

                Button("Zapisz zmiany") {
                    store.update(config)
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding(.top)
        }
        .padding()
        .frame(width: 400)
    }
}
