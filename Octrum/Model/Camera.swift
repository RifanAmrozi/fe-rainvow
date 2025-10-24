//
//  Camera.swift
//  Octrum
//
//  Created by Marcelinus Gerardo on 17/10/25.
//

import Foundation

struct Camera: Identifiable, Codable {
    let id: String
    var name: String
    var aisleLoc: String
    var previewImg: String?
    var rtspUrl: String
    var webrtcUrl: String?
    var status: Bool
    var storeId: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case aisleLoc = "aisle_loc"
        case previewImg = "preview_img"
        case rtspUrl = "rtsp_url"
        case webrtcUrl = "webrtc_url"
        case status
        case storeId = "store_id"
    }
}

struct CreateCameraRequest: Codable {
    let name: String
    let aisleLoc: String
    let rtspUrl: String
    let storeId: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case aisleLoc = "aisle_loc"
        case rtspUrl = "rtsp_url"
        case storeId = "store_id"
    }
}
