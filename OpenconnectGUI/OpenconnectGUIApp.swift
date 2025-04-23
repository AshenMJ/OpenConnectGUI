//
//  OpenconnectGUIApp.swift
//  OpenconnectGUI
//
//  Created by Mikołaj Jucha on 23/04/2025.
//

import SwiftUI
import UserNotifications

@main
struct OpenconnectGUIApp: App {
    init() {
          // poproś użytkownika o pozwolenie na powiadomienia
          UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
              if let err = error {
                  print("Notification auth error:", err)
              }
          }
      }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
