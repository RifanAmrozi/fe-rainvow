//
//  CameraService.swift
//  Octrum
//
//  Created by Marcelinus Gerardo on 23/10/25.
//

import Foundation
import Combine

public class CameraService {
    static let shared = CameraService()
    
    private let baseURL = "http://10.60.61.85:3000"
    private var session: SessionManager { SessionManager.shared }
    
    private init() {}
    
    func fetchCameras() -> AnyPublisher<[Camera], Error> {
        guard let storeId = session.storeId else {
            return Fail(error: URLError(.userAuthenticationRequired)).eraseToAnyPublisher()
        }
        
        guard let url = URL(string: "\(baseURL)/camera?store_id=\(storeId)")
        else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response -> Data in
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Raw API Response: \(jsonString)")
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                
                print("HTTP Status Code: \(httpResponse.statusCode)")
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    throw URLError(.badServerResponse)
                }
                
                return data
            }
            .decode(type: [Camera].self, decoder: JSONDecoder())
            .mapError { error in
                if let decodingError = error as? DecodingError {
                    print("Decoding Error Details: \(decodingError)")
                    switch decodingError {
                    case .keyNotFound(let key, let context):
                        print("Missing key: \(key.stringValue), context: \(context.debugDescription)")
                    case .typeMismatch(let type, let context):
                        print("Type mismatch for type: \(type), context: \(context.debugDescription)")
                    case .valueNotFound(let type, let context):
                        print("Value not found for type: \(type), context: \(context.debugDescription)")
                    case .dataCorrupted(let context):
                        print("Data corrupted: \(context.debugDescription)")
                    @unknown default:
                        print("Unknown decoding error")
                    }
                }
                return error
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func fetchCamera(id: String) -> AnyPublisher<Camera, Error> {
        guard let url = URL(string: "\(baseURL)/camera?id=\(id)") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: Camera.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func createCamera(name: String, aisleLoc: String, rtspUrl: String) -> AnyPublisher<Camera, Error> {
        guard let url = URL(string: "\(baseURL)/camera") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        guard let storeId = session.storeId else {
            return Fail(error: URLError(.userAuthenticationRequired)).eraseToAnyPublisher()
        }
        
        let request = CreateCameraRequest(
            name: name,
            aisleLoc: aisleLoc,
            rtspUrl: rtspUrl,
            storeId: storeId
        )
        
        guard let jsonData = try? JSONEncoder().encode(request) else {
            return Fail(error: URLError(.cannotParseResponse)).eraseToAnyPublisher()
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = jsonData
        
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .map(\.data)
            .decode(type: Camera.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
