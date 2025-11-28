//
//  ProfileView.swift
//  Octrum
//
//  Created by Marcelinus Gerardo on 29/10/25.
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var userViewModel = UserViewModel.shared
    @EnvironmentObject var session: SessionManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var username: String = ""
    @State private var position: String = ""
    
    init() {
        
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
        ZStack {
            themeBackground().ignoresSafeArea()
            
            VStack {
                HStack {}
                    .frame(maxWidth: .infinity, maxHeight: 12)
                    .background(.charcoal)
                    .padding(.bottom, -8)
                
                ZStack {
                    Circle()
                        .foregroundColor(.charcoal)
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.white.opacity(0.8))
                        .overlay(
                            Circle()
                                .stroke(Color.charcoal, lineWidth: 1)
                        )
                }
                .frame(maxWidth: .infinity)
                .background(VStack(spacing: 0) {
                    Color.charcoal
                    Color.clear
                    Color.clear
                })
                .padding(.bottom, 16)
                
                VStack(spacing: 16) {
                    CustomTextField(
                        label: "Username",
                        placeholder: "Loading...",
                        text: $username
                    )
                    
                    CustomTextField(
                        label: String(localized: "Role"),
                        placeholder: "Loading...",
                        text: $position,
                        isDisabled: true,
                        isEditable: false
                    )
                    .onChange(of: position) { newValue in
                        position = newValue.uppercased()
                    }
                }
                .tint(.solidBlue)
                .padding(.horizontal, 16)
                
                Spacer(minLength: 40)
                
                VStack(spacing: 12) {
                    Button(action: {
                        // TODO: Save changes
                    }, label: {
                        Text("Save")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.charcoal)
                            .cornerRadius(10)
                    })
                    
                    Button(action: {
                        session.clearSession()
                    }, label: {
                        Text("Logout")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.flashyRed)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.red.opacity(0.05))
                            .cornerRadius(10)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.flashyRed, lineWidth: 0.8)
                            )
                    })
                }
                .padding(16)
            }
        }
        .navigationTitle("My Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            userViewModel.getUserProfile()
        }
        .onReceive(userViewModel.$userProfile) { profile in
            if let profile = profile {
                username = profile.username
                position = profile.role
            }
        }
    }
}

#Preview {
    ProfileView()
}
