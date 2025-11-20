//
//  DeviceService.swift
//  Octrum
//
//  Created by Marcelinus Gerardo on 11/11/25.
//

import Foundation

public class DeviceService {
    private let baseURL = NetworkConfig.baseURL
    private let session = SessionManager.shared
    
    func registerDevice(userId: String, storeId: String, deviceToken: String) async throws {
        guard let url = URL(string: "\(baseURL)/user/device") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let accessToken = session.accessToken {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        
        let requestBody = DeviceRegistrationRequest(
            userId: userId,
            storeId: storeId,
            deviceToken: deviceToken
        )
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        request.httpBody = try encoder.encode(requestBody)
        
        print("📤 Registering device token to backend...")
        print("   User ID: \(userId)")
        print("   Store ID: \(storeId)")
        print("   Device Token: \(deviceToken)")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        print("📥 Device registration response: Status \(httpResponse.statusCode)")
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorString = String(data: data, encoding: .utf8) {
                print("❌ Error response: \(errorString)")
            }
            throw URLError(.badServerResponse)
        }
        
        print("✅ Device token registered successfully")
    }
}
