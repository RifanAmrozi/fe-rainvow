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
    var status: Bool?
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
    
    init(id: String, name: String, aisleLoc: String, previewImg: String? = nil, rtspUrl: String, webrtcUrl: String? = nil, status: Bool? = nil, storeId: String) {
        self.id = id
        self.name = name
        self.aisleLoc = aisleLoc
        self.previewImg = previewImg
        self.rtspUrl = rtspUrl
        self.webrtcUrl = webrtcUrl
        self.status = status
        self.storeId = storeId
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        aisleLoc = try container.decode(String.self, forKey: .aisleLoc)
        previewImg = try? container.decode(String.self, forKey: .previewImg)
        rtspUrl = try container.decode(String.self, forKey: .rtspUrl)
        webrtcUrl = try? container.decode(String.self, forKey: .webrtcUrl)
        status = try? container.decode(Bool.self, forKey: .status)
        storeId = try container.decode(String.self, forKey: .storeId)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(aisleLoc, forKey: .aisleLoc)
        try container.encodeIfPresent(previewImg, forKey: .previewImg)
        try container.encode(rtspUrl, forKey: .rtspUrl)
        try container.encodeIfPresent(webrtcUrl, forKey: .webrtcUrl)
        try container.encodeIfPresent(status, forKey: .status)
        try container.encode(storeId, forKey: .storeId)
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
