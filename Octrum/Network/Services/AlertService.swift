//
//  AlertService.swift
//  Octrum
//
//  Created by Marcelinus Gerardo on 06/11/25.
//

import Foundation

public class AlertService {
    private let baseURL = NetworkConfig.baseURL
    
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
    
    func fetchAlertDetail(alertId: String) async throws -> AlertDetailResponse {
        guard let url = URL(string: "\(baseURL)/alert/\(alertId)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        print("📥 Alert detail response: Status \(httpResponse.statusCode)")
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        let alertDetail = try JSONDecoder().decode(AlertDetailResponse.self, from: data)
        return alertDetail
    }
    
    func updateAlertStatus(alertId: String, isValid: Bool) async throws {
        guard let url = URL(string: "\(baseURL)/alert/\(alertId)") else {
            throw URLError(.badURL)
        }
        
        var accessToken = SessionManager.shared.accessToken ?? ""
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = ["is_valid": isValid]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        print("✅ Alert \(alertId) updated with is_valid: \(isValid)")
    }
}
