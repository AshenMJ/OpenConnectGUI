import SwiftUI

struct ConnectionRow: View {
  let config: VPNConfiguration
  @ObservedObject var connection: VPNConnectionState

  // akcje sterujące
  var onConnect: () -> Void
  var onDisconnect: () -> Void
  var onEdit: () -> Void
  var onShowLogs: () -> Void
  var onDelete: () -> Void

  var body: some View {
    ZStack {
      RoundedRectangle(cornerRadius: 12)
        .fill(Color.gray.opacity(0.1))

      VStack(alignment: .leading, spacing: 10) {
        HStack {
          Text(config.name)
            .font(.title3).fontWeight(.semibold)
          Spacer()
          // zielona gdy isConnected == true
          Circle()
            .fill(connection.isConnected ? Color.green : Color.gray)
            .frame(width: 12, height: 12)
        }

        Text(config.serverAddress)
          .font(.subheadline).foregroundColor(.secondary)

        HStack(spacing: 12) {
          Label(config.username, systemImage: "person.fill")
            .font(.caption).foregroundColor(.gray)
          if let proto = config.protocolType {
            Label(proto, systemImage: "network")
              .font(.caption).foregroundColor(.gray)
          }
        }

        HStack(spacing: 10) {
          Button(action: onConnect) {
            Label("Connect", systemImage: "link")
          }.buttonStyle(.bordered)

          Button(action: onDisconnect) {
            Label("Disconnect", systemImage: "xmark.circle")
          }.buttonStyle(.bordered)

          Button(action: onEdit) {
            Image(systemName: "pencil")
          }.buttonStyle(.borderless).help("Edit")

          Button(action: onShowLogs) {
            Image(systemName: "info.circle")
          }.buttonStyle(.borderless).help("Logs")

          Button(action: onDelete) {
            Image(systemName: "trash")
          }.buttonStyle(.borderless).help("Delete")
        }
      }
      .padding()
    }
    .padding(.vertical, 4)
  }
}
