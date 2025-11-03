//
//  NotificationManager.swift
//  Octrum
//
//  Created by Marcelinus Gerardo on 30/10/25.
//

import Foundation
import UserNotifications
import UIKit
import Combine

class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    
    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("✅ Notification permission granted")
            } else if let error = error {
                print("❌ Notification permission error: \(error.localizedDescription)")
            } else {
                print("⚠️ Notification permission denied")
            }
        }
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    // This method is called when notification arrives while app is in FOREGROUND
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                               willPresent notification: UNNotification,
                               withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show notification even when app is open (foreground)
        completionHandler([.banner, .sound, .badge])
        print("✅ Notification displayed in foreground: \(notification.request.content.title)")
    }
    
    // This method is called when user taps on the notification
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                               didReceive response: UNNotificationResponse,
                               withCompletionHandler completionHandler: @escaping () -> Void) {
        print("📱 User tapped notification: \(response.notification.request.content.title)")
        completionHandler()
    }
    
    func sendNotification(title: String, body: String, badge: Int? = nil, soundName: String? = "alert.wav") {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        
        // Set custom sound or default
        if let soundName = soundName {
            content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: soundName))
            print("🔔 Using custom sound: \(soundName)")
        } else {
            content.sound = .default
            print("🔔 Using default sound")
        }
        
        if let badge = badge {
            content.badge = NSNumber(value: badge)
        }
        
        // Trigger immediately
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error sending notification: \(error.localizedDescription)")
            } else {
                print("✅ Notification sent: \(title)")
            }
        }
    }
    
    func incrementBadge() {
        UNUserNotificationCenter.current().getDeliveredNotifications { notifications in
            let newBadge = notifications.count + 1
            DispatchQueue.main.async {
                UIApplication.shared.applicationIconBadgeNumber = newBadge
            }
        }
    }
    
    func clearBadge() {
        DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }
}
