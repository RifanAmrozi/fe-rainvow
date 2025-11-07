//
//  AlertHistoryCard.swift
//  Octrum
//
//  Created by AI Assistant on 07/11/25.
//

import SwiftUI

struct AlertHistoryCard: View {
    let alert: Alert
    
    var body: some View {
        HStack(spacing: 14) {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 100, height: 68)
                .cornerRadius(10)
                .overlay(
                    Image(systemName: "photo")
                        .foregroundColor(.gray)
                        .font(.system(size: 28))
                )
            
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Image(systemName: "camera.fill")
                    Text("\(alert.cameraName) - Aisle \(alert.aisleLoc)")
                }
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(Color.gray)
                
                Text(alert.title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.black)
                    .lineLimit(2)
                
                Text(alert.formattedTimestamp)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.gray)
                                
                Text("Confirmed by user")
                    .font(.system(size: 12))
                    .foregroundColor(.gray.opacity(0.8))
            }
            .frame(maxWidth: .infinity, maxHeight: 68, alignment: .leading)
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10)
            .stroke(Color.gray.opacity(0.3), lineWidth: 1))
    }
}

#Preview {
    AlertHistoryCard(alert: Alert(
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
