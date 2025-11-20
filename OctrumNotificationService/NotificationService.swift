//
//  NotificationService.swift
//  OctrumNotificationService
//
//  Created by Marcelinus Gerardo on 18/11/25.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        guard let bestAttemptContent = bestAttemptContent else {
            contentHandler(request.content)
            return
        }
        
        // Log untuk debugging
        print("🔔 NotificationService: didReceive called")
        print("📦 Payload: \(request.content.userInfo)")
        
        // Get media URL from payload
        guard let mediaUrlString = request.content.userInfo["media-url"] as? String,
              let mediaUrl = URL(string: mediaUrlString) else {
            print("❌ No valid media-url found in payload")
            print("📋 Available keys: \(request.content.userInfo.keys)")
            contentHandler(bestAttemptContent)
            return
        }
        
        print("📥 Downloading media from: \(mediaUrlString)")
        
        // Download the image
        downloadMedia(from: mediaUrl) { [weak self] localURL in
            guard let self = self,
                  let localURL = localURL else {
                print("❌ Failed to download media")
                contentHandler(bestAttemptContent)
                return
            }
            
            // Attach the downloaded image
            do {
                let attachment = try UNNotificationAttachment(
                    identifier: "image",
                    url: localURL,
                    options: [UNNotificationAttachmentOptionsTypeHintKey: "public.jpeg"]
                )
                bestAttemptContent.attachments = [attachment]
                print("✅ Media attachment added successfully")
            } catch {
                print("❌ Error creating attachment: \(error.localizedDescription)")
            }
            
            contentHandler(bestAttemptContent)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        if let contentHandler = contentHandler, let bestAttemptContent = bestAttemptContent {
            print("⏰ Service extension time will expire")
            contentHandler(bestAttemptContent)
        }
    }
    
    private func downloadMedia(from url: URL, completion: @escaping (URL?) -> Void) {
        let task = URLSession.shared.downloadTask(with: url) { localURL, response, error in
            guard let localURL = localURL, error == nil else {
                print("❌ Download error: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }
            
            // Create a temporary file URL
            let tempDirectory = FileManager.default.temporaryDirectory
            let uniqueFilename = UUID().uuidString + ".jpg"
            let destinationURL = tempDirectory.appendingPathComponent(uniqueFilename)
            
            do {
                // Move the downloaded file to a permanent temporary location
                if FileManager.default.fileExists(atPath: destinationURL.path) {
                    try FileManager.default.removeItem(at: destinationURL)
                }
                try FileManager.default.moveItem(at: localURL, to: destinationURL)
                print("✅ Media downloaded to: \(destinationURL.path)")
                completion(destinationURL)
            } catch {
                print("❌ File move error: \(error.localizedDescription)")
                completion(nil)
            }
        }
        task.resume()
    }

}
