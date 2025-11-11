//
//  WebSocketManager.swift
//  Octrum
//
//  Created by Marcelinus Gerardo on 30/10/25.
//

import Foundation
import Combine
import UIKit

class WebSocketManager: ObservableObject {
    private var webSocketTask: URLSessionWebSocketTask?
    private let urlString = NetworkConfig.webSocketURL
    private let notificationManager = NotificationManager.shared
    private var messageCount = 0
    private var reconnectTimer: Timer?
    private var reconnectAttempts = 0
    private let maxReconnectAttempts = 10
    private var shouldReconnect = true
    private var urlSession: URLSession!
    private var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid
    private var pingTimer: Timer?
    
    @Published var isConnected = false
    @Published var receivedMessages: [String] = []
    
    // Alert trigger
    @Published var newAlertReceived = false
    
    init() {
        // Configure URLSession for background operation
        let configuration = URLSessionConfiguration.default
        configuration.waitsForConnectivity = true
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        self.urlSession = URLSession(configuration: configuration)
        
        // Register for app lifecycle notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    @objc private func appDidEnterBackground() {
        print("🔵 WebSocket: App entering background - starting background task")
        startBackgroundTask()
        startPingTimer()
    }
    
    @objc private func appWillEnterForeground() {
        print("🟢 WebSocket: App entering foreground")
        endBackgroundTask()
        stopPingTimer()
        if !isConnected {
            connect()
        }
    }
    
    private func startBackgroundTask() {
        backgroundTaskID = UIApplication.shared.beginBackgroundTask { [weak self] in
            print("⚠️ Background task expired, ending task")
            self?.endBackgroundTask()
        }
    }
    
    private func endBackgroundTask() {
        if backgroundTaskID != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTaskID)
            backgroundTaskID = .invalid
        }
    }
    
    private func startPingTimer() {
        stopPingTimer()
        // Send ping every 20 seconds to keep connection alive
        pingTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
            self?.sendPing()
        }
        if let pingTimer = pingTimer {
            RunLoop.main.add(pingTimer, forMode: .common)
        }
    }
    
    private func stopPingTimer() {
        pingTimer?.invalidate()
        pingTimer = nil
    }
    
    private func sendPing() {
        webSocketTask?.sendPing { [weak self] error in
            if let error = error {
                print("❌ Ping failed: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self?.isConnected = false
                    self?.scheduleReconnect()
                }
            } else {
                print("✅ Ping successful - connection alive")
            }
        }
    }
    
    func connect() {
        guard let url = URL(string: urlString) else {
            print("❌ Invalid WebSocket URL")
            return
        }
        
        // Cancel any existing connection
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        
        // Use the configured URLSession
        webSocketTask = urlSession.webSocketTask(with: url)
        webSocketTask?.resume()
        
        isConnected = true
        reconnectAttempts = 0
        print("✅ WebSocket connected to: \(urlString)")
        
        // Start receiving messages
        receiveMessage()
    }
    
    func disconnect() {
        shouldReconnect = false
        reconnectTimer?.invalidate()
        reconnectTimer = nil
        stopPingTimer()
        endBackgroundTask()
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        isConnected = false
        print("🔌 WebSocket disconnected")
    }
    
    private func scheduleReconnect() {
        guard shouldReconnect else { return }
        guard reconnectAttempts < maxReconnectAttempts else {
            print("❌ Max reconnect attempts reached. Stopping reconnection.")
            return
        }
        
        reconnectAttempts += 1
        let delay = min(Double(reconnectAttempts) * 2.0, 30.0) // Exponential backoff, max 30s
        
        print("🔄 Scheduling reconnect attempt \(reconnectAttempts)/\(maxReconnectAttempts) in \(delay)s...")
        
        DispatchQueue.main.async { [weak self] in
            self?.reconnectTimer?.invalidate()
            self?.reconnectTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
                print("🔄 Attempting to reconnect...")
                self?.connect()
            }
        }
    }
    
    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    print("📨 Received message: \(text)")
                    
                    // Start background task if in background
                    let taskID = UIApplication.shared.beginBackgroundTask {
                        print("⚠️ Message processing background task expired")
                    }
                    
                    DispatchQueue.main.async {
                        self?.receivedMessages.append(text)
                        self?.messageCount += 1
                        
                        // Trigger for AlertList and AlertHistory
                        self?.newAlertReceived = true
                        
                        // Check if app is in background
                        let appState = UIApplication.shared.applicationState
                        let isInBackground = (appState == .background || appState == .inactive)
                        
                        print("📱 App state: \(appState.rawValue), In background: \(isInBackground)")
                        
                        // Send notification immediately
                        self?.notificationManager.sendNotification(
                            title: "Suspicious Behavior Detected",
                            body: "Check it out ASAP!",
                            badge: self?.messageCount
                        )
                        
                        // Reset trigger after a short delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self?.newAlertReceived = false
                        }
                        
                        // End background task
                        if taskID != .invalid {
                            UIApplication.shared.endBackgroundTask(taskID)
                        }
                    }
                    
                case .data(let data):
                    if let text = String(data: data, encoding: .utf8) {
                        print("📨 Received data: \(text)")
                        
                        // Start background task if in background
                        let taskID = UIApplication.shared.beginBackgroundTask {
                            print("⚠️ Message processing background task expired")
                        }
                        
                        DispatchQueue.main.async {
                            self?.receivedMessages.append(text)
                            self?.messageCount += 1
                            
                            // Send notification immediately
                            self?.notificationManager.sendNotification(
                                title: "Suspicious Behavior Detected",
                                body: "Check it out ASAP!",
                                badge: self?.messageCount
                            )
                            
                            // End background task
                            if taskID != .invalid {
                                UIApplication.shared.endBackgroundTask(taskID)
                            }
                        }
                    }
                @unknown default:
                    print("⚠️ Unknown message type received")
                }
                
                // Continue receiving messages
                self?.receiveMessage()
                
            case .failure(let error):
                print("❌ WebSocket error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self?.isConnected = false
                    // Auto-reconnect on error
                    self?.scheduleReconnect()
                }
            }
        }
    }
    
    func sendMessage(_ message: String) {
        let message = URLSessionWebSocketTask.Message.string(message)
        webSocketTask?.send(message) { error in
            if let error = error {
                print("❌ Error sending message: \(error.localizedDescription)")
            } else {
                print("✅ Message sent: \(message)")
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        disconnect()
    }
}
