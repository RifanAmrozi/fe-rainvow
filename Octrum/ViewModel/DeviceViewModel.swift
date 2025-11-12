//
//  DeviceViewModel.swift
//  Octrum
//
//  Created by Marcelinus Gerardo on 11/11/25.
//

import Foundation
import Combine

// MARK: - Device ViewModel
// ✅ MVVM Pattern untuk handle device registration

@MainActor
class DeviceViewModel: ObservableObject {
    private let deviceService: DeviceService
    private let notificationManager: NotificationManager
    private var cancellables = Set<AnyCancellable>()
    
    @Published var isRegistering: Bool = false
    @Published var registrationError: String?
    
    init(
        deviceService: DeviceService = DeviceService(),
        notificationManager: NotificationManager = NotificationManager.shared
    ) {
        self.deviceService = deviceService
        self.notificationManager = notificationManager
        
        // Listen to APNs device token
        setupDeviceTokenListener()
    }
    
    private func setupDeviceTokenListener() {
        NotificationCenter.default.publisher(for: NSNotification.Name("APNsDeviceTokenReceived"))
            .compactMap { $0.object as? String }
            .sink { [weak self] deviceToken in
                print("🔔 Device token received in DeviceViewModel: \(deviceToken)")
            }
            .store(in: &cancellables)
    }
    
    func registerDeviceAfterLogin(userId: String, storeId: String) {
        guard let deviceToken = notificationManager.deviceToken else {
            print("⚠️ Device token not ready. Registration will occur.")
            scheduleDelayedRegistration(userId: userId, storeId: storeId)
            return
        }
        
        Task {
            await registerDevice(userId: userId, storeId: storeId, deviceToken: deviceToken)
        }
    }
    
    private func scheduleDelayedRegistration(userId: String, storeId: String) {
        NotificationCenter.default.publisher(for: NSNotification.Name("APNsDeviceTokenReceived"))
            .compactMap { $0.object as? String }
            .timeout(.seconds(5), scheduler: DispatchQueue.main)
            .first()
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        print("⏱️ Timeout waiting for device token")
                    }
                },
                receiveValue: { [weak self] deviceToken in
                    print("✅ Device token ready, registering now...")
                    Task {
                        await self?.registerDevice(userId: userId, storeId: storeId, deviceToken: deviceToken)
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    private func registerDevice(userId: String, storeId: String, deviceToken: String) async {
        isRegistering = true
        registrationError = nil
        
        do {
            try await deviceService.registerDevice(
                userId: userId,
                storeId: storeId,
                deviceToken: deviceToken
            )
            print("✅ Device registered successfully")
        } catch {
            registrationError = error.localizedDescription
            print("❌ Error registering device: \(error.localizedDescription)")
        }
        
        isRegistering = false
    }
}
