import Foundation

struct Store: Codable {
    let id: String
    let storeName: String
    let storeAddress: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case storeName = "store_name"
        case storeAddress = "store_address"
    }
}