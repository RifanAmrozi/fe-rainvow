//
//  AlertService.swift
//  Octrum
//
//  Created by Marcelinus Gerardo on 06/11/25.
//

import Foundation

class AlertService {
    private let baseURL = "http://10.63.47.194:3000"
    
    func getAlerts(storeId: String) async throws -> [Alert] {
        guard let url = URL(string: "\(baseURL)/alert/store/\(storeId)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let alerts = try JSONDecoder().decode([Alert].self, from: data)
        return alerts
    }
    
    func getAlertsByValidity(storeId: String, isValid: Bool) async throws -> [Alert] {
        let validityParam = isValid ? "true" : "false"
        guard let url = URL(string: "\(baseURL)/alert/store/\(storeId)?is_valid=\(validityParam)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let alerts = try JSONDecoder().decode([Alert].self, from: data)
        return alerts
    }
}
