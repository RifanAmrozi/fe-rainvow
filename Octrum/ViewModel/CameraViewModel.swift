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
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let cameraService = CameraService.shared
    
    init() {
        fetchCameras()
    }
        
    func fetchCameras() {
        isLoading = true
        errorMessage = nil
        
        cameraService.fetchCameras()
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                    print("Error fetching cameras: \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] cameras in
                self?.cameras = cameras
            }
            .store(in: &cancellables)
    }
    
    func addCamera(name: String, aisleLoc: String, rtspUrl: String, completion: @escaping (Bool) -> Void) {
        isLoading = true
        errorMessage = nil
        
        cameraService.createCamera(name: name, aisleLoc: aisleLoc, rtspUrl: rtspUrl)
            .sink { [weak self] completionResult in
                self?.isLoading = false
                if case .failure(let error) = completionResult {
                    self?.errorMessage = error.localizedDescription
                    print("Error creating camera: \(error.localizedDescription)")
                    completion(false)
                }
            } receiveValue: { [weak self] newCamera in
                self?.cameras.append(newCamera)
                completion(true)
            }
            .store(in: &cancellables)
    }
    
    func fetchCamera(id: String) -> AnyPublisher<Camera, Error> {
        return cameraService.fetchCamera(id: id)
    }
    
    func deleteCamera(at offsets: IndexSet) {
        cameras.remove(atOffsets: offsets)
        // TODO: DELETE API (low priority)
    }
}
