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
    
    init(
        alertId: String,
        alertService: AlertService = AlertService()
    ) {
        self.alertId = alertId
        self.alertService = alertService
    }
    
    func fetchAlertDetail() async {
        isLoading = true
        errorMessage = nil
        
        do {
            alertDetail = try await alertService.fetchAlertDetail(alertId: alertId)
            print("✅ Alert detail loaded: \(alertDetail?.title ?? "")")
        } catch {
            errorMessage = "Failed to load alert detail: \(error.localizedDescription)"
            print("❌ Error loading alert detail: \(error)")
        }
        
        isLoading = false
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
                videoUrl: alertDetail.videoUrl,
                notes: alertDetail.notes,
                storeId: alertDetail.storeId,
                cameraId: alertDetail.cameraId,
                cameraName: alertDetail.cameraName,
                aisleLoc: alertDetail.aisleLoc
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
                videoUrl: alertDetail.videoUrl,
                notes: alertDetail.notes,
                storeId: alertDetail.storeId,
                cameraId: alertDetail.cameraId,
                cameraName: alertDetail.cameraName,
                aisleLoc: alertDetail.aisleLoc
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
