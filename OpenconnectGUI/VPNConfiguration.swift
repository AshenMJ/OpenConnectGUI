//
//  VPNConfiguration.swift
//  OpenconnectGUI
//
//  Created by Mikołaj Jucha on 23/04/2025.
//
import Foundation

/// Represents a single VPN configuration used by the application.
struct VPNConfiguration: Identifiable, Codable, Equatable {

    /// A unique identifier for the VPN configuration.
    var id: UUID = UUID()
    
    /// A human-readable name for the configuration (displayed in the UI).
    var name: String
    
    /// The VPN server address (e.g., "https://vpn.example.com").
    var serverAddress: String
    
    /// The username used for VPN authentication.
    var username: String

    /// Optional VPN protocol type (e.g., "anyconnect", "gp", "nc", "pulse", "fortinet").
    var protocolType: String?

    /// Indicates whether to store credentials securely in the Keychain.
    var rememberCredentials: Bool
}
