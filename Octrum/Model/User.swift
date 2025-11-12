//
//  User.swift
//  Octrum
//
//  Created by Marcelinus Gerardo on 27/10/25.
//

import Foundation

struct LoginResponse: Codable {
    let accessToken: String
    let tokenType: String
    let id: String
    let storeId: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case id
        case storeId = "store_id"
    }
}

struct LoginRequest: Codable {
    let username: String
    let password: String
}

struct UserProfile: Codable {
    let id: String
    let username: String
    let role: String
    let storeId: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case role
        case storeId = "store_id"
    }
}

struct DeviceRegistrationRequest: Codable {
    let userId: String
    let storeId: String
    let deviceToken: String
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case storeId = "store_id"
        case deviceToken = "device_token"
    }
}

struct DeviceRegistrationResponse: Codable {
    let success: Bool
    let message: String?
}
