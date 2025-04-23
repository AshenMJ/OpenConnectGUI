//
//  AutoConnectView.swift
//  OpenconnectGUI
//
//  Created by Mikołaj Jucha on 23/04/2025.
//
import SwiftUI

struct AutoConnectView: View {
    let config: VPNConfiguration
    let password: String
    let onConnect: () -> Void

    var body: some View {
        Text("Łączenie z \(config.name)...")
            .padding()
            .onAppear {
                onConnect()
            }
    }
}
