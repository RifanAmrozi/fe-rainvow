//
//  AlertDetailView.swift
//  Octrum
//
//  Created on 12/11/25.
//

import SwiftUI
import AVKit

struct AlertDetailView: View {
    let alertId: String
    
    @StateObject private var viewModel: AlertDetailViewModel
    @ObservedObject private var userViewModel = UserViewModel.shared
    @Environment(\.dismiss) var dismiss
    @State private var player: AVPlayer?
    
    init(alertId: String) {
        self.alertId = alertId
        _viewModel = StateObject(wrappedValue: AlertDetailViewModel(alertId: alertId))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // ----------------- Location -----------------
            LocationCard(store: userViewModel.store)
            
            // ----------------- Body -----------------
            ZStack {
                if viewModel.isLoading {
                    loadingView
                } else if let error = viewModel.errorMessage {
                    errorView(message: error)
                } else if let alertDetail = viewModel.alertDetail {
                    contentView(alertDetail: alertDetail)
                }
            }
            .navigationTitle("Alert Detail")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await viewModel.fetchAlertDetail()
            }
            .onChange(of: viewModel.alertDetail) { alertDetail in
                if let alertDetail = alertDetail {
                    setupVideoPlayer(videoUrl: alertDetail.videoUrl)
                }
            }
            
            Spacer()
        }
        .background(themeBackground())
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading alert details...")
                .font(.system(size: 16))
                .foregroundColor(.gray)
        }
    }
    
    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            
            Text(message)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
            
            Button("Try Again") {
                Task {
                    await viewModel.fetchAlertDetail()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    private func contentView(alertDetail: AlertDetailResponse) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                // ----------------- Video Player -----------------
                if let player = player {
                    VideoPlayer(player: player)
                        .aspectRatio(16/9, contentMode: .fit)
                        .cornerRadius(12)
                        .padding(.top, 12)
                        .padding(.horizontal)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .aspectRatio(16/9, contentMode: .fit)
                        .cornerRadius(12)
                        .overlay(
                            VStack(spacing: 8) {
                                ProgressView()
                                Text("Loading video...")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                            }
                        )
                        .padding(.top, 12)
                        .padding(.horizontal)
                }
                
                // ----------------- Info -----------------
                VStack(alignment: .leading, spacing: 4) {
                    Text("Camera & Location")
                        .font(.system(size: 14, weight: .bold))
                    
                    Text("\(alertDetail.cameraName) - \(alertDetail.aisleLoc)")
                        .font(.system(size: 14, weight: .regular))
                    
                    Divider()
                        .background(.gray.opacity(0.4))
                        .padding(.vertical, 4)
                    
                    Text("\(alertDetail.title)")
                        .font(.system(size: 14, weight: .bold))
                    
                    Text("\(alertDetail.formattedTimestamp)")
                        .font(.system(size: 14, weight: .regular))
                    
                    Divider()
                        .background(.gray.opacity(0.4))
                        .padding(.vertical, 4)
                    
                    Text("Decision")
                        .font(.system(size: 14, weight: .bold))
                    
                    Text("Confirmed by User")
                        .font(.system(size: 14, weight: .regular))
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.white)
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1))
                .padding(.horizontal)
                
                // ----------------- Notes -----------------
                if let notes = alertDetail.notes, !notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Notes")
                            .font(.system(size: 14, weight: .bold))
                        
                        Text(notes)
                            .font(.system(size: 14, weight: .regular))
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.bluishGray)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1))
                    .padding(.horizontal)
                }
                
                // ----------------- Action Button -----------------
                if alertDetail.isValid == nil && !viewModel.isUpdated {
                    actionButtons
                        .padding(.horizontal)
                }
            }
        }
    }
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button(action: {
                Task {
                    await viewModel.confirmAlert()
                }
            }, label: {
                HStack {
                    if viewModel.isProcessing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    }
                    Text(viewModel.isProcessing ? "Processing..." : "Confirm Alert")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(viewModel.isProcessing ? Color.gray : Color.charcoal)
                .cornerRadius(10)
            })
            .disabled(viewModel.isProcessing)
            
            Button(action: {
                Task {
                    await viewModel.ignoreAlert()
                }
            }, label: {
                Text("Ignore Alert")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.red, lineWidth: 2)
                    )
            })
            .disabled(viewModel.isProcessing)
        }
    }
    
    private var statusBackgroundColor: Color {
        switch viewModel.statusColor {
        case "green":
            return Color.green
        case "red":
            return Color.red
        default:
            return Color.orange
        }
    }
    
    private func setupVideoPlayer(videoUrl: String) {
        guard let url = URL(string: videoUrl) else {
            print("❌ Invalid video URL: \(videoUrl)")
            return
        }
        
        print("🎥 Setting up video player with URL: \(videoUrl)")
        player = AVPlayer(url: url)
        player?.play()
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.gray)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)
                
                Text(value)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.black)
            }
            
            Spacer()
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(8)
    }
}

#Preview {
    NavigationStack {
        AlertDetailView(alertId: "a800cf9d-d40e-477a-8dbd-78a64ec3d4f1")
    }
}
