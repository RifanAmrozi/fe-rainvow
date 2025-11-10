//
//  AlertCard.swift
//  Octrum
//
//  Created by Marcelinus Gerardo on 06/11/25.
//

import SwiftUI
import AVKit

struct AlertCard: View {
    let alert: Alert
    @State private var player: AVPlayer?
    @State private var isProcessing = false
    @State private var isUpdated = false
    
    private let alertService = AlertService()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Activity Detected!")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.red)
            
            Text(alert.title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.black)
            
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
            
            VStack(alignment: .leading, spacing: 2) {
                Text("\(alert.cameraName) - \(alert.aisleLoc)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                
                Text(alert.formattedTimestamp)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 12) {
                Button(action: {
                    handleConfirm()
                }, label: {
                    Text("Confirm")
                        .padding(.vertical, 12)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .background(isUpdated ? Color.gray : Color.charcoal)
                        .cornerRadius(10)
                })
                .disabled(isProcessing || isUpdated)
                
                Button(action: {
                    handleIgnore()
                }, label: {
                    Text("Ignore")
                        .padding(.vertical, 12)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(isUpdated ? Color.gray : Color.red)
                        .frame(maxWidth: .infinity)
                        .cornerRadius(10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(isUpdated ? Color.gray : Color.red, lineWidth: 2)
                        )
                })
                .disabled(isProcessing || isUpdated)
            }
            .padding(.top, 8)
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
                isUpdated = true
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
                isUpdated = true
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
        videoUrl: "shoplifting_track5_20251104_122246",
        notes: nil,
        cameraName: "Cam 01",
        aisleLoc: "Aisle 1"
    ))
}
