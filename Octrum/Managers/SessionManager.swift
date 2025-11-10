import Foundation
import SwiftUI
import Combine
import Security

public class SessionManager: ObservableObject {
    
    static let shared = SessionManager()
    
    @Published var isLoggedIn: Bool = false
    @Published var accessToken: String?
    @Published var userId: String?
    @Published var storeId: String?

    private let service = "com.octrum.app"
    private let accessTokenKey = "accessToken"
    private let userIdKey = "userId"
    private let storeIdKey = "storeId"
    private let hasLaunchedBeforeKey = "hasLaunchedBefore"
    
    private init() {
        if !UserDefaults.standard.bool(forKey: hasLaunchedBeforeKey) {
            clearKeychainOnFirstLaunch()
            UserDefaults.standard.set(true, forKey: hasLaunchedBeforeKey)
        }
        
        self.accessToken = getKeychain(key: accessTokenKey)
        self.userId = getKeychain(key: userIdKey)
        self.storeId = getKeychain(key: storeIdKey)
        self.isLoggedIn = self.accessToken != nil
    }
    
    private func clearKeychainOnFirstLaunch() {
        deleteKeychain(key: accessTokenKey)
        deleteKeychain(key: userIdKey)
        deleteKeychain(key: storeIdKey)
        print("🧹 Cleared keychain on first launch")
    }

    func saveSession(token: String, userId: String, storeId: String) {
        DispatchQueue.main.async {
            self.saveKeychain(key: self.accessTokenKey, value: token)
            self.saveKeychain(key: self.userIdKey, value: userId)
            self.saveKeychain(key: self.storeIdKey, value: storeId)
            
            self.accessToken = token
            self.userId = userId
            self.storeId = storeId
            self.isLoggedIn = true
        }
    }

    func clearSession() {
        DispatchQueue.main.async {
            self.deleteKeychain(key: self.accessTokenKey)
            self.deleteKeychain(key: self.userIdKey)
            self.deleteKeychain(key: self.storeIdKey)
            
            self.accessToken = nil
            self.userId = nil
            self.storeId = nil
            self.isLoggedIn = false
        }
    }

    // Keychain Helpers
    private func saveKeychain(key: String, value: String) {
        let data = Data(value.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            print("Error saving to keychain: \(status)")
        }
    }

    private func getKeychain(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess, let data = dataTypeRef as? Data {
            return String(data: data, encoding: .utf8)
        } else {
            return nil
        }
    }

    private func deleteKeychain(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess && status != errSecItemNotFound {
            print("Error deleting from keychain: \(status)")
        }
    }
}
