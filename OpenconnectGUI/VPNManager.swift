//
//  VPNManager.swift
//  OpenconnectGUI
//
//  Created by Mikołaj Jucha on 23/04/2025.
//
import Foundation

/// Manages VPN connection by launching `openconnect` as a subprocess.
class VPNManager: ObservableObject {

    @Published var isConnected: Bool = false
    @Published var logs: [String] = []

    private var stdoutPipe: Pipe?
    private var stderrPipe: Pipe?
    
    /// The currently running process (if any).
    private var process: Process?

    func connect(using config: VPNConfiguration, password: String? = nil) {
        guard process == nil else {
            print("VPN already running.")
            return
        }

        let task = Process()
        task.executableURL = URL(fileURLWithPath: findOpenConnectPath())
        var arguments = ["--protocol", config.protocolType ?? "anyconnect", config.serverAddress]
        arguments.insert("--user=\(config.username)", at: 0)
        task.arguments = arguments

        if let password = password {
            let pipe = Pipe()
            task.standardInput = pipe
            DispatchQueue.global().async {
                if let data = "\(password)\n".data(using: .utf8) {
                    pipe.fileHandleForWriting.write(data)
                }
            }
        }

        stdoutPipe = Pipe()
        stderrPipe = Pipe()
        task.standardOutput = stdoutPipe
        task.standardError = stderrPipe

        listenTo(pipe: stdoutPipe!)
        listenTo(pipe: stderrPipe!)

        do {
            try task.run()
            self.process = task
            self.isConnected = true
            print("VPN process started.")
        } catch {
            print("Failed to start openconnect: \(error)")
        }
    }

    private func listenTo(pipe: Pipe) {
        pipe.fileHandleForReading.readabilityHandler = { handle in
            let data = handle.availableData
            if let output = String(data: data, encoding: .utf8), !output.isEmpty {
                DispatchQueue.main.async {
                    self.logs.append(output.trimmingCharacters(in: .whitespacesAndNewlines))
                }
            }
        }
    }

    func disconnect() {
        process?.terminate()
        process = nil
        isConnected = false
        logs.append("Disconnected.")
    }
    
    private func findOpenConnectPath() -> String {
        let paths = [
            "/opt/homebrew/bin/openconnect",
            "/usr/local/bin/openconnect",
            "/usr/bin/openconnect" // fallback systemowa
        ]
        return paths.first(where: { FileManager.default.fileExists(atPath: $0) }) ?? "/usr/local/bin/openconnect"
    }
}
