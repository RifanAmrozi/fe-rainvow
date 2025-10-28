//
//  LocationCard.swift
//  Octrum
//
//  Created by Marcelinus Gerardo on 24/10/25.
//

import SwiftUI

struct LocationCard: View {
    let store: Store?
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(store?.storeName ?? "")
                    .font(.system(size: 14, weight: .medium))
                    .lineLimit(1)
                Text(store?.storeAddress ?? "")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right.circle")
                .foregroundColor(Color.blue)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.white)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray, lineWidth: 1)
        )
        .padding(.horizontal, 16)
        .background(VStack(spacing: 0) {
            Color.charcoal
            Color.clear
        })
    }
}
