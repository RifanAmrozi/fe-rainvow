import Foundation
import Combine

public class AuthService {
    static let shared = AuthService()
    private let baseURL = NetworkConfig.baseURL
    
    private init() {}
    
    func login(request: LoginRequest) -> AnyPublisher<LoginResponse, Error> {
        guard let url = URL(string: "\(baseURL)/user/login") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            urlRequest.httpBody = try JSONEncoder().encode(request)
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        print("🔐 Attempting login to: \(url)")
        print("📤 Login request: \(request)")
        
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap { data, response -> Data in
                print("📥 Received response")
                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    print("❌ Bad server response")
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: LoginResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func getUserProfile(userId: String) -> AnyPublisher<UserProfile, Error> {
        guard let url = URL(string: "\(baseURL)/user/\(userId)") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        print("🔍 Fetching user profile from: \(url)")
        
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap { data, response -> Data in
                print("📥 Received user profile response")
                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    print("❌ Bad server response for user profile")
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: UserProfile.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func getStore(storeId: String) -> AnyPublisher<Store, Error> {
        guard let url = URL(string: "\(baseURL)/store?id=\(storeId)") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        print("🏪 Fetching store data from: \(url)")
        
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap { data, response -> Data in
                print("📥 Received store response")
                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    print("❌ Bad server response for store")
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: [Store].self, decoder: JSONDecoder())
            .tryMap { stores -> Store in
                guard let store = stores.first else {
                    throw URLError(.cannotParseResponse)
                }
                return store
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
