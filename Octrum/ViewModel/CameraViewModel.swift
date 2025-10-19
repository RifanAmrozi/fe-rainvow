//
//  CameraViewModel.swift
//  Octrum
//
//  Created by Marcelinus Gerardo on 17/10/25.
//

import SwiftUI
import Foundation
import Combine

public class CameraViewModel: ObservableObject {
    @Published var cameras: [Camera] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadCameras()
    }
    
    // ------------------- Functions -------------------
    
    func addCamera(name: String, webRTCURL: String) {
        let newCamera = Camera(id: UUID(), name: name, webRTCURL: webRTCURL)
        cameras.append(newCamera)
        saveCameras()
    }
    
    func deleteCamera(at offsets: IndexSet) {
        cameras.remove(atOffsets: offsets)
        saveCameras()
    }
    
    private func saveCameras() {
        if let encoded = try? JSONEncoder().encode(cameras) {
            UserDefaults.standard.set(encoded, forKey: "savedCameras")
        }
    }
    
    private func loadCameras() {
        if let savedCameras = UserDefaults.standard.data(forKey: "savedCameras") {
            if let decodedCameras = try? JSONDecoder().decode([Camera].self, from: savedCameras) {
                self.cameras = decodedCameras
                return
            }
        }
        self.cameras = []
    }
}
