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
            Image(systemName: isConnected ? "wifi" : (isConnecting ? "circle.dashed" : "wifi.exclamationmark"))
                .font(.system(size: 12))
            
            Text(isConnected ? "LIVE" : (isConnecting ? "CONNECTING" : "OFFLINE"))
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .foregroundStyle(Color.white)
        .background(isConnected||isConnecting ? Color.blue : Color.gray)
        .cornerRadius(5)
    }
}
