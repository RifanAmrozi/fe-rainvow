//
//  AlertHistoryViewModel.swift
//  Octrum
//
//  Created by AI Assistant on 07/11/25.
//

import Foundation
import Combine

@MainActor
class AlertHistoryViewModel: ObservableObject {
    @Published var confirmedAlerts: [Alert] = []
    @Published var ignoredAlerts: [Alert] = []
    @Published var isLoadingConfirmed = false
    @Published var isLoadingIgnored = false
    @Published var errorMessage: String?
    
    private let alertService = AlertService()
    
    func fetchAlerts() {
        guard let storeId = SessionManager.shared.storeId else {
            errorMessage = "Store ID not found"
            return
        }
        
        // Fetch both confirmed and ignored alerts
        fetchConfirmedAlerts(storeId: storeId)
        fetchIgnoredAlerts(storeId: storeId)
    }
    
    private func fetchConfirmedAlerts(storeId: String) {
        isLoadingConfirmed = true
        errorMessage = nil
        
        Task {
            do {
                confirmedAlerts = try await alertService.getAlertsByValidity(storeId: storeId, isValid: true)
                isLoadingConfirmed = false
            } catch {
                errorMessage = error.localizedDescription
                isLoadingConfirmed = false
            }
        }
    }
    
    private func fetchIgnoredAlerts(storeId: String) {
        isLoadingIgnored = true
        errorMessage = nil
        
        Task {
            do {
                ignoredAlerts = try await alertService.getAlertsByValidity(storeId: storeId, isValid: false)
                isLoadingIgnored = false
            } catch {
                errorMessage = error.localizedDescription
                isLoadingIgnored = false
            }
        }
    }
}
