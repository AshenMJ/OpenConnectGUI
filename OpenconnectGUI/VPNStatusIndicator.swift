//
//  VPNStatusIndicator.swift
//  OpenconnectGUI
//
//  Created by Mikołaj Jucha on 23/04/2025.
//
import SwiftUI

/// A small colored circle indicating VPN connection status.
struct VPNStatusIndicator: View {
    var isConnected: Bool

    var body: some View {
        Circle()
            .fill(isConnected ? Color.green : Color.gray)
            .frame(width: 10, height: 10)
            .shadow(radius: isConnected ? 2 : 0)
    }
}
