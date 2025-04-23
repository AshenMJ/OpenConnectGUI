//
//  NotificationManager.swift
//  OpenconnectGUI
//
//  Created by Mikołaj Jucha on 23/04/2025.
//
import UserNotifications

struct NotificationManager {
    static func postConnectionSuccess(for name: String) {
        let content = UNMutableNotificationContent()
        content.title = "VPN Connected"
        content.body  = "You are now connected to \(name)."
        content.sound = .default

        let req = UNNotificationRequest(
            identifier: "vpn.connected.\(name)",
            content: content,
            trigger: nil // natychmiastowe
        )

        UNUserNotificationCenter.current().add(req) { err in
            if let e = err { print("Notification error:", e) }
        }
    }
    static func postConnectionDisconnected(for name: String) {
        let content = UNMutableNotificationContent()
        content.title = "VPN Disconected"
        content.body  = "You are now disconnected from \(name)."
        content.sound = .default

        let req = UNNotificationRequest(
            identifier: "vpn.disconected.\(name)",
            content: content,
            trigger: nil // natychmiastowe
        )

        UNUserNotificationCenter.current().add(req) { err in
            if let e = err { print("Notification error:", e) }
        }
    }
}
