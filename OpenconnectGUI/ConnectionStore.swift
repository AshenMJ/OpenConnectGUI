//
//  ConnectionStore.swift
//  OpenconnectGUI
//
//  Created by Mikołaj Jucha on 23/04/2025.
//

import Foundation

/// Przechowuje instancje VPNConnectionState bez mutacji w body.
class ConnectionStore: ObservableObject {
  @Published private(set) var states: [UUID: VPNConnectionState] = [:]

  /// Zwraca istniejący obiekt albo tworzy nowy, ale zapisuje go
  /// w `states` *dopiero* w następnym cyklu głównego wątku.
  func connection(for config: VPNConfiguration) -> VPNConnectionState {
    if let existing = states[config.id] {
      return existing
    }
    let newOne = VPNConnectionState(config: config)
    // mutujemy @Published poza body — w async to unikniemy błędu
    DispatchQueue.main.async {
      self.states[config.id] = newOne
    }
    return newOne
  }
    func remove(_ config: VPNConfiguration) {
        DispatchQueue.main.async {
          self.states[config.id] = nil
        }
      }
}
