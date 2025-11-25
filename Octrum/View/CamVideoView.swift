//
//  CamVideoView.swift
//  Octrum
//
//  Created by Marcelinus Gerardo on 17/10/25.
//

import SwiftUI
import WebRTC

struct CamVideoView: View {
    let camera: Camera
    @StateObject private var webRTCManager = WebRTCManager()
    @ObservedObject private var userViewModel = UserViewModel.shared
    @State private var isFullscreen = false
    
    init(camera: Camera) {
        self.camera = camera
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.charcoal
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // ----------------- Location -----------------
            LocationCard(store: userViewModel.store)
            
            // ----------------- Live Streaming -----------------
            ZStack {
                if webRTCManager.isConnected, let videoTrack = webRTCManager.remoteVideoTrack {
#if arch(arm64)
                    WebRTCVideoView(videoTrack: videoTrack)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
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
                                .scaleEffect(1.5)
                                .tint(.white)
                            Text("Connecting to camera...")
                                .font(.headline)
                                .foregroundColor(.white)
                        } else {
                            Image(systemName: "video.slash.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            Text("Camera Offline")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("Unable to connect to the stream")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                // ----------------- Indicator Overlay -----------------
                VStack {
                    HStack {
                        StatusIndicator(
                            isConnected: webRTCManager.isConnected,
                            isConnecting: webRTCManager.isConnecting
                        )
                        
                        Spacer()
                        
                        if webRTCManager.isConnected {
                            Button(action: {
                                isFullscreen = true
                            }, label: {
                                Image(systemName: "arrow.up.left.and.arrow.down.right")
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(4)
                                    .background(Color.black.opacity(0.4))
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.white, lineWidth: 1))
                            })
                        }
                    }
                    .padding(10)
                    
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        if webRTCManager.isConnected {
                            Button(action: {
                                refreshVideoTrack()
                            }, label: {
                                Image(systemName: "arrow.clockwise")
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(4)
                                    .background(Color.black.opacity(0.4))
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.white, lineWidth: 1))
                            })
                        }
                    }
                    .padding(10)
                }
            }
            .background(.black)
            .aspectRatio(16/9, contentMode: .fit)
            .cornerRadius(10)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(16)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Camera & Location")
                    .font(.system(size: 14, weight: .bold))
                
                Text("\(camera.name) - \(camera.aisleLoc)")
                    .font(.system(size: 14, weight: .regular))
                
                Divider()
                    .background(.gray.opacity(0.4))
                    .padding(.vertical, 4)
                
                Text("RTSP URL")
                    .font(.system(size: 14, weight: .bold))
                
                Text("\(camera.rtspUrl)")
                    .font(.system(size: 14, weight: .regular))
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(.black)
            .background(.white)
            .cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1))
            .padding()
            
            Spacer()
            
        }
        .background(themeBackground())
        .navigationTitle("Live")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let webrtcUrl = camera.webrtcUrl, !webrtcUrl.isEmpty {
                webRTCManager.connect(whepURL: webrtcUrl)
            }
        }
        .onDisappear {
            webRTCManager.disconnect()
        }
        .onTapGesture(count: 2) {
            // Double tap to refresh video if black screen
            refreshVideoTrack()
        }
        .fullScreenCover(isPresented: $isFullscreen) {
            FullScreenVideoView(
                webRTCManager: webRTCManager,
                camera: camera,
                isPresented: $isFullscreen
            )
        }
    }
    
    private func refreshVideoTrack() {
        print("🔄 Manual refresh button/gesture triggered")
        webRTCManager.refreshVideoTrack()
    }
}

#if arch(arm64)
struct WebRTCVideoView: UIViewRepresentable {
    let videoTrack: RTCVideoTrack
    @State private var viewId = UUID()
    
    func makeUIView(context: Context) -> RTCMTLVideoView {
        let view = RTCMTLVideoView()
        view.videoContentMode = .scaleAspectFit
        view.backgroundColor = UIColor.black
        
        videoTrack.remove(view)
        videoTrack.isEnabled = true
        
        print("🖥️ Creating new video view - track enabled: \(videoTrack.isEnabled), readyState: \(videoTrack.readyState.rawValue)")
        videoTrack.add(view)
        
        view.setNeedsLayout()
        view.layoutIfNeeded()
        
        DispatchQueue.main.async {
            view.setNeedsDisplay()
            view.layer.setNeedsDisplay()
        }
        
        return view
    }
    
    func updateUIView(_ uiView: RTCMTLVideoView, context: Context) {
        if !videoTrack.isEnabled {
            print("🔄 Re-enabling video track in updateUIView")
            videoTrack.isEnabled = true
        }
        
        videoTrack.remove(uiView)
        videoTrack.add(uiView)
        
        uiView.setNeedsLayout()
        uiView.layoutIfNeeded()
        uiView.setNeedsDisplay()
        uiView.layer.setNeedsDisplay()
        
        print("🔄 Updated video view - track enabled: \(videoTrack.isEnabled), readyState: \(videoTrack.readyState.rawValue)")
    }
}
#endif

struct CamVideoView_Previews: PreviewProvider {
    static var previews: some View {
        CamVideoView(camera: Camera(
            id: "sample-id",
            name: "Sample Camera",
            aisleLoc: "Front Gate",
            previewImg: nil,
            rtspUrl: "rtsp://192.168.0.10:554/stream",
            webrtcUrl: "http://172.20.10.5:8889/example/whep",
            status: true,
            storeId: "store-id"
        ))
    }
}
