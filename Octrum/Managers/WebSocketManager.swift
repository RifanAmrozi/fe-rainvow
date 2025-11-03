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
    
    @Published var isConnected = false
    @Published var receivedMessages: [String] = []
    
    func connect() {
        guard let url = URL(string: urlString) else {
            print("❌ Invalid WebSocket URL")
            return
        }
        
        let session = URLSession(configuration: .default)
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        
        isConnected = true
        print("✅ WebSocket connected to: \(urlString)")
        
        // Start receiving messages
        receiveMessage()
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        isConnected = false
        print("🔌 WebSocket disconnected")
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
                            title: "🚨 New Alert",
                            body: text,
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
                                title: "🚨 New Alert",
                                body: text,
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
