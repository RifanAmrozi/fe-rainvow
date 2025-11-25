//
//  CamListView.swift
//  Octrum
//
//  Created by Marcelinus Gerardo on 17/10/25.
//

import SwiftUI

struct CamListView: View {
    @StateObject private var viewModel = CameraViewModel()
    @ObservedObject private var userViewModel = UserViewModel.shared
    
    @State private var isAddingCamera = false
    @State private var isShowingFilter = false
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isAlertSuccess = false
    
    // Dynamic columns based on device type
    var columns: [GridItem] {
        let columnCount = UIDevice.current.userInterfaceIdiom == .pad ? 5 : 2
        return Array(repeating: GridItem(.flexible(), spacing: 16), count: columnCount)
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                GeometryReader { geo in
                    Color.charcoal
                        .frame(height: geo.safeAreaInsets.top)
                        .ignoresSafeArea(edges: .top)
                }
                
                VStack(spacing: 0) {
                    // ----------------- Profile -----------------
                    profileHeaderView
                    
                    // ----------------- Location -----------------
                    LocationCard(store: userViewModel.store)
                    
                    // ----------------- Camera List -----------------
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Integrated CCTV: \(viewModel.totalCameras)")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.black)
                                .lineLimit(1)
                            
                            let filterLocation = viewModel.filteredAisleLocation ?? "All Locations"
                            HStack(spacing: 4) {
                                Text(filterLocation)
                                    .font(.system(size: 11, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                            .background(Color.blue)
                            .cornerRadius(12)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            isAddingCamera = true
                        }, label: {
                            HStack(spacing: 8) {
                                Image(systemName: "plus")
                                    .font(.system(size: 12, weight: .semibold))
                                Text("Add CCTV")
                                    .font(.system(size: 12, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 18)
                            .background(Color.charcoal)
                            .cornerRadius(5)
                        })
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    
                    ScrollView {
                        if viewModel.cameras.isEmpty {
                            DisclaimerCard(
                                title: viewModel.emptyStateTitle,
                                message: viewModel.emptyStateMessage
                            )
                            .padding(.horizontal)
                            .padding(.top, 1)
                            .padding(.bottom, 8)
                        } else {
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(viewModel.cameras) { camera in
                                    NavigationLink(destination: CamVideoView(camera: camera)) {
                                        ZStack(alignment: .bottomLeading) {
                                            Image("Isle")
                                                .resizable()
                                                .scaledToFill()
                                                .aspectRatio(1, contentMode: .fit)
                                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                                .overlay(
                                                    LinearGradient(
                                                        gradient: Gradient(colors: [Color.black.opacity(0.6), Color.black.opacity(0)]),
                                                        startPoint: .bottom,
                                                        endPoint: .top
                                                    )
                                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                                )
                                            
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
                            .padding(.top, 1)
                            .padding(.bottom, 8)
                        }
                    }
                    .refreshable {
                        await refreshCameras()
                    }
                }
                .background(themeBackground())
                .sheet(isPresented: $isAddingCamera) {
                    AddCamView { success, message in
                        alertMessage = message
                        isAlertSuccess = success
                        showAlert = true
                    }
                    .environmentObject(viewModel)
                }
                .sheet(isPresented: $isShowingFilter) {
                    FilterCamView(currentFilter: viewModel.filteredAisleLocation) { selectedLocation in
                        viewModel.setFilter(aisleLocation: selectedLocation)
                    }
                }
            }
        }
        .tint(.white)
        .customAlert(
            isPresented: $showAlert,
            message: alertMessage,
            isSuccess: isAlertSuccess
        )
        .onAppear {
            userViewModel.fetchDataOnce()
            if viewModel.cameras.isEmpty && !viewModel.isLoading {
                print("🔵 First launch: fetching initial cameras")
                viewModel.fetchCameras()
            }
        }
    }
    
    // Profile
    private var profileHeaderView: some View {
        HStack(spacing: 16) {
            NavigationLink(destination: ProfileView()) {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 45, height: 45)
                    .foregroundColor(.white.opacity(0.8))
                    .clipShape(Circle())
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Rock the shift, ")
                    .font(.system(size: 16, weight: .regular))
                + Text(userViewModel.userProfile?.username.capitalized ?? "Octrooms")
                    .font(.system(size: 16, weight: .bold))
                + Text("!")
                
                Text(userViewModel.userProfile?.role.capitalized ?? "      ")
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
            
            Button(action: {
                isShowingFilter = true
            }, label: {
                Image("FilterIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
            })
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 12)
        .background(Color.charcoal)
        .foregroundColor(.white)
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
