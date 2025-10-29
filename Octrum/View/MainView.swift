//
//  MainView.swift
//  Octrum
//
//  Created by Marcelinus Gerardo on 17/10/25.
//

import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = CameraViewModel()
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
                    .environmentObject(viewModel)
                
                Text("Alerts")
                    .tabItem {
                        Image(systemName: "bell.fill")
                        Text("Alerts")
                    }
                
                Text("History")
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
