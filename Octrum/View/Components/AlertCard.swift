//
//  AlertCard.swift
//  Octrum
//
//  Created by Marcelinus Gerardo on 06/11/25.
//

import SwiftUI
import AVKit
import Kingfisher

struct AlertCard: View {
    let alert: Alert
    var onStatusUpdated: (() -> Void)?
    
    @State private var isShowPerson = false
    @State private var player: AVPlayer?
    @State private var isProcessing = false
    @ObservedObject private var stateManager = AlertStateManager.shared
    
    private let alertService = AlertService()
    
    private var currentStatus: Bool? {
        // Prioritas: state manager (local update) > alert.isValid (dari API)
        return stateManager.getAlertStatus(alertId: alert.id) ?? alert.isValid
    }
    
    private var timeComponents: [String] {
        alert.formattedTimestamp.components(separatedBy: "-")
    }
    
    var body: some View {
        NavigationLink(destination: AlertDetailView(alertId: alert.id, alert: alert)) {
            cardContent
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var cardContent: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
                
                Text("ACTIVITY DETECTED!")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.red)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(alert.cameraName)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text("•")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.gray.opacity(0.5))
                    
                    Text(alert.aisleLoc)
                        .font(.system(size: 32, weight: .regular))
                        .foregroundColor(.black)
                }
                
                HStack {
                    Text(timeComponents.first ?? "")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.black)
                    
                    Text("-")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text(timeComponents.last ?? "")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.black)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            if let player = player {
                VideoPlayer(player: player)
                    .aspectRatio(16/9, contentMode: .fit)
                    .cornerRadius(10)
                    .padding(.vertical, 8)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .aspectRatio(16/9, contentMode: .fit)
                    .cornerRadius(10)
                    .overlay(
                        Image(systemName: "video.slash")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                    )
            }
            
            dropdownPhoto()
                .padding(.top, 4)
            
            actionButton()
                .padding(.top, 4)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10)
            .stroke(Color.gray.opacity(0.3), lineWidth: 1))
        .padding(.horizontal)
        .onAppear {
            setupVideoPlayer()
        }
    }
    
    private func dropdownPhoto() -> some View {
        VStack {
            HStack {
                Image(systemName: "photo")
                    .font(.system(size: 14))
                    .foregroundColor(.black)
                Text("Review suspect")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.black)
                Spacer()
                Button(action: {
                    isShowPerson.toggle()
                }, label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .rotationEffect(isShowPerson == true ? .degrees(90) : .degrees(0))
                })
            }
            
            if isShowPerson {
                KFImage(URL(string: alert.photoUrl))
                    .resizable()
                    .fade(duration: 0.3)
                    .placeholder {
                        ProgressView().tint(.white)
                    }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .overlay(RoundedRectangle(cornerRadius: 10)
            .stroke(Color.gray.opacity(0.3), lineWidth: 1))
    }
    
    private func actionButton() -> some View {
        HStack(spacing: 12) {
            if currentStatus != false {
                Button(action: {
                    handleConfirm()
                }, label: {
                    Text(currentStatus == true ? "Confirmed" : "Confirm")
                        .padding(.vertical, 12)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .background(isProcessing || currentStatus == true ? Color.gray : Color.charcoal)
                        .cornerRadius(10)
                })
                .disabled(isProcessing || currentStatus == true)
            }
            
            if currentStatus != true {
                Button(action: {
                    handleIgnore()
                }, label: {
                    Text(currentStatus == false ? "Ignored" : "Ignore")
                        .padding(.vertical, 12)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(isProcessing || currentStatus == false ? Color.gray : Color.red)
                        .frame(maxWidth: .infinity)
                        .cornerRadius(10)
                        .background(isProcessing || currentStatus == false ? Color.gray.opacity(0.1) : Color.red.opacity(0.05))
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(isProcessing || currentStatus == false ? Color.gray : Color.red, lineWidth: 0.8)
                        )
                })
                .disabled(isProcessing || currentStatus == false)
            }
        }
        .padding(.top, 8)
    }
    
    private func setupVideoPlayer() {
        let videoURLString = alert.videoUrl
        
        if let url = URL(string: videoURLString) {
            player = AVPlayer(url: url)
            player?.play()
        }
    }
    
    private func handleConfirm() {
        Task {
            isProcessing = true
            do {
                try await alertService.updateAlertStatus(alertId: alert.id, isValid: true)
                print("✅ Alert confirmed successfully")
                stateManager.updateAlertStatus(alertId: alert.id, isValid: true)
                onStatusUpdated?()
            } catch {
                print("❌ Error confirming alert: \(error.localizedDescription)")
            }
            isProcessing = false
        }
    }
    
    private func handleIgnore() {
        Task {
            isProcessing = true
            do {
                try await alertService.updateAlertStatus(alertId: alert.id, isValid: false)
                print("✅ Alert ignored successfully")
                stateManager.updateAlertStatus(alertId: alert.id, isValid: false)
                onStatusUpdated?()
            } catch {
                print("❌ Error ignoring alert: \(error.localizedDescription)")
            }
            isProcessing = false
        }
    }
}

#Preview {
    AlertCard(alert: Alert(
        id: "1",
        title: "Suspicious Behaviour",
        incidentStart: "2025-11-04T05:22:46.938570",
        isValid: nil,
        photoUrl: "https://example.com/photo.jpg",
        videoUrl: "shoplifting_track5_20251104_122246",
        notes: nil,
        cameraName: "Cam 01",
        aisleLoc: "Aisle 1",
        updatedBy: "ferdy"
    ))
}
