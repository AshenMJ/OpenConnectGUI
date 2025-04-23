import Foundation
import Combine

/// Represents the state of a single VPN connection.
class VPNConnectionState: ObservableObject, Identifiable {
    let id = UUID()
    let config: VPNConfiguration

    @Published var isConnected: Bool = false
    @Published var logs: [String] = []

    private var process: Process?
    private var outputPipe = Pipe()
    private var inputPipe = Pipe()

    init(config: VPNConfiguration) {
        self.config = config
    }

    func connect(with vpnPassword: String, sudoPassword: String)
    {
        guard !isConnected else {
            log("[\(Date())] VPN już połączony.")
            return
        }

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            let process = Process()
            let inputPipe = Pipe()
            let outputPipe = Pipe()

            process.executableURL = URL(fileURLWithPath: "/usr/bin/sudo")
            process.arguments = [
                "/opt/homebrew/bin/openconnect",
                "--protocol", self.config.protocolType ?? "anyconnect",
                "--user", self.config.username,
                "--passwd-on-stdin",
                self.config.serverAddress
            ]

            process.standardInput = inputPipe
            process.standardOutput = outputPipe
            process.standardError = outputPipe

            self.process = process
            self.inputPipe = inputPipe
            self.outputPipe = outputPipe

            do {
                try process.run()

                DispatchQueue.main.async {
                    self.isConnected = true
                    self.log("[\(Date())] Połączenie rozpoczęte z \(self.config.serverAddress)")
                }

              
                    if let vpnData = "\(vpnPassword)\n".data(using: .utf8) {
                        inputPipe.fileHandleForWriting.write(vpnData)
                    }
                

                // Obsługa logów
                outputPipe.fileHandleForReading.readabilityHandler = { [weak self] handle in
                    guard let self = self else { return }
                    let output = String(data: handle.availableData, encoding: .utf8) ?? ""
                    let lines = output.split(separator: "\n").map(String.init)

                    DispatchQueue.main.async {
                        self.logs.append(contentsOf: lines.suffix(10))
                        self.trimLogsIfNeeded()
                    }
                }

                // Obsługa zakończenia procesu
                process.terminationHandler = { [weak self] _ in
                    guard let self = self else { return }
                    DispatchQueue.main.async {
                        self.isConnected = false
                        self.log("[\(Date())] Połączenie zakończone.")
                        self.cleanup()
                    }
                }

            } catch {
                DispatchQueue.main.async {
                    self.log("[\(Date())] Błąd uruchamiania: \(error.localizedDescription)")
                }
                self.cleanup()
            }
        }
    }
    
    func disconnect() {
        guard isConnected else {
            log("[\(Date())] VPN nie jest połączony.")
            return
        }

        process?.terminate()
        cleanup()
        isConnected = false
        log("[\(Date())] Rozłączono.")
    }

    /// Czyści zasoby związane z procesem.
    private func cleanup() {
        outputPipe.fileHandleForReading.readabilityHandler = nil
        process = nil
    }

    /// Ogranicza liczbę logów do maksymalnie 500 wpisów.
    private func trimLogsIfNeeded() {
        if logs.count > 500 {
            logs.removeFirst(logs.count - 500)
        }
    }

    /// Dodaje wpis do logów.
    private func log(_ message: String) {
        DispatchQueue.main.async {
            self.logs.append(message)
            self.trimLogsIfNeeded()
        }
    }
}
