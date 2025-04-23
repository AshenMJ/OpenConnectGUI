import SwiftUI

struct ConnectVPNView: View {
    let config: VPNConfiguration
    let onConnect: (_ vpnPassword: String, _ sudoPassword: String, _ rememberVpn: Bool, _ rememberSudo: Bool) -> Void

    @State private var vpnPassword: String = ""
    @State private var sudoPassword: String = ""
    @State private var rememberVPN = false
    @State private var rememberSudo = false
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Połącz z \(config.name)")
                .font(.title2)
                .bold()

            SecureField("Hasło VPN", text: $vpnPassword)
                .textFieldStyle(.roundedBorder)

            Toggle("Zapamiętaj hasło VPN", isOn: $rememberVPN)

            Divider()

            SecureField("Hasło administratora (sudo)", text: $sudoPassword)
                .textFieldStyle(.roundedBorder)

            Toggle("Zapamiętaj hasło sudo", isOn: $rememberSudo)

            HStack {
                Spacer()
                Button("Anuluj") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)

                Button("Połącz") {
                    onConnect(vpnPassword, sudoPassword, rememberVPN, rememberSudo)
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(vpnPassword.isEmpty || sudoPassword.isEmpty)
            }
        }
        .padding()
        .frame(width: 400)
    }
}
