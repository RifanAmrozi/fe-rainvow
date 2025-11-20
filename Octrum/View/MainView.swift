//
//  MainView.swift
//  Octrum
//
//  Created by Marcelinus Gerardo on 17/10/25.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var session: SessionManager
    @StateObject var alertViewModel = AlertViewModel()
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        
        appearance.backgroundEffect = UIBlurEffect(style: .systemMaterialLight)
        
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor.systemBlue
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.systemBlue]
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.systemGray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.systemGray]
        
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        NavigationStack {
            TabView {
                CamListView()
                    .tabItem {
                        Image(systemName: "video.fill")
                        Text("CCTV")
                    }
                
                AlertListView()
                    .environmentObject(alertViewModel)
                    .tabItem {
                        Image(systemName: "bell.fill")
                        Text("Alerts")
                    }
                    .badge(alertViewModel.totalAlerts)
                
                AlertHistoryView()
                    .tabItem {
                        Image(systemName: "clock.fill")
                        Text("History")
                    }
            }
            .tint(.blue)
            .onAppear {
                alertViewModel.fetchAlerts()
            }
        }
        .tint(.white)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(SessionManager.shared)
    }
}
