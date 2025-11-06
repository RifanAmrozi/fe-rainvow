//
//  AlertListView.swift
//  Octrum
//
//  Created by Marcelinus Gerardo on 03/11/25.
//

import SwiftUI

struct AlertListView: View {
    @StateObject private var userViewModel = UserViewModel()
    @StateObject private var alertViewModel = AlertViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Alert")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
            }
            .frame(maxWidth: .infinity, minHeight: 56, maxHeight: 56)
            .padding(.bottom, 11)
            .background(.charcoal)
            
            // ----------------- Location -----------------
            LocationCard(store: userViewModel.store)
            
            // ----------------- Alert List -----------------
            if alertViewModel.isLoading {
                Spacer()
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
                Spacer()
            } else if let errorMessage = alertViewModel.errorMessage {
                Spacer()
                VStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 40))
                        .foregroundColor(.red)
                    Text("Error loading alerts")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    Text(errorMessage)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding()
                Spacer()
            } else if alertViewModel.alerts.isEmpty {
                DisclaimerCard(
                    title: "The alert clip view might be not optimal due to certain conditions:",
                    message: """
                                • Blurry view
                                • The person is too far
                                • The person is too far
                                • The environment is too dark
                                • The person detected is children
                                • Overcrowded
                                """
                )
                .padding()
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(alertViewModel.alerts) { alert in
                            AlertCard(alert: alert)
                        }
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 20)
                }
            }
        }
        .background(themeBackground())
        .onAppear {
            alertViewModel.fetchAlerts()
        }
    }
}

#Preview {
    AlertListView()
}
