//
//  AlertHistoryView.swift
//  Octrum
//
//  Created by Marcelinus Gerardo on 03/11/25.
//

import SwiftUI

struct AlertHistoryView: View {
    @StateObject private var userViewModel = UserViewModel()
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                GeometryReader { geo in
                    Color.charcoal
                        .frame(height: geo.safeAreaInsets.top)
                        .ignoresSafeArea(edges: .top)
                }
                
                VStack(spacing: 0) {
                    HStack {
                        Text("History")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        
                    }
                    .frame(maxWidth: .infinity, minHeight: 56, maxHeight: 56)
                    .padding(.bottom, 11)
                    .background(.charcoal)
                    
                    // ----------------- Location -----------------
                    LocationCard(store: userViewModel.store)
                    
                    Spacer()
                }
                .background(themeBackground())
            }
        }
        .tint(.white)
    }
}

#Preview {
    AlertHistoryView()
}
