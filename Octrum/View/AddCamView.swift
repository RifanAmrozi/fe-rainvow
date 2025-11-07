//
//  AddCamView.swift
//  Octrum
//
//  Created by Marcelinus Gerardo on 17/10/25.
//

import SwiftUI

struct AddCamView: View {
    @EnvironmentObject var viewModel: CameraViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var name: String = ""
    @State private var aisleLoc: String = ""
    @State private var rtspUrl: String = ""
    @State private var isLoading: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                
                CustomTextField(
                    label: "CCTV Name",
                    placeholder: "Cam 01",
                    text: $name,
                    isDisabled: isLoading
                )
                
                Spacer().frame(height: 16)
                
                CustomTextField(
                    label: "Location",
                    placeholder: "Front Gate",
                    text: $aisleLoc,
                    isDisabled: isLoading
                )
                
                Spacer().frame(height: 16)
                
                CustomTextField(
                    label: "RTSP Url",
                    placeholder: "rtsp://xx.xx.xx.xx:xxxx/stream",
                    text: $rtspUrl,
                    isDisabled: isLoading,
                    autocapitalization: .never
                )
                
                Spacer().frame(height: 32)
                
                Button(action: {
                    saveCamera()
                }, label: {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                .scaleEffect(1.5)
                        }
                        Text(isLoading ? "Saving..." : "Save")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(isLoading ? Color.gray : Color.charcoal)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                })
                .disabled(isLoading || name.isEmpty || aisleLoc.isEmpty || rtspUrl.isEmpty)
                
                Spacer()
            }
            .padding(.top, 16)
            .padding(.horizontal, 16)
            .navigationTitle("Add CCTV")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.white, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.light, for: .navigationBar)
            .tint(.blue)
            .alert("Add Camera", isPresented: $showAlert) {
                Button("OK", role: .cancel) {
                    if alertMessage.contains("success") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
    
    private func saveCamera() {
        isLoading = true
        
        viewModel.addCamera(name: name, aisleLoc: aisleLoc, rtspUrl: rtspUrl) { success in
            isLoading = false
            if success {
                alertMessage = "Camera added successfully!"
                showAlert = true
            } else {
                alertMessage = "Failed to add camera. Please try again."
                showAlert = true
            }
        }
    }
}

struct AddCamView_Previews: PreviewProvider {
    static var previews: some View {
        AddCamView()
            .environmentObject(CameraViewModel())
    }
}
