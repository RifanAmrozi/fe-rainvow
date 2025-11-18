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
            
            contentView
        }
        .background(themeBackground())
        .onAppear {
            userViewModel.fetchDataOnce()
            if viewModel.alerts.isEmpty && !viewModel.isLoading {
                print("🔵 First launch: fetching initial alerts")
                viewModel.fetchAlerts()
            }
        }
        .onChange(of: webSocketManager.newAlertReceived) { newValue in
            if newValue {
                print("📨 New alert received via WebSocket, refreshing alerts...")
                viewModel.fetchAlerts()
            }
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        if viewModel.isLoading {
            loadingView
        } else if let errorMessage = viewModel.errorMessage {
            errorView(message: errorMessage)
        } else if viewModel.alerts.isEmpty {
            errorView(message: "")
        } else {
            alertListView
        }
    }
    
    private var loadingView: some View {
        VStack {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.black)
            Spacer()
        }
    }
    
    private func errorView(message: String) -> some View {
        VStack {
            Spacer()
            VStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 48))
                    .foregroundColor(.blue)
                
                Text("Error loading alerts")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(message)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 24)
                
                Button(action: {
                    viewModel.fetchAlerts()
                }, label: {
                    Text("Try Again")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.charcoal)
                        .cornerRadius(8)
                })
            }
            .padding()
            Spacer()
        }
    }
    
    //    private var emptyStateView: some View {
    //        VStack {
    //            DisclaimerCard(
    //                title: viewModel.emptyStateTitle,
    //                message: viewModel.emptyStateMessage
    //            )
    //            .padding()
    //            Spacer()
    //        }
    //    }
    
    private var alertListView: some View {
        
        ScrollView {
            LazyVStack(spacing: 16) {
                DisclaimerCard(
                    title: viewModel.emptyStateTitle,
                    message: viewModel.emptyStateMessage
                )
                .padding(.horizontal)
                
                ForEach(viewModel.alerts) { alert in
                    AlertCard(alert: alert)
                }
            }
            .padding(.top, 16)
            .padding(.bottom, 20)
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
