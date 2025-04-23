import SwiftUI

struct VPNStatusIndicator: View {
    let isConnected: Bool

    var body: some View {
        Circle()
            .fill(isConnected ? Color.green : Color.gray)
            .frame(width: 12, height: 12)
            .overlay(
                Circle()
                  .stroke(Color.secondary.opacity(0.5), lineWidth: 1)
            )
            .help(isConnected ? "Connected" : "Disconnected")
    }
}
