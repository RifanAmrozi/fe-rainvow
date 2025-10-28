//
//  CamListView.swift
//  Octrum
//
//  Created by Marcelinus Gerardo on 17/10/25.
//

import SwiftUI

struct CamListView: View {
    @EnvironmentObject var viewModel: CameraViewModel
    @StateObject private var userViewModel = UserViewModel()
    @State private var isAddingCamera = false
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                GeometryReader { geo in
                    Color.charcoal
                        .frame(height: geo.safeAreaInsets.top)
                        .ignoresSafeArea(edges: .top)
                }
                
                VStack(spacing: 0) {
                    // ----------------- Profile -----------------
                    HStack(spacing: 16) {
                        Image("")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 45, height: 45)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 1))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Rock the shift, ")
                                .font(.system(size: 16, weight: .regular))
                            + Text(userViewModel.userProfile?.username.capitalized ?? "  ")
                                .font(.system(size: 16, weight: .bold))
                            + Text("!")
                            
                            Text(userViewModel.userProfile?.role.capitalized ?? "  ")
                                .font(.system(size: 12, weight: .regular))
                                .padding(.vertical, 4)
                                .padding(.horizontal, 6)
                                .background(Color.blue.opacity(0.5))
                                .cornerRadius(4)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(Color.blue, lineWidth: 1)
                                )
                        }
                        
                        Spacer()
                        
                        Image(systemName: "line.3.horizontal.decrease")
                            .font(.title2)
                        
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 12)
                    .background(Color.charcoal)
                    .foregroundColor(.white)
                    
            // ----------------- Location -----------------
            LocationCard(store: userViewModel.store)
                    
                    // ----------------- Camera List -----------------
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(viewModel.cameras) { camera in
                                NavigationLink(destination: CamVideoView(camera: camera)) {
                                    ZStack(alignment: .bottomLeading) {
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color.gray.opacity(0.3))
                                            .aspectRatio(1, contentMode: .fit)
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(camera.name)
                                                .font(.system(size: 16, weight: .regular))
                                                .foregroundColor(.white)
                                                .lineLimit(1)
                                            
                                            Text(camera.aisleLoc)
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundColor(.white)
                                                .lineLimit(1)
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.bottom, 16)
                                    }
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 8)
                        
                        Button(action: {
                            isAddingCamera = true
                        }, label: {
                            HStack(spacing: 12) {
                                Image(systemName: "plus")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("Add CCTV")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.charcoal)
                            .cornerRadius(10)
                        })
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .padding(.bottom, 80)
                    }
                    .refreshable {
                        await refreshCameras()
                    }
                }
                .background(.gray.opacity(0.2))
                .sheet(isPresented: $isAddingCamera) {
                    AddCamView()
                }
            }
        }
        .tint(.white)
    }
    
    // Refresh List
    private func refreshCameras() async {
        viewModel.fetchCameras()
        try? await Task.sleep(nanoseconds: 500_000_000)
    }
}

struct CamListView_Previews: PreviewProvider {
    static var previews: some View {
        CamListView()
            .environmentObject(CameraViewModel())
    }
}
