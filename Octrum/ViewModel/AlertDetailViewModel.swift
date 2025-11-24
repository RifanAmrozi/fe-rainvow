//
//  AlertDetailViewModel.swift
//  Octrum
//
//  Created by AI Assistant on 12/11/25.
//

import Foundation
import Combine

@MainActor
public class AlertDetailViewModel: ObservableObject {
    @Published var alertDetail: AlertDetailResponse?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isProcessing: Bool = false
    @Published var isUpdated: Bool = false
    
    private let alertService: AlertService
    private let alertId: String
    private let existingAlert: Alert?
    
    init(
        alertId: String,
        existingAlert: Alert? = nil,
        alertService: AlertService = AlertService()
    ) {
        self.alertId = alertId
        self.existingAlert = existingAlert
        self.alertService = alertService
        
        if let existingAlert = existingAlert {
            self.alertDetail = convertAlertToDetailResponse(existingAlert)
            print("Using cached alert data.")
        }
    }
    
    func fetchAlertDetail() async {
        // Gunakan cache jika ada
        if let existingAlert = existingAlert {
            // HANYA sync state manager jika belum ada state tersimpan
            // Prioritaskan state manager yang sudah ada (dari user action)
            if AlertStateManager.shared.getAlertStatus(alertId: existingAlert.id) == nil {
                AlertStateManager.shared.updateAlertStatus(alertId: existingAlert.id, isValid: existingAlert.isValid)
                print("🔄 Initial sync alert state from cache: \(existingAlert.isValid?.description ?? "nil")")
            } else {
                print("✅ State manager already has value, keeping existing state")
            }
            print("Using cached alert data.")
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            alertDetail = try await alertService.fetchAlertDetail(alertId: alertId)
            print("✅ Alert detail loaded from API: \(alertDetail?.title ?? "")")
            
            if let alertDetail = alertDetail {
                if AlertStateManager.shared.getAlertStatus(alertId: alertDetail.id) == nil {
                    AlertStateManager.shared.updateAlertStatus(alertId: alertDetail.id, isValid: alertDetail.isValid)
                    print("🔄 Initial sync alert state from API: \(alertDetail.isValid?.description ?? "nil")")
                } else {
                    print("✅ State manager already has value, keeping existing state")
                }
            }
        } catch {
            errorMessage = "Failed to load alert detail: \(error.localizedDescription)"
            print("❌ Error loading alert detail: \(error)")
        }
        
        isLoading = false
    }
    
    func refreshAlertDetail() async {
        isLoading = true
        errorMessage = nil
        
        do {
            alertDetail = try await alertService.fetchAlertDetail(alertId: alertId)
            print("✅ Alert detail refreshed from API: \(alertDetail?.title ?? "")")
            
            // Sinkronkan state manager dengan data terbaru dari API
            if let alertDetail = alertDetail {
                AlertStateManager.shared.updateAlertStatus(alertId: alertDetail.id, isValid: alertDetail.isValid)
                print("🔄 Synced alert state from API refresh: \(alertDetail.isValid?.description ?? "nil")")
            }
        } catch {
            errorMessage = "Failed to refresh alert detail: \(error.localizedDescription)"
            print("❌ Error refreshing alert detail: \(error)")
        }
        
        isLoading = false
    }
    
    private func convertAlertToDetailResponse(_ alert: Alert) -> AlertDetailResponse {
        let storeId = SessionManager.shared.storeId ?? ""
        return AlertDetailResponse(
            id: alert.id,
            title: alert.title,
            incidentStart: alert.incidentStart,
            isValid: alert.isValid,
            photoUrl: alert.photoUrl,
            videoUrl: alert.videoUrl,
            notes: alert.notes,
            storeId: storeId,
            cameraId: "", // Camera ID tidak ada di Alert model, tapi tidak critical
            cameraName: alert.cameraName,
            aisleLoc: alert.aisleLoc,
            updatedBy: alert.updatedBy
        )
    }
    
    func confirmAlert() async {
        guard let alertDetail = alertDetail else { return }
        
        isProcessing = true
        
        do {
            try await alertService.updateAlertStatus(alertId: alertDetail.id, isValid: true)
            print("✅ Alert confirmed successfully")
            
            self.alertDetail = AlertDetailResponse(
                id: alertDetail.id,
                title: alertDetail.title,
                incidentStart: alertDetail.incidentStart,
                isValid: true,
                photoUrl: alertDetail.photoUrl,
                videoUrl: alertDetail.videoUrl,
                notes: alertDetail.notes,
                storeId: alertDetail.storeId,
                cameraId: alertDetail.cameraId,
                cameraName: alertDetail.cameraName,
                aisleLoc: alertDetail.aisleLoc,
                updatedBy: alertDetail.updatedBy
            )
            isUpdated = true
        } catch {
            errorMessage = "Failed to confirm alert: \(error.localizedDescription)"
            print("❌ Error confirming alert: \(error)")
        }
        
        isProcessing = false
    }
    
    func ignoreAlert() async {
        guard let alertDetail = alertDetail else { return }
        
        isProcessing = true
        
        do {
            try await alertService.updateAlertStatus(alertId: alertDetail.id, isValid: false)
            print("✅ Alert ignored successfully")
            
            self.alertDetail = AlertDetailResponse(
                id: alertDetail.id,
                title: alertDetail.title,
                incidentStart: alertDetail.incidentStart,
                isValid: false,
                photoUrl: alertDetail.photoUrl,
                videoUrl: alertDetail.videoUrl,
                notes: alertDetail.notes,
                storeId: alertDetail.storeId,
                cameraId: alertDetail.cameraId,
                cameraName: alertDetail.cameraName,
                aisleLoc: alertDetail.aisleLoc,
                updatedBy: alertDetail.updatedBy
            )
            isUpdated = true
        } catch {
            errorMessage = "Failed to ignore alert: \(error.localizedDescription)"
            print("❌ Error ignoring alert: \(error)")
        }
        
        isProcessing = false
    }
    
    var statusText: String {
        guard let alertDetail = alertDetail else { return "Unknown" }
        
        if let isValid = alertDetail.isValid {
            return isValid ? "Confirmed" : "Ignored"
        }
        return "Pending Review"
    }
    
    var statusColor: String {
        guard let alertDetail = alertDetail else { return "gray" }
        
        if let isValid = alertDetail.isValid {
            return isValid ? "green" : "red"
        }
        return "orange"
    }
}
