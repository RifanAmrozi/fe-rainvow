//
//  Camera.swift
//  Octrum
//
//  Created by Marcelinus Gerardo on 17/10/25.
//

import Foundation

struct Camera: Identifiable, Codable {
    let id: UUID
    var name: String
    var webRTCURL: String
}
