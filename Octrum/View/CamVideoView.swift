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
            LocationCard()
            
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
                    }
                    .padding()
                    
                    Spacer()
                }
            }
            .background(.black)
            .aspectRatio(16/9, contentMode: .fit)
            .cornerRadius(10)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(16)
            
            Spacer()
        }
        .background(.gray.opacity(0.2))
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
    }
}

#if arch(arm64)
struct WebRTCVideoView: UIViewRepresentable {
    let videoTrack: RTCVideoTrack
    
    func makeUIView(context: Context) -> RTCMTLVideoView {
        let view = RTCMTLVideoView()
        view.videoContentMode = .scaleAspectFit
        videoTrack.add(view)
        return view
    }
    
    func updateUIView(_ uiView: RTCMTLVideoView, context: Context) {
        // Left empty. Track is not expected to change.
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
