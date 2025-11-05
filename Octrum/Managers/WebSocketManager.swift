//
//  WebSocketManager.swift
//  Octrum
//
//  Created by Marcelinus Gerardo on 30/10/25.
//

import Foundation
import Combine

class WebSocketManager: ObservableObject {
    private var webSocketTask: URLSessionWebSocketTask?
    private let urlString = "ws://10.60.60.232:3000/ws/alerts"
    private let notificationManager = NotificationManager.shared
    private var messageCount = 0
    private var reconnectTimer: Timer?
    private var reconnectAttempts = 0
    private let maxReconnectAttempts = 10
    private var shouldReconnect = true
    
    @Published var isConnected = false
    @Published var receivedMessages: [String] = []
    
    func connect() {
        guard let url = URL(string: urlString) else {
            print("❌ Invalid WebSocket URL")
            return
        }
        
        // Cancel any existing connection
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        
        let session = URLSession(configuration: .default)
        webSocketTask = session.webSocketTask(with: url)
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
                    DispatchQueue.main.async {
                        self?.receivedMessages.append(text)
                        self?.messageCount += 1
                        
                        // Send notification
                        self?.notificationManager.sendNotification(
                            title: "Suspicious Behavior Detected",
                            body: "Check it out ASAP!",
                            // body: text,
                            badge: self?.messageCount
                        )
                    }
                case .data(let data):
                    if let text = String(data: data, encoding: .utf8) {
                        print("📨 Received data: \(text)")
                        DispatchQueue.main.async {
                            self?.receivedMessages.append(text)
                            self?.messageCount += 1
                            
                            // Send notification
                            self?.notificationManager.sendNotification(
                                title: "Suspicious Behavior Detected",
                                body: "Check it out ASAP!",
                                // body: text,
                                badge: self?.messageCount
                            )
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
        disconnect()
    }
}
