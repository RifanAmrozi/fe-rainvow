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
    let photoUrl: String
    let videoUrl: String
    let notes: String?
    let cameraName: String
    let aisleLoc: String
    let updatedBy: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case incidentStart = "incident_start"
        case isValid = "is_valid"
        case photoUrl = "photo_url"
        case videoUrl = "video_url"
        case notes
        case cameraName = "camera_name"
        case aisleLoc = "aisle_loc"
        case updatedBy = "updated_by"
    }
    
    var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        
        if let date = formatter.date(from: incidentStart) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "HH:mm:ss - EEE dd/MM/yyyy"
            displayFormatter.locale = Locale(identifier: "en_US_POSIX")
            return displayFormatter.string(from: date)
        }
        return incidentStart
    }
}

struct AlertDetailResponse: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let incidentStart: String
    let isValid: Bool?
    let videoUrl: String
    let notes: String?
    let storeId: String
    let cameraId: String
    let cameraName: String
    let aisleLoc: String
    let updatedBy: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case incidentStart = "incident_start"
        case isValid = "is_valid"
        case videoUrl = "video_url"
        case notes
        case storeId = "store_id"
        case cameraId = "camera_id"
        case cameraName = "camera_name"
        case aisleLoc = "aisle_loc"
        case updatedBy = "updated_by"
    }
    
    var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        
        if let date = formatter.date(from: incidentStart) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "HH:mm:ss - EEE dd/MM/yyyy"
            displayFormatter.locale = Locale(identifier: "en_US_POSIX")
            return displayFormatter.string(from: date)
        }
        return incidentStart
    }
}
