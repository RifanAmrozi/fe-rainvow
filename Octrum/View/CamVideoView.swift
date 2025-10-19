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

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Video Player Area
                ZStack {
                    Color.black
                    
                    if webRTCManager.isConnected, let videoTrack = webRTCManager.remoteVideoTrack {
                        #if arch(arm64)
                        WebRTCVideoView(videoTrack: videoTrack)
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
                    
                    // Status Indicator Overlay
                    VStack {
                        HStack {
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(webRTCManager.isConnected ? Color.green : (webRTCManager.isConnecting ? Color.orange : Color.red))
                                    .frame(width: 8, height: 8)
                                Text(webRTCManager.isConnected ? "LIVE" : (webRTCManager.isConnecting ? "CONNECTING" : "OFFLINE"))
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(20)
                            
                            Spacer()
                        }
                        .padding()
                        
                        Spacer()
                    }
                }
                .aspectRatio(16/9, contentMode: .fit)
                .cornerRadius(0)
                
                // Camera Info Section
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(camera.name)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        HStack {
                            Image(systemName: "network")
                                .foregroundColor(.secondary)
                            Text(camera.webRTCURL)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    
                    Spacer()
                }
                .padding()
            }
        }
        .navigationTitle("Camera View")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            webRTCManager.connect(whepURL: camera.webRTCURL)
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
        // This can be left empty if the track is not expected to change.
    }
}
#endif

struct CamVideoView_Previews: PreviewProvider {
    static var previews: some View {
        CamVideoView(camera: Camera(id: UUID(), name: "Sample Camera", webRTCURL: "http://172.20.10.5:8889/example/whep"))
    }
}
