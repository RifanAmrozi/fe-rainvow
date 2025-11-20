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
    static let shared = AlertHistoryViewModel()
    
    @Published var confirmedAlerts: [Alert] = []
    @Published var ignoredAlerts: [Alert] = []
    @Published var isLoadingConfirmed = false
    @Published var isLoadingIgnored = false
    @Published var errorMessage: String?
    
    private let alertService = AlertService()
    private var hasFetchedData = false
    
    private init() {
        // Private init to enforce singleton
    }
    
    func fetchAlertsOnce() {
        guard !hasFetchedData else {
            print("📦 AlertHistoryViewModel: Using cached data")
            return
        }
        hasFetchedData = true
        print("🔵 AlertHistoryViewModel: First fetch - loading data")
        fetchAlerts()
    }
    
    func fetchAlerts() {
        guard let storeId = SessionManager.shared.storeId else {
            errorMessage = "Store ID not found"
            return
        }
        
        // Fetch both confirmed and ignored alerts
        fetchConfirmedAlerts(storeId: storeId)
        fetchIgnoredAlerts(storeId: storeId)
    }
    
    func refreshAlerts() async {
        print("🔄 AlertHistoryViewModel: Manual refresh triggered")
        fetchAlerts()
        try? await Task.sleep(nanoseconds: 500_000_000)
    }
    
    private func fetchConfirmedAlerts(storeId: String) {
        isLoadingConfirmed = true
        errorMessage = nil
        
        Task {
            do {
                confirmedAlerts = try await alertService.getAlertsByValidity(storeId: storeId, isValid: true)
                isLoadingConfirmed = false
                print("✅ Fetched \(confirmedAlerts.count) confirmed alerts")
            } catch {
                errorMessage = error.localizedDescription
                isLoadingConfirmed = false
                print("❌ Error fetching confirmed alerts: \(error.localizedDescription)")
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
                print("✅ Fetched \(ignoredAlerts.count) ignored alerts")
            } catch {
                errorMessage = error.localizedDescription
                isLoadingIgnored = false
                print("❌ Error fetching ignored alerts: \(error.localizedDescription)")
            }
        }
    }
    
    func clearData() {
        confirmedAlerts = []
        ignoredAlerts = []
        errorMessage = nil
        hasFetchedData = false
        isLoadingConfirmed = false
        isLoadingIgnored = false
        print("🗑️ AlertHistoryViewModel: Data cleared")
    }
}
