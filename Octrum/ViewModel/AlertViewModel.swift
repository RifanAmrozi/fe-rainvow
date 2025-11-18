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
    
    private let alertService: AlertService
    private let sessionManager: SessionManager
    
    var emptyStateTitle: String {
        "The alert clip view might be not optimal due to certain conditions:"
    }
    
    var emptyStateMessage: String {
        """
        • Blurry view
        • The person is too far
        • The environment is too dark
        • The person detected is children
        • Overcrowded
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
                self.isLoading = false
                print("✅ Fetched \(fetchedAlerts.count) alerts")
            } catch {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
                print("❌ Error fetching alerts: \(error.localizedDescription)")
            }
        }
    }
    
    func refreshAlerts() async {
        fetchAlerts()
        try? await Task.sleep(nanoseconds: 500_000_000)
    }
}
