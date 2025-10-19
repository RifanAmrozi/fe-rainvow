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
    @State private var webRTCURL: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Camera Details")) {
                    TextField("Camera Name", text: $name)
                    TextField("WebRTC URL", text: $webRTCURL)
                }
                
                Section {
                    Button("Add Camera") {
                        viewModel.addCamera(name: name, webRTCURL: webRTCURL)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .navigationTitle("Add New Camera")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
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
