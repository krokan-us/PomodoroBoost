//
//  NotificationsManager.swift
//  PomodomoLight
//
//  Created by Asım Altınışık on 16.05.2023.
//

import UserNotifications
import UIKit

class NotificationManager {
    
    let userDefaults = UserDefaults.standard
    
    static let shared = NotificationManager()
    private let notificationCenter = UNUserNotificationCenter.current()
    
    // Request user authorization for sending notifications
    func sendNotificationRequest() {
        notificationCenter.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Failed to request notification authorization: \(error.localizedDescription)")
            }
            if granted {
                print("Notification authorization granted")
            } else {
                print("Notification authorization denied")
            }
        }
    }
    
    // Check if notifications are enabled for the app
    func isNotificationsEnabled(completion: @escaping (Bool) -> Void) {
        notificationCenter.getNotificationSettings { settings in
            completion(settings.authorizationStatus == .authorized)
        }
    }
    
    // Disable notifications for the app
    func disableNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.removeAllDeliveredNotifications()
    }
}
