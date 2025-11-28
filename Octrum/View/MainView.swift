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
    @State private var selectedTab: Int = 0
    
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
            TabView(selection: $selectedTab) {
                CamListView()
                    .tabItem {
                        Image(systemName: "video.fill")
                        Text("CCTV")
                    }
                    .tag(0)
                
                AlertListView()
                    .environmentObject(alertViewModel)
                    .tabItem {
                        Image(systemName: "bell.fill")
                        Text("Alerts")
                    }
                    .badge(alertViewModel.totalAlerts)
                    .tag(1)
                
                AlertHistoryView()
                    .tabItem {
                        Image(systemName: "clock.fill")
                        Text("History")
                    }
                    .tag(2)
            }
            .tint(.solidBlue)
            .onAppear {
                alertViewModel.fetchAlerts()
                setupNotificationObserver()
            }
            .onDisappear {
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name("SwitchToAlertsTab"), object: nil)
            }
        }
        .tint(.white)
    }
    
    private func setupNotificationObserver() {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("SwitchToAlertsTab"),
            object: nil,
            queue: .main
        ) { _ in
            selectedTab = 1
            print("🔔 Switched to Alerts tab from notification tap")
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(SessionManager.shared)
    }
}
