//
//  StatusIndicator.swift
//  Octrum
//
//  Created by Marcelinus Gerardo on 24/10/25.
//

import SwiftUI

struct StatusIndicator: View {
    let isConnected: Bool
    let isConnecting: Bool
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(isConnected ? Color.green : (isConnecting ? Color.orange : Color.red))
                .frame(width: 8, height: 8)
            Text(isConnected ? "LIVE" : (isConnecting ? "CONNECTING" : "OFFLINE"))
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.black.opacity(0.6))
        .cornerRadius(20)
    }
}
