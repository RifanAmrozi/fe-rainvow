//
//  NetworkConfig.swift
//  Octrum
//
//  Created on 07/11/25.
//

import Foundation

struct NetworkConfig {
    
    // Dev url
    static let baseIP = "10.60.52.82"
    static let httpPort = "3000"
    
    // Deployed test url
    static let deployUrl = "https://nonobservant-zara-clusteringly.ngrok-free.dev"
    
    static var baseURL: String {
        // return "http://\(baseIP):\(httpPort)"
        return deployUrl
    }
    
    static var webSocketURL: String {
        return "ws://\(baseIP):\(httpPort)/ws/alerts"
    }
    
    static var videoBaseURL: String {
        return "\(baseURL)/alert_clips"
    }
}
