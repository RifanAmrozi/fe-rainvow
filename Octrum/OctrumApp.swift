//
//  OctrumApp.swift
//  Octrum
//
//  Created by Marcelinus Gerardo on 17/10/25.
//

import SwiftUI

@main
struct OctrumApp: App {
    @StateObject private var session = SessionManager.shared
    @StateObject private var webSocketManager = WebSocketManager()
    @Environment(\.scenePhase) private var scenePhase
    
    private let notificationManager = NotificationManager.shared
    
    init() {
        NotificationManager.shared.requestAuthorization()
    }
    
    var body: some Scene {
        WindowGroup {
            if session.isLoggedIn {
                MainView()
                    .environmentObject(session)
                    .environmentObject(webSocketManager)
                    .onAppear {
                        webSocketManager.connect()
                    }
            } else {
                LoginView()
                    .environmentObject(session)
            }
        }
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .active:
                print("🟢 App is active - WebSocket connected")
                if session.isLoggedIn && !webSocketManager.isConnected {
                    webSocketManager.connect()
                }
            case .inactive:
                print("🟡 App is inactive - WebSocket stays connected")
            case .background:
                print("🔵 App is in background - WebSocket stays connected")
            @unknown default:
                break
            }
        }
    }
}
