//
//  CamListView.swift
//  Octrum
//
//  Created by Marcelinus Gerardo on 17/10/25.
//

import SwiftUI

struct CamListView: View {
    @EnvironmentObject var viewModel: CameraViewModel
    @State private var isAddingCamera = false
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            // Camera Cards
                            ForEach(viewModel.cameras) { camera in
                                NavigationLink(destination: CamVideoView(camera: camera)) {
                                    ZStack(alignment: .bottom) {
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color.gray.opacity(0.3))
                                            .aspectRatio(1, contentMode: .fit)
                                        
                                        Image(systemName: "video.fill")
                                            .font(.system(size: 40))
                                            .foregroundColor(.gray.opacity(0.5))
                                        
                                        Text(camera.name)
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.white)
                                            .lineLimit(1)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .frame(maxWidth: .infinity)
                                            .background(Color.black.opacity(0.7))
                                    }
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(16)
                        .padding(.bottom, 100) // Space for bottom button
                    }
                    
                    Spacer()
                    
                    // Add CCTV Button at bottom
                    Button(action: {
                        isAddingCamera = true
                    }, label: {
                        HStack(spacing: 12) {
                            Image(systemName: "plus")
                                .font(.system(size: 20, weight: .semibold))
                            Text("Add CCTV")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.blue)
                        .cornerRadius(16)
                    })
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                    .background(Color(.systemGroupedBackground))
                }
            }
            .navigationTitle("CCTV List")
            .sheet(isPresented: $isAddingCamera) {
                AddCamView()
            }
        }
    }
}

struct CamListView_Previews: PreviewProvider {
    static var previews: some View {
        CamListView()
            .environmentObject(CameraViewModel())
    }
}
