import Foundation
import SwiftUI
import Combine

public class UserViewModel: ObservableObject {
    static let shared = UserViewModel()
    
    @Published var userProfile: UserProfile?
    @Published var store: Store?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let authService = AuthService.shared
    private let sessionManager = SessionManager.shared
    private var hasFetchedData = false
    
    func fetchDataOnce() {
        guard !hasFetchedData else { return }
        hasFetchedData = true
        fetchUserProfile()
        fetchStore()
    }
    
    func fetchUserProfile() {
        guard let userId = sessionManager.userId else {
            errorMessage = "User ID not found"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        authService.getUserProfile(userId: userId)
            .sink { [weak self] completion in
                DispatchQueue.main.async {
                    self?.isLoading = false
                }
                if case .failure(let error) = completion {
                    DispatchQueue.main.async {
                        self?.errorMessage = "Failed to load profile: \(error.localizedDescription)"
                        print("User profile error: \(error)")
                    }
                }
            } receiveValue: { [weak self] profile in
                DispatchQueue.main.async {
                    self?.userProfile = profile
                    print("User profile loaded: \(profile.username) - \(profile.role)")
                }
            }
            .store(in: &cancellables)
    }
    
    func getUserProfile() {
        guard let userId = sessionManager.userId else {
            errorMessage = "User ID not found"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        authService.getUserProfile(userId: userId)
            .sink { [weak self] completion in
                DispatchQueue.main.async {
                    self?.isLoading = false
                }
                if case .failure(let error) = completion {
                    DispatchQueue.main.async {
                        self?.errorMessage = "Failed to load profile: \(error.localizedDescription)"
                        print("User profile error: \(error)")
                    }
                }
            } receiveValue: { [weak self] profile in
                DispatchQueue.main.async {
                    self?.userProfile = profile
                    print("User profile loaded: \(profile.username) - \(profile.role)")
                }
            }
            .store(in: &cancellables)
    }
    
    func fetchStore() {
        guard let storeId = sessionManager.storeId else {
            errorMessage = "Store ID not found"
            return
        }
        
        authService.getStore(storeId: storeId)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    DispatchQueue.main.async {
                        self?.errorMessage = "Failed to load store: \(error.localizedDescription)"
                        print("Store error: \(error)")
                    }
                }
            } receiveValue: { [weak self] store in
                DispatchQueue.main.async {
                    self?.store = store
                    print("Store loaded: \(store.storeName)")
                }
            }
            .store(in: &cancellables)
    }
    
    func clearData() {
        userProfile = nil
        store = nil
        errorMessage = nil
        hasFetchedData = false
        cancellables.removeAll()
        print("🗑️ UserViewModel: Data cleared")
    }
}
