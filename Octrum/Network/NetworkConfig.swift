//
//  NetworkConfig.swift
//  Octrum
//
//  Created on 07/11/25.
//

import Foundation

struct NetworkConfig {
    static let baseIP = "10.60.49.123"
    
    static let httpPort = "3000"
    
    static var baseURL: String {
        return "http://\(baseIP):\(httpPort)"
    }
    
    static var webSocketURL: String {
        return "ws://\(baseIP):\(httpPort)/ws/alerts"
    }
    
    static var videoBaseURL: String {
        return "\(baseURL)/alert_clips"
    }
}
