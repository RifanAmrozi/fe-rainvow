//
//  AlertViewModel.swift
//  Octrum
//
//  Created by Marcelinus Gerardo on 06/11/25.
//

import Foundation
import Combine

class AlertViewModel: ObservableObject {
    @Published var alerts: [Alert] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let alertService = AlertService()
    private let sessionManager = SessionManager.shared
    
    func fetchAlerts() {
        guard let storeId = sessionManager.storeId else {
            errorMessage = "Store ID not found"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let fetchedAlerts = try await alertService.getAlerts(storeId: storeId)
                
                await MainActor.run {
                    self.alerts = fetchedAlerts
                    self.isLoading = false
                    print("✅ Fetched \(fetchedAlerts.count) alerts")
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                    print("❌ Error fetching alerts: \(error.localizedDescription)")
                }
            }
        }
    }
}
