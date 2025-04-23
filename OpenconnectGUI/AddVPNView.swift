//
//  AddVPNView.swift
//  OpenconnectGUI
//
//  Created by Mikołaj Jucha on 23/04/2025.
//
import SwiftUI

/// Represents a user-friendly display name and its associated protocol value
struct VPNProtocolOption: Identifiable {
    let id = UUID()
    let label: String
    let value: String
}

/// A sheet that allows users to enter and save a new VPN configuration.
struct AddVPNView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var store: VPNConfigurationStore

    @State private var name = ""
    @State private var serverAddress = ""
    @State private var username = ""
    @State private var protocolType: String = "anyconnect"
    @State private var rememberCredentials = false
    @State private var sudoPassword = ""
    
    private let supportedProtocols: [VPNProtocolOption] = [
        VPNProtocolOption(label: "Cisco AnyConnect", value: "anyconnect"),
        VPNProtocolOption(label: "Juniper Network Connect", value: "nc"),
        VPNProtocolOption(label: "Pulse Secure", value: "pulse"),
        VPNProtocolOption(label: "GlobalProtect", value: "gp"),
        VPNProtocolOption(label: "F5 BIG-IP", value: "f5"),
        VPNProtocolOption(label: "Fortinet FortiGate", value: "fortinet"),
        VPNProtocolOption(label: "Array Networks", value: "array")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Skonfiguruj połączenie")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.bottom, 8)

            Form {
                TextField("Nazwa połączenia", text: $name)
                TextField("Adres serwera", text: $serverAddress)
                TextField("Nazwa użytkownika", text: $username)
                
                Picker("Protokół", selection: $protocolType) {
                    ForEach(supportedProtocols) { option in
                        Text(option.label).tag(option.value)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                SecureField("Hasło administratora", text: $sudoPassword)
                Toggle("Zapamiętaj poświadczenia", isOn: $rememberCredentials)
            }

            HStack {
                Spacer()
                Button("Anuluj") {
                    presentationMode.wrappedValue.dismiss()
                }
                Button("Zapisz") {
                    let newConfig = VPNConfiguration(
                        name: name,
                        serverAddress: serverAddress,
                        username: username,
                        protocolType: protocolType,
                        rememberCredentials: rememberCredentials
                    )
                    store.add(newConfig)
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(name.isEmpty || serverAddress.isEmpty || username.isEmpty)
            }
            .padding(.top)
        }
        .padding()
        .frame(width: 400, height: 360)
    }
}
