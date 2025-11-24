//
//  OctrumApp.swift
//  Octrum
//
//  Created by Marcelinus Gerardo on 17/10/25.
//

import SwiftUI

// Handle APNs callbacks dari iOS
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        NotificationManager.shared.requestAuthorization()
        
        return true
    }
    
    // When token succesfully generated
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        NotificationManager.shared.didRegisterForRemoteNotifications(withDeviceToken: deviceToken)
    }
    
    // When registration failed
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        NotificationManager.shared.didFailToRegisterForRemoteNotifications(withError: error)
    }
    
    // When receive remote notification (from APNs)
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        NotificationManager.shared.didReceiveRemoteNotification(userInfo)
        completionHandler(.newData)
    }
}

@main
struct OctrumApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var session = SessionManager.shared
//    @StateObject private var webSocketManager = WebSocketManager()
    @Environment(\.scenePhase) private var scenePhase
    
    private let notificationManager = NotificationManager.shared
    
    var body: some Scene {
        WindowGroup {
            if session.isLoggedIn {
                MainView()
                    .preferredColorScheme(.light)
                    .environmentObject(session)
//                    .environmentObject(webSocketManager)
//                    .onAppear {
//                        webSocketManager.connect()
//                    }
            } else {
                LoginView()
                    .preferredColorScheme(.light)
                    .environmentObject(session)
            }
        }
//        .onChange(of: scenePhase) { newPhase in
//            switch newPhase {
//            case .active:
//                print("🟢 App is active - WebSocket connected")
//                if session.isLoggedIn && !webSocketManager.isConnected {
//                    webSocketManager.connect()
//                }
//            case .inactive:
//                print("🟡 App is inactive - WebSocket stays connected")
//            case .background:
//                print("🔵 App is in background - WebSocket stays connected")
//            @unknown default:
//                break
//            }
//        }
    }
}
