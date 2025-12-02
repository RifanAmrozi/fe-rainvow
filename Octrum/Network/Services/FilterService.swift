//
//  FilterService.swift
//  Octrum
//
//  Created on 24/11/25.
//

import Foundation

struct AisleLocationsResponse: Codable {
    let aisleLocations: [String]
    
    enum CodingKeys: String, CodingKey {
        case aisleLocations = "aisle_locations"
    }
}

public class FilterService {
    static let shared = FilterService()
    
    private init() {}
    
    func fetchAisleLocations(storeId: String) async throws -> [String] {
        guard let url = URL(string: "\(NetworkConfig.baseURL)/camera/aisle-loc?store_id=\(storeId)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        let responseData = try JSONDecoder().decode(AisleLocationsResponse.self, from: data)
        let aisleLocations = responseData.aisleLocations
        print("✅ Fetched aisle locations: \(aisleLocations)")
        return aisleLocations
    }
}
