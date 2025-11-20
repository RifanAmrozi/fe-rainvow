import Foundation
import Combine

@MainActor
public class AuthViewModel: ObservableObject {
    @Published var username = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let authService = AuthService.shared
    private let sessionManager = SessionManager.shared
    private let deviceViewModel = DeviceViewModel()
    
    func login() {
        isLoading = true
        errorMessage = nil
        
        let loginRequest = LoginRequest(username: username, password: password)
        
        authService.login(request: loginRequest)
            .sink { [weak self] completion in
                DispatchQueue.main.async {
                    self?.isLoading = false
                }
                if case .failure(let error) = completion {
                    DispatchQueue.main.async {
                        self?.errorMessage = "Login failed: \(error.localizedDescription)"
                        print("Login error: \(error)")
                    }
                }
            } receiveValue: { [weak self] response in
                print("Login successful: \(response)")
                DispatchQueue.main.async {
                    self?.isLoading = false
                }
                
                self?.sessionManager.saveSession(
                    token: response.accessToken,
                    userId: response.id,
                    storeId: response.storeId
                )
                
                self?.deviceViewModel.registerDeviceAfterLogin(
                    userId: response.id,
                    storeId: response.storeId
                )
            }
            .store(in: &cancellables)
    }
}
