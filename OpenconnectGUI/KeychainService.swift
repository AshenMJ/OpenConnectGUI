import Foundation
import Security

/// Provides methods for securely storing and retrieving credentials in the macOS Keychain.
class KeychainService {
    
    // Save VPN password for a given config
    static func savePassword(_ password: String, for config: VPNConfiguration) {
        let account = config.username
        let service = config.serverAddress
        let data = password.data(using: .utf8)!

        let query: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrAccount as String: account,
            kSecAttrServer as String: service,
            kSecValueData as String: data
        ]

        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    // Load VPN password for a given config
    static func loadPassword(for config: VPNConfiguration) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrAccount as String: config.username,
            kSecAttrServer as String: config.serverAddress,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status == errSecSuccess,
              let data = item as? Data,
              let password = String(data: data, encoding: .utf8) else {
            return nil
        }

        return password
    }

    // Delete VPN password for a given config
    static func deletePassword(for config: VPNConfiguration) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrAccount as String: config.username,
            kSecAttrServer as String: config.serverAddress
        ]
        SecItemDelete(query as CFDictionary)
    }

    // MARK: - Generic password for sudo

    static func savePassword(_ password: String, forKey key: String) {
        let data = password.data(using: .utf8)!

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrService as String: "OpenconnectGUI",
            kSecValueData as String: data
        ]

        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    static func loadPassword(forKey key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrService as String: "OpenconnectGUI",
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status == errSecSuccess,
              let data = item as? Data,
              let password = String(data: data, encoding: .utf8) else {
            return nil
        }

        return password
    }

    static func saveSudoPassword(_ password: String) {
        savePassword(password, forKey: "vpn_sudo_password")
    }

    static func loadSudoPassword() -> String? {
        return loadPassword(forKey: "vpn_sudo_password")
    }
}
