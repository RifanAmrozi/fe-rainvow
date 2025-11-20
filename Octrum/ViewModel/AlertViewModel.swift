//
//  AlertViewModel.swift
//  Octrum
//
//  Created by Marcelinus Gerardo on 06/11/25.
//

import Foundation
import Combine

@MainActor
class AlertViewModel: ObservableObject {
    @Published var alerts: [Alert] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var totalAlerts: Int = 0
    
    private let alertService: AlertService
    private let sessionManager: SessionManager
    
    var emptyStateTitle: String {
        "The system is unable to detect under following conditions:"
    }
    
    var emptyStateMessage: String {
        """
        • The view is blurry without any lightings 
        • ⁠The person is too far from camera
        • The person is too close from camera
        • ⁠Children and crowded environment
        """
    }
    
    init(
        alertService: AlertService = AlertService(),
        sessionManager: SessionManager = SessionManager.shared
    ) {
        self.alertService = alertService
        self.sessionManager = sessionManager
    }
    
    func fetchAlerts() {
        guard let storeId = sessionManager.storeId else {
            errorMessage = "Store ID not found. Please log in again."
            print("❌ Error: Store ID not found")
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let fetchedAlerts = try await alertService.getAlerts(storeId: storeId)
                
                self.alerts = fetchedAlerts
                
                for alert in fetchedAlerts {
                    AlertStateManager.shared.updateAlertStatus(alertId: alert.id, isValid: alert.isValid)
                }
                totalAlerts = fetchedAlerts.count
                
                self.isLoading = false
            } catch {
                let nsError = error as NSError
                if nsError.domain == NSURLErrorDomain {
                    switch nsError.code {
                    case -1011: // HTTP 500 Internal Server Error
                        self.errorMessage = "Server error. Please try again later or contact support."
                        print("❌ HTTP 500: Server internal error - \(error.localizedDescription)")
                    case -1001: // Timeout
                        self.errorMessage = "Request timeout. Please check your internet connection."
                        print("❌ Timeout error: \(error.localizedDescription)")
                    case -1009: // No internet
                        self.errorMessage = "No internet connection. Please check your network."
                        print("❌ No internet: \(error.localizedDescription)")
                    default:
                        self.errorMessage = "Network error: \(error.localizedDescription)"
                        print("❌ Network error (\(nsError.code)): \(error.localizedDescription)")
                    }
                } else {
                    self.errorMessage = error.localizedDescription
                    print("❌ Error fetching alerts: \(error.localizedDescription)")
                }
                self.isLoading = false
            }
        }
    }
    
    func refreshAlerts() async {
        print("🔄 AlertViewModel: Manual refresh triggered")
        fetchAlerts()
        try? await Task.sleep(nanoseconds: 500_000_000)
    }
    
    func clearData() {
        alerts = []
        errorMessage = nil
        isLoading = false
        print("🗑️ AlertViewModel: Data cleared")
    }
}
