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
    
    var body: some Scene {
        WindowGroup {
            if session.isLoggedIn {
                MainView()
                    .environmentObject(session)
            } else {
                LoginView()
                    .environmentObject(session)
            }
        }
    }
}
