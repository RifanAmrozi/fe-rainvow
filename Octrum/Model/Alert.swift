//
//  Alert.swift
//  Octrum
//
//  Created by Marcelinus Gerardo on 06/11/25.
//

import Foundation

struct Alert: Identifiable, Codable {
    let id: String
    let title: String
    let incidentStart: String
    let isValid: Bool?
    let videoUrl: String
    let notes: String?
    let cameraName: String
    let aisleLoc: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case incidentStart = "incident_start"
        case isValid = "is_valid"
        case videoUrl = "video_url"
        case notes
        case cameraName = "camera_name"
        case aisleLoc = "aisle_loc"
    }
    
    // Format timestamp untuk display
    var formattedTimestamp: String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = formatter.date(from: incidentStart) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "HH:mm:ss - EEE dd/MM/yyyy"
            return displayFormatter.string(from: date)
        }
        return incidentStart
    }
}
