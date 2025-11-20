//
//  AlertHistoryCard.swift
//  Octrum
//
//  Created by Marcelinus Gerardo on 07/11/25.
//

import SwiftUI
import Kingfisher

struct AlertHistoryCard: View {
    let alert: Alert
    
    var body: some View {
        NavigationLink(destination: AlertDetailView(alertId: alert.id, alert: alert)) {
            cardContent
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var cardContent: some View {
        HStack(spacing: 14) {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 100, height: 68)
                .overlay(
                    KFImage(URL(string: alert.photoUrl))
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 68)
                        .clipped()
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            VStack(alignment: .leading, spacing: 2) {
                
                Text("\(alert.cameraName) - \(alert.aisleLoc)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.black)
                
                Text(alert.formattedTimestamp)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.black.opacity(0.5))
                                     
                Spacer()
                
                if alert.isValid==true {
                    Text("Confirmed by \(alert.updatedBy ?? "Unknown").")
                        .font(.system(size: 12))
                        .foregroundColor(.black.opacity(0.5))
                } else if  alert.isValid==false {
                    Text("Ignored by \(alert.updatedBy ?? "Unknown").")
                        .font(.system(size: 12))
                        .foregroundColor(.black.opacity(0.5))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 68, alignment: .leading)
            .padding(.vertical, 2)
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
        photoUrl: "https://example.com/photo.jpg",
        videoUrl: "shoplifting_track5_20251104_122246",
        notes: nil,
        cameraName: "Cam 01",
        aisleLoc: "Aisle 1",
        updatedBy: "ferdy"
    ))
}
