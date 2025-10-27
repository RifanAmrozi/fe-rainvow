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
    
    private let baseURL = "http://10.98.169.194:3000"
    private let storeId = "d4c77b10-1a0f-4c21-9a7b-8bcb1c2a5678"
    
    private init() {}
    
    func fetchCameras() -> AnyPublisher<[Camera], Error> {
        guard let url = URL(string: "\(baseURL)/camera") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [Camera].self, decoder: JSONDecoder())
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
