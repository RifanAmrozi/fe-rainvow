//
//  MainView.swift
//  Octrum
//
//  Created by Marcelinus Gerardo on 17/10/25.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var session: SessionManager
    
    init() {
        UITabBar.appearance().backgroundColor = UIColor.white
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
                    .tabItem {
                        Image(systemName: "bell.fill")
                        Text("Alerts")
                    }
                
                AlertHistoryView()
                    .tabItem {
                        Image(systemName: "clock.fill")
                        Text("History")
                    }
            }
            .tint(.blue)
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
