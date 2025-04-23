import SwiftUI
import Combine

/// Model zarządzający logami VPN.
class VPNLogsViewModel: ObservableObject {
    @Published var logs: [String] = []

    private var logUpdateTimer: AnyCancellable?

    init(initialLogs: [String] = []) {
        self.logs = initialLogs
        startUpdatingLogs()
    }

    /// Symuluje dodawanie nowych logów co sekundę.
    private func startUpdatingLogs() {
        logUpdateTimer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                let newLog = "Log \(Date())"
                DispatchQueue.main.async {
                    self.logs.append(newLog)
                    if self.logs.count > 500 {
                        self.logs.removeFirst(self.logs.count - 500)
                    }
                }
            }
    }

    deinit {
        logUpdateTimer?.cancel()
    }
}

/// Widok wyświetlający logi VPN.
struct VPNLogsView: View {
    @StateObject private var viewModel: VPNLogsViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showCopiedMessage = false

    init(logs: [String] = []) {
        _viewModel = StateObject(wrappedValue: VPNLogsViewModel(initialLogs: logs))
    }

    var body: some View {
        VStack(alignment: .leading) {
            // Nagłówek
            HStack {
                Text("Logi połączenia")
                    .font(.headline)
                Spacer()
                Button("Zamknij") {
                    dismiss()
                }
            }

            Divider()

            // Obszar logów
            ScrollView {
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(viewModel.logs, id: \.self) { line in
                        Text(line)
                            .font(.system(size: 12, design: .monospaced))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.bottom)
            }

            // Akcje w stopce
            HStack {
                Spacer()
                Button("Skopiuj do schowka") {
                    copyLogsToClipboard()
                }
                if showCopiedMessage {
                    Text("✅ Skopiowano")
                        .font(.caption)
                        .foregroundColor(.green)
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 0.3), value: showCopiedMessage)
                }
            }
            .padding(.top, 8)
        }
        .padding()
        .frame(width: 500, height: 320)
    }

    /// Kopiuje ostatnie logi do schowka.
    private func copyLogsToClipboard() {
        let lastLogs = viewModel.logs.suffix(200).joined(separator: "\n")
        
        #if os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(lastLogs, forType: .string)
        #else
        UIPasteboard.general.string = lastLogs
        #endif

        showCopiedMessage = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            showCopiedMessage = false
        }
    }
}
