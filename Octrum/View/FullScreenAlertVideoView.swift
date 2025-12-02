//
//  FullScreenAlertVideoView.swift
//  Octrum
//
//  Created on 25/11/25.
//

import SwiftUI
import AVKit

struct FullScreenAlertVideoView: View {
    let videoUrl: String
    @Environment(\.dismiss) var dismiss
    @State private var player: AVPlayer?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.ignoresSafeArea()
                
                if let player = player {
                    VideoPlayer(player: player)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .ignoresSafeArea()
                } else {
                    VStack(spacing: 12) {
                        ProgressView()
                            .tint(.white)
                            .scaleEffect(1.5)
                        Text("Loading video...")
                            .foregroundColor(.white)
                            .font(.system(size: 16))
                    }
                }
                
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            player?.pause()
                            
                            // Force rotate back to portrait before dismiss
                            AppDelegate.orientationLock = .portrait
                            
                            if #available(iOS 16.0, *) {
                                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
                                    dismiss()
                                    return
                                }
                                windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
                            } else {
                                UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
                            }
                            
                            dismiss()
                        }, label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.black.opacity(0.4))
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 1))
                        })
                        .padding(20)
                    }
                    Spacer()
                }
            }
        }
        .statusBarHidden(true)
        .ignoresSafeArea()
        .onAppear {
            setupPlayer()
            
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
            player?.pause()
            player = nil
            
            AppDelegate.orientationLock = .portrait
            
            // Force rotate back to portrait
            if #available(iOS 16.0, *) {
                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
                windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
            } else {
                UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            }
        }
    }
    
    private func setupPlayer() {
        guard let url = URL(string: videoUrl) else {
            print("❌ Invalid video URL: \(videoUrl)")
            return
        }
        
        print("🎥 Setting up fullscreen video player with URL: \(videoUrl)")
        player = AVPlayer(url: url)
        player?.play()
    }
}

#Preview {
    FullScreenAlertVideoView(videoUrl: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")
}
