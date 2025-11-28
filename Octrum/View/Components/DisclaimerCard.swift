//
//  DisclaimerCard.swift
//  Octrum
//
//  Created by Marcelinus Gerardo on 29/10/25.
//

import SwiftUI

struct DisclaimerCard: View {
    let title: String
    let message: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "info.circle")
                .foregroundColor(.solidBlue)
                
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    
                Text(message)
                    .font(.system(size: 14, weight: .regular))
            }
            .foregroundColor(.solidBlue)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.lightBlue)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.solidBlue, lineWidth: 1)
        )
        
    }
}

#Preview {
    DisclaimerCard(
        title: "The CCTV list might not be available due to:",
        message: """
            • Different WiFi network with the CCTV
            • Bad internet connection
            """
    )
}
