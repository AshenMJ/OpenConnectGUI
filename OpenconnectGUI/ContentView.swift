//
//  ContentView.swift
//  OpenconnectGUI
//
//  Created by Mikołaj Jucha on 23/04/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var store = VPNConfigurationStore()

    var body: some View {
        VPNListView(store: store)
    }
}

#Preview {
    ContentView()
}
