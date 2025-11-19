//
//  AlertListView.swift
//  Octrum
//
//  Created by Marcelinus Gerardo on 03/11/25.
//

import SwiftUI

struct AlertListView: View {
    @StateObject private var viewModel = AlertViewModel()
    @ObservedObject private var userViewModel = UserViewModel.shared
    @EnvironmentObject var webSocketManager: WebSocketManager
    
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
            
            LocationCard(store: userViewModel.store)
            
            alertListView
        }
        .background(themeBackground())
        .onAppear {
            userViewModel.fetchDataOnce()
            if viewModel.alerts.isEmpty && !viewModel.isLoading {
                print("🔵 First launch: fetching initial alerts")
                viewModel.fetchAlerts()
            }
        }
    }
    
    private var alertListView: some View {
        
        ScrollView {
            DisclaimerCard(
                title: viewModel.emptyStateTitle,
                message: viewModel.emptyStateMessage
            )
            .padding(.horizontal)
            .padding(.top)
            
            if viewModel.alerts.isEmpty {
                Text("")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
            } else {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.alerts) { alert in
                        AlertCard(alert: alert)
                    }
                }
                .padding(.top, 8)
                .padding(.bottom, 20)
            }
        }
        .refreshable {
            await viewModel.refreshAlerts()
        }
        
    }
}

#Preview {
    AlertListView()
        .environmentObject(WebSocketManager())
}
