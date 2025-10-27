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
