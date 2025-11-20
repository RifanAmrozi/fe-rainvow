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
    
    // Alert callback
    var onSaveComplete: ((Bool, String) -> Void)?
    
    @State private var name: String = ""
    @State private var aisleLoc: String = ""
    @State private var rtspUrl: String = ""
    @State private var isLoading: Bool = false
    
    var isValidRtspUrl: Bool {
        guard !rtspUrl.isEmpty else { return false }
        
        let lowercased = rtspUrl.lowercased()
        guard lowercased.hasPrefix("rtsp://") || lowercased.hasPrefix("rtsps://") else {
            return false
        }
        
        guard let url = URL(string: rtspUrl) else {
            return false
        }
        
        guard url.host != nil else {
            return false
        }
        
        return true
    }
    
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
                
                if !rtspUrl.isEmpty && !isValidRtspUrl {
                    Text("Invalid RTSP URL format. Must start with rtsp:// or rtsps://")
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                        .padding(.top, 4)
                }
                
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
                    .background(isLoading || !isValidRtspUrl || name.isEmpty || aisleLoc.isEmpty ? Color.gray : Color.charcoal)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                })
                .disabled(isLoading || name.isEmpty || aisleLoc.isEmpty || rtspUrl.isEmpty || !isValidRtspUrl)
                
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
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
    
    private func saveCamera() {
        isLoading = true
        let cameraName = name
        
        viewModel.addCamera(name: name, aisleLoc: aisleLoc, rtspUrl: rtspUrl) { success in
            isLoading = false
            
            presentationMode.wrappedValue.dismiss()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                let message = success
                    ? "\"Cam \(cameraName)\" is successfully added!"
                    : "\"Cam \(cameraName)\" is failed to be added!"
                onSaveComplete?(success, message)
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
