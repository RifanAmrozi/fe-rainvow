//
//  LocationCard.swift
//  Octrum
//
//  Created by Marcelinus Gerardo on 24/10/25.
//

import SwiftUI

struct LocationCard: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Indomaret @ Skyhouse Apartment BSD")
                    .font(.system(size: 14, weight: .medium))
                Text("Store address")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right.circle")
                .foregroundColor(Color.blue)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
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
