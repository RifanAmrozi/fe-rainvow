//
//  FullScreenVideoView.swift
//  Octrum
//
//  Created by Marcelinus Gerardo on 28/10/25.
//

import SwiftUI
import WebRTC

struct FullScreenVideoView: View {
    let webRTCManager: WebRTCManager
    let camera: Camera
    @Binding var isPresented: Bool
    @State private var showControls = true
    @State private var controlsTimer: Timer?
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea(.all)
            
            // Video Content
            if webRTCManager.isConnected, let videoTrack = webRTCManager.remoteVideoTrack {
#if arch(arm64)
                WebRTCVideoView(videoTrack: videoTrack)
                    .ignoresSafeArea(.all)
#else
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.orange)
                    Text("WebRTC is not supported on simulator")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text("Please run on a real device")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding()
#endif
            } else {
                VStack(spacing: 20) {
                    if webRTCManager.isConnecting {
                        ProgressView()
                            .scaleEffect(2)
                            .tint(.white)
                        Text("Connecting to camera...")
                            .font(.title2)
                            .foregroundColor(.white)
                    } else {
                        Image(systemName: "video.slash.fill")
                            .font(.system(size: 100))
                            .foregroundColor(.gray)
                        Text("Camera Offline")
                            .font(.title)
                            .foregroundColor(.white)
                        Text("Unable to connect to the stream")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                }
            }
            
            // Controls Overlay
            if showControls {
                VStack {
                    HStack {
                        // Indicators
                        StatusIndicator(
                            isConnected: webRTCManager.isConnected,
                            isConnecting: webRTCManager.isConnecting
                        )
                        
                        Spacer()
                        
                        // Camera Title
                        VStack {
                            Text("CCTV: \(camera.name)")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("Location: \(camera.aisleLoc)")
                                .font(.subheadline)
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        // Status and Refresh
                        HStack(spacing: 8) {
                            if webRTCManager.isConnected {
                                Button(action: {
                                    refreshVideoTrack()
                                }, label: {
                                    Image(systemName: "arrow.clockwise")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                        .padding(8)
                                        .background(Color.black.opacity(0.4))
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.white, lineWidth: 1))
                                })
                            }
                            
                            Button(action: {
                                // Force rotate back to portrait before dismiss
                                AppDelegate.orientationLock = .portrait
                                
                                if #available(iOS 16.0, *) {
                                    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
                                        isPresented = false
                                        return
                                    }
                                    windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
                                } else {
                                    UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
                                }
                                
                                isPresented = false
                            }, label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(Color.black.opacity(0.4))
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.white, lineWidth: 1))
                            })
                        }
                    }
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [Color.black.opacity(0.8), Color.clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 120)
                        .ignoresSafeArea(.container, edges: .top)
                    )
                    
                    Spacer()
                }
                .transition(.opacity.animation(.easeInOut(duration: 0.3)))
            }
        }
        .onTapGesture {
            toggleControls()
        }
        .onAppear {
            // Hide controls after 3 seconds initially
            resetControlsTimer()
            
            // Lock to landscape when this view appears
            AppDelegate.orientationLock = .landscape
            
            // Force rotate to landscape
            if #available(iOS 16.0, *) {
                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
                windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .landscape))
            } else {
                UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
            }
        }
        .onDisappear {
            // Return to portrait when dismissed
            AppDelegate.orientationLock = .portrait
            
            // Force rotate back to portrait
            if #available(iOS 16.0, *) {
                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
                windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
            } else {
                UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            }
        }
        .statusBarHidden(!showControls)
        .preferredColorScheme(.dark)
    }
    
    private func toggleControls() {
        withAnimation(.easeInOut(duration: 0.3)) {
            showControls.toggle()
        }
        
        if showControls {
            resetControlsTimer()
        }
    }
    
    private func resetControlsTimer() {
        controlsTimer?.invalidate()
        controlsTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
            withAnimation(.easeInOut(duration: 0.3)) {
                showControls = false
            }
        }
    }
    
    private func refreshVideoTrack() {
        print("🔄 Fullscreen manual refresh triggered")
        webRTCManager.refreshVideoTrack()
        resetControlsTimer() // Reset timer when user interacts
    }
}

#Preview {
    FullScreenVideoView(
        webRTCManager: WebRTCManager(),
        camera: Camera(
            id: "sample-id",
            name: "Sample Camera",
            aisleLoc: "Front Gate",
            previewImg: nil,
            rtspUrl: "rtsp://192.168.0.10:554/stream",
            webrtcUrl: "http://172.20.10.5:8889/example/whep",
            status: true,
            storeId: "store-id"
        ),
        isPresented: .constant(true)
    )}
