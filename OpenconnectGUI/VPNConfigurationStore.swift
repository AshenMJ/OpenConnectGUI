//
//  VPNConfigurationStore.swift
//  OpenconnectGUI
//
//  Created by Mikołaj Jucha on 23/04/2025.
//
import Foundation

/// A store that manages a collection of VPN configurations,
/// providing loading and saving functionality.
class VPNConfigurationStore: ObservableObject {

    /// The list of saved VPN configurations.
    @Published var configurations: [VPNConfiguration] = []
    private var connections: [UUID: VPNConnectionState] = [:]

    /// The URL of the JSON file where configurations are stored.
    private let configFileURL: URL

    /// Initializes the store and attempts to load existing configurations from disk.
    init(filename: String = "vpn_configurations.json") {
        let directory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let folderURL = directory.appendingPathComponent("OpenConnectGUI", isDirectory: true)
        try? FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
        self.configFileURL = folderURL.appendingPathComponent(filename)

        load()
    }

    /// Loads VPN configurations from the JSON file.
    func load() {
        guard FileManager.default.fileExists(atPath: configFileURL.path) else {
            configurations = []
            return
        }

        do {
            let data = try Data(contentsOf: configFileURL)
            configurations = try JSONDecoder().decode([VPNConfiguration].self, from: data)
        } catch {
            print("Failed to load configurations: \(error)")
            configurations = []
        }
    }

    /// Saves the current VPN configurations to the JSON file.
    func save() {
        do {
            let data = try JSONEncoder().encode(configurations)
            try data.write(to: configFileURL)
        } catch {
            print("Failed to save configurations: \(error)")
        }
    }

    /// Adds a new VPN configuration and persists it.
    func add(_ config: VPNConfiguration) {
        configurations.append(config)
        save()
    }

    /// Removes a VPN configuration by its ID and saves the changes.
    func remove(_ config: VPNConfiguration) {
        configurations.removeAll { $0.id == config.id }
        save()
    }

    /// Updates an existing configuration and saves the changes.
    func update(_ updated: VPNConfiguration) {
        if let index = configurations.firstIndex(where: { $0.id == updated.id }) {
            configurations[index] = updated
            save()
        }
    }
}
