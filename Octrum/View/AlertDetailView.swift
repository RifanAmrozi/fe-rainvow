//
//  AlertDetailView.swift
//  Octrum
//
//  Created on 12/11/25.
//

import SwiftUI
import AVKit
import Kingfisher
import Photos

struct AlertDetailView: View {
    let alertId: String
    let alert: Alert?
    
    @StateObject private var viewModel: AlertDetailViewModel
    @ObservedObject private var userViewModel = UserViewModel.shared
    @ObservedObject private var stateManager = AlertStateManager.shared
    @Environment(\.dismiss) var dismiss
    @State private var player: AVPlayer?
    
    private var currentStatus: Bool? {
        // Prioritas: state manager (local update) > viewModel.alertDetail?.isValid (dari API)
        return stateManager.getAlertStatus(alertId: alertId) ?? viewModel.alertDetail?.isValid
    }
    
    init(alertId: String, alert: Alert? = nil) {
        self.alertId = alertId
        self.alert = alert
        
        _viewModel = StateObject(wrappedValue: AlertDetailViewModel(
            alertId: alertId,
            existingAlert: alert
        ))
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
            .onAppear {
                if let alertDetail = viewModel.alertDetail {
                    setupVideoPlayer(videoUrl: alertDetail.videoUrl)
                }
            }
            .onChange(of: viewModel.alertDetail) { alertDetail in
                if let alertDetail = alertDetail {
                    setupVideoPlayer(videoUrl: alertDetail.videoUrl)
                }
            }
            
            Spacer()
        }
        .background(Color.white)
        .customAlert(
            isPresented: $showDownloadAlert,
            message: downloadMessage,
            isSuccess: downloadSuccess
        )
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
                
                VStack {
                    HStack {
                        Image(systemName: "photo")
                            .font(.system(size: 14))
                            .foregroundColor(.black)
                        Text("The suspect")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.black)
                        Spacer()
                    }
                    
                    KFImage(URL(string: alertDetail.photoUrl))
                        .resizable()
                        .fade(duration: 0.3)
                        .placeholder {
                            ProgressView().tint(.black)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding(16)
                .overlay(RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1))
                .padding(.horizontal)
                
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
                    
                    if alertDetail.isValid==true {
                        Text("Confirmed by \(alertDetail.updatedBy ?? "Unknown").")
                            .font(.system(size: 14, weight: .regular))
                    } else if  alertDetail.isValid==false {
                        Text("Ignored by \(alertDetail.updatedBy ?? "Unknown").")
                            .font(.system(size: 14, weight: .regular))
                    } else {
                        Text("Status pending.")
                            .font(.system(size: 14, weight: .regular))
                    }
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
                actionButtons.padding(.horizontal)
                
                // ----------------- Download Button -----------------
                if let alertDetail = viewModel.alertDetail {
                    downloadButton(videoUrl: alertDetail.videoUrl)
                        .padding(.horizontal)
                        .padding(.bottom)
                        .padding(.top, -2)
                }
            }
        }
        .refreshable {
            await viewModel.refreshAlertDetail()
        }
    }
    
    private var actionButtons: some View {
        HStack(spacing: 12) {
            if currentStatus != false {
                Button(action: {
                    Task {
                        await viewModel.confirmAlert()
                        stateManager.updateAlertStatus(alertId: alertId, isValid: true)
                    }
                }, label: {
                    Text(currentStatus == true ? "Confirmed" : "Confirm")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(viewModel.isProcessing || currentStatus == true ? Color.gray : Color.charcoal)
                        .cornerRadius(10)
                })
                .disabled(viewModel.isProcessing || currentStatus == true)
            }
            
            if currentStatus != true {
                Button(action: {
                    Task {
                        await viewModel.ignoreAlert()
                        stateManager.updateAlertStatus(alertId: alertId, isValid: false)
                    }
                }, label: {
                    Text(currentStatus == false ? "Ignored" : "Ignore")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(viewModel.isProcessing || currentStatus == false ? Color.gray : .red)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(viewModel.isProcessing || currentStatus == false ? Color.gray.opacity(0.1) : Color.red.opacity(0.05))
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(viewModel.isProcessing || currentStatus == false ? Color.gray : Color.red, lineWidth: 0.8)
                        )
                })
                .disabled(viewModel.isProcessing || currentStatus == false)
            }
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
    
    @State private var isDownloading = false
    @State private var downloadSuccess = false
    @State private var showDownloadAlert = false
    @State private var downloadMessage = ""
    
    private func downloadButton(videoUrl: String) -> some View {
        Button(action: {
            Task {
                await downloadVideo(videoUrl: videoUrl)
            }
        }, label: {
            HStack(spacing: 12) {
                Image(systemName: isDownloading ? "square.and.arrow.down.badge.clock" : "square.and.arrow.down")
                    .font(.system(size: 20))
                
                if isDownloading {
                    Text("Downloading...")
                        .font(.system(size: 16, weight: .semibold))
                } else {
                    Text("Download Video")
                        .font(.system(size: 16, weight: .semibold))
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(isDownloading ? Color.gray : Color.charcoal)
            .cornerRadius(10)
        })
        .disabled(isDownloading)
        
    }
    
    private func downloadVideo(videoUrl: String) async {
        isDownloading = true
        
        guard let url = URL(string: videoUrl) else {
            downloadMessage = "Invalid video URL"
            downloadSuccess = false
            showDownloadAlert = true
            isDownloading = false
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("alert_video_\(UUID().uuidString).mp4")
            try data.write(to: tempURL)
            
            try await saveVideoToPhotos(url: tempURL)
            try? FileManager.default.removeItem(at: tempURL)
            
            downloadMessage = "Video saved to Photos successfully!"
            downloadSuccess = true
            showDownloadAlert = true
            
        } catch {
            print("❌ Download error: \(error.localizedDescription)")
            downloadMessage = "Failed to download video. Please try again."
            downloadSuccess = false
            showDownloadAlert = true
        }
        
        isDownloading = false
    }
    
    private func saveVideoToPhotos(url: URL) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
            }) { success, error in
                if success {
                    continuation.resume()
                } else if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: NSError(domain: "PhotoSaveError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error saving to Photos"]))
                }
            }
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
