//
//  FilterCamView.swift
//  Octrum
//
//  Created on 24/11/25.
//

import SwiftUI

struct FilterCamView: View {
    @StateObject private var viewModel = FilterViewModel()
    @ObservedObject private var userViewModel = UserViewModel.shared
    @Environment(\.presentationMode) var presentationMode
    
    var currentFilter: String? = nil
    var onFilterApply: ((String?) -> Void)?
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("CCTV Location")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        // Only show reset button when there's a selected location
                        if viewModel.selectedAisleLocation != nil {
                            Button(action: {
                                resetFilter()
                            }, label: {
                                Text("Reset Filter")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(.red)
                            })
                        }
                    }
                    
                    if viewModel.isLoading {
                        HStack {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .tint(.black)
                            Text("Loading locations...")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                        )
                    } else if viewModel.aisleLocations.isEmpty {
                        Text("No locations available")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(12)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                            )
                    } else {
                        Menu {
                            Button(action: {
                                viewModel.selectedAisleLocation = nil
                            }, label: {
                                HStack {
                                    Text("All Locations")
                                    if viewModel.selectedAisleLocation == nil {
                                        Spacer()
                                        Image(systemName: "checkmark")
                                    }
                                }
                            })
                            
                            Divider()
                            
                            ForEach(viewModel.aisleLocations, id: \.self) { location in
                                Button(action: {
                                    viewModel.selectedAisleLocation = location
                                }, label: {
                                    HStack {
                                        Text(location)
                                        if viewModel.selectedAisleLocation == location {
                                            Spacer()
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                })
                            }
                        } label: {
                            HStack {
                                Text(viewModel.selectedAisleLocation ?? "Select location...")
                                    .foregroundColor(viewModel.selectedAisleLocation == nil ? .gray : .primary)
                                    .font(.system(size: 16))
                                
                                Spacer()
                                
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 14))
                            }
                            .padding(12)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                            )
                        }
                    }
                    
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 12))
                            .foregroundColor(.red)
                            .padding(.top, 4)
                    }
                }
                
                Spacer()
                
                Button(action: {
                    applyFilter()
                }, label: {
                    Text("Apply Filter")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.charcoal)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                })
                .padding(.bottom, 12)
            }
            .padding(.top, 16)
            .padding(.horizontal, 16)
            .navigationTitle("Filter CCTV")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.white, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.light, for: .navigationBar)
            .tint(.blue)
            .background(.white)
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .onAppear {
            // Set current filter to viewModel if exists
            viewModel.selectedAisleLocation = currentFilter
            
            if let storeId = userViewModel.store?.id {
                viewModel.fetchAisleLocations(storeId: storeId)
            }
        }
    }
    
    private func applyFilter() {
        let selectedLocation = viewModel.applyFilter()
        presentationMode.wrappedValue.dismiss()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onFilterApply?(selectedLocation)
        }
    }
    
    private func resetFilter() {
        viewModel.resetFilter()
        presentationMode.wrappedValue.dismiss()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onFilterApply?(nil)
        }
    }
}

struct FilterCamView_Previews: PreviewProvider {
    static var previews: some View {
        FilterCamView()
    }
}
