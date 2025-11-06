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
                    // TODO: function
                    print("Confirm tapped for alert: \(alert.id)")
                }, label: {
                    Text("Confirm")
                        .padding(.vertical, 12)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .background(Color.charcoal)
                        .cornerRadius(10)
                })
                
                Button(action: {
                    // TODO: function
                    print("Ignore tapped for alert: \(alert.id)")
                }, label: {
                    Text("Ignore")
                        .padding(.vertical, 12)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color.red)
                        .frame(maxWidth: .infinity)
                        .cornerRadius(10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.red, lineWidth: 2)
                        )
                })
            }
            .padding(.top, 8)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
        .padding(.horizontal)
        .onAppear {
            setupVideoPlayer()
        }
    }
    
    private func setupVideoPlayer() {
        // TODO: Video
        let videoURLString = "http://10.60.60.232:3000/videos/\(alert.videoUrl).mp4"
        
        if let url = URL(string: videoURLString) {
            player = AVPlayer(url: url)
            player?.play()
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
