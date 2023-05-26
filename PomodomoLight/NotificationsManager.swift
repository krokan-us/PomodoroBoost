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
    
    private let sessionEndedNotifications = [
        "☕️ Time for a break!",
        "😌 Relax and recharge!",
        "🏖️ Take a rest!",
        "🧘‍♀️ Clear your mind!",
        "🌴 Enjoy a break!",
        "👣 Stretch and relax!",
        "🌞 Refresh yourself!",
        "🎶 Listen to soothing music!",
        "📖 Read a book!",
        "💤 Power nap time!",
        "🧁 Treat yourself!",
        "🤗 Connect with a friend!",
        "⏰ Take a break!",
        "🔆 Pause and relax!",
        "💆‍♂️ Rejuvenate yourself!"
    ]
    
    private let breakEndedNotifications = [
        "⏰ Break's over! Let's continue!",
        "💪 Ready to rock the next session!",
        "🔥 Back in action! Keep it up!",
        "⚡️ Break's done. Keep the momentum!",
        "💥 Recharged and ready? Let's go!",
        "⚡️ Break's over! Ignite the session!",
        "🔥 Back in action! Make waves!",
        "💥 Break's up! Let's crush it!",
        "🌟 Break's done! Shine brighter now!",
        "⏳ Time's up! Dive back in!",
        "💪 Recharged and ready to dominate!",
        "✨ Break complete! Sparkle in the session!",
        "⚡️ Energized and ready! Back to it!",
        "🔥 Break over! Unleash your brilliance!",
        "💫 Break's end! Let's soar!"
    ]
    
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
    
    func scheduleNotification(content: UNMutableNotificationContent, timeInterval: TimeInterval, identifier: String) {
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        let notificationCenter = UNUserNotificationCenter.current()
        let backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
        
        notificationCenter.add(request) { (error) in
            if let error = error {
                // Handle notification scheduling error
                print("Notification scheduling error: \(error.localizedDescription)")
            }
            
            // End the background task once the notification is scheduled
            UIApplication.shared.endBackgroundTask(backgroundTaskIdentifier)
        }
    }
    
    func scheduleTimerNotification(timeInterval: TimeInterval, isBreak: Bool) {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = isBreak ? "Break Ended" : "Session Ended"
        notificationContent.body = isBreak ? breakEndedNotifications.randomElement() ?? "Your break has ended." : sessionEndedNotifications.randomElement() ?? "Your session has ended."
        notificationContent.sound = UNNotificationSound.default
        
        let identifier = isBreak ? "breakEndedNotification" : "sessionEndedNotification"
        scheduleNotification(content: notificationContent, timeInterval: timeInterval, identifier: identifier)
    }
    
    func sendBreakEndedNotification() {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "Break Ended"
        notificationContent.body = breakEndedNotifications.randomElement() ?? "Your break has ended."
        notificationContent.sound = UNNotificationSound.default

        let identifier = "breakEndedNotification"
        scheduleNotification(content: notificationContent, timeInterval: 0.1, identifier: identifier)
    }

    func sendSessionEndedNotification() {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "Session Ended"
        notificationContent.body = sessionEndedNotifications.randomElement() ?? "Your session has ended."
        notificationContent.sound = UNNotificationSound.default

        let identifier = "sessionEndedNotification"
        scheduleNotification(content: notificationContent, timeInterval: 0.1, identifier: identifier)
    }
}
