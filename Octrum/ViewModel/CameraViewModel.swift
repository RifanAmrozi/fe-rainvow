//
//  CameraViewModel.swift
//  Octrum
//
//  Created by Marcelinus Gerardo on 17/10/25.
//

import Foundation
import Combine

@MainActor
public class CameraViewModel: ObservableObject {
    @Published var cameras: [Camera] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var filteredAisleLocation: String? = nil
    
    private var allCameras: [Camera] = []
    private var cancellables = Set<AnyCancellable>()
    private let cameraService: CameraService
    
    init(cameraService: CameraService = CameraService.shared) {
        self.cameraService = cameraService
    }
    
    var emptyStateTitle: String {
        String(
            localized: "camview_empty_state_title",
            defaultValue: "The CCTV list might not be available due to:"
        )
    }
    
    var emptyStateMessage: String {
        String(
            localized: "camview_empty_state_message",
            defaultValue:
            """
            • Different WiFi network with the CCTV
            • Bad internet connection
            """
        )
    }
    
    var totalCameras: Int {
        cameras.count
    }
    
    func fetchCameras() {
        isLoading = true
        errorMessage = nil
        
        cameraService.fetchCameras()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                    print("❌ Error fetching cameras: \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] cameras in
                self?.allCameras = cameras
                self?.applyFilter()
                print("✅ Fetched \(cameras.count) cameras")
            }
            .store(in: &cancellables)
    }
    
    func addCamera(name: String, aisleLoc: String, rtspUrl: String, completion: @escaping (Bool) -> Void) {
        isLoading = true
        errorMessage = nil
        
        cameraService.createCamera(name: name, aisleLoc: aisleLoc, rtspUrl: rtspUrl)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completionResult in
                self?.isLoading = false
                if case .failure(let error) = completionResult {
                    self?.errorMessage = error.localizedDescription
                    print("❌ Error creating camera: \(error.localizedDescription)")
                    completion(false)
                }
            } receiveValue: { [weak self] newCamera in
                self?.allCameras.append(newCamera)
                self?.applyFilter()
                print("✅ Camera added: \(newCamera.name)")
                completion(true)
            }
            .store(in: &cancellables)
    }
    
    func setFilter(aisleLocation: String?) {
        filteredAisleLocation = aisleLocation
        applyFilter()
        
        if let location = aisleLocation {
            print("🔍 Filter applied: \(location) - Showing \(cameras.count) cameras")
        } else {
            print("🔍 Filter cleared - Showing all \(cameras.count) cameras")
        }
    }
    
    private func applyFilter() {
        if let filterLocation = filteredAisleLocation {
            cameras = allCameras.filter { $0.aisleLoc == filterLocation }
        } else {
            cameras = allCameras
        }
    }
    
    func fetchCamera(id: String) -> AnyPublisher<Camera, Error> {
        return cameraService.fetchCamera(id: id)
    }
}
