//
//  AlertHistoryView.swift
//  Octrum
//
//  Created by Marcelinus Gerardo on 03/11/25.
//

import SwiftUI

struct AlertHistoryView: View {
    @StateObject private var userViewModel = UserViewModel()
    @StateObject private var alertHistoryViewModel = AlertHistoryViewModel()
    @State private var selectedTab = "true"
    
    var body: some View {
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
            
            Picker("Tabs", selection: $selectedTab) {
                Text("Ignored").tag("false")
                Text("Confirmed").tag("true")
            }
            .pickerStyle(SegmentedPickerStyle())
            .scaleEffect(y: 1.2)
            .padding(.vertical, 4)
            .padding(.bottom, 1)
            .padding(.horizontal, 1)
            .background(Color.charcoal.opacity(0.1))
            .cornerRadius(9)
            .overlay(
                RoundedRectangle(cornerRadius: 9).stroke(Color.charcoal, lineWidth: 1)
            )
            .padding()
            
            // Alert History List
            ScrollView {
                LazyVStack(spacing: 12) {
                    if selectedTab == "true" {
                        // Confirmed Alerts
                        if alertHistoryViewModel.isLoadingConfirmed {
                            ProgressView()
                                .padding()
                        } else if alertHistoryViewModel.confirmedAlerts.isEmpty {
                            Text("No confirmed alerts")
                                .foregroundColor(.gray)
                                .padding()
                        } else {
                            ForEach(alertHistoryViewModel.confirmedAlerts) { alert in
                                AlertHistoryCard(alert: alert)
                            }
                        }
                    } else {
                        // Ignored Alerts
                        if alertHistoryViewModel.isLoadingIgnored {
                            ProgressView()
                                .padding()
                        } else if alertHistoryViewModel.ignoredAlerts.isEmpty {
                            Text("No ignored alerts")
                                .foregroundColor(.gray)
                                .padding()
                        } else {
                            ForEach(alertHistoryViewModel.ignoredAlerts) { alert in
                                AlertHistoryCard(alert: alert)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .background(themeBackground())
        .onAppear {
            userViewModel.fetchUserProfile()
            alertHistoryViewModel.fetchAlerts()
        }
    }
}

#Preview {
    AlertHistoryView()
}
