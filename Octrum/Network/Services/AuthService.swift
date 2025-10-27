import Foundation
import Combine

public class AuthService {
    static let shared = AuthService()
    private let baseURL = "http://10.60.61.85:3000"
    
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
                if let httpResponse = response as? HTTPURLResponse {
                    print("📊 HTTP Status: \(httpResponse.statusCode)")
                }
                if let responseString = String(data: data, encoding: .utf8) {
                    print("📋 Response data: \(responseString)")
                }
                
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
}
