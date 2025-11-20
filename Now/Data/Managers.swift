//
//  Managers.swift
//  Now
//
//  Created by Rohan Kewalramani on 11/20/25.
//

import Foundation
import LocalAuthentication
import UserNotifications

// MARK: - AUTHENTICATION MANAGER
class AuthenticationManager {
    static func authenticate(completion: @escaping (Bool) -> Void) {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Unlock your journal."
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    completion(success)
                }
            }
        } else {
            print("Biometrics not available")
            completion(false)
        }
    }
}

// MARK: - NOTIFICATION MANAGER
class NotificationManager {
    static func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    static func scheduleDailyReminder(isEnabled: Bool, timePreference: String = "Night") {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        if isEnabled {
            let content = UNMutableNotificationContent()
            content.title = "Time to Reflect"
            content.body = "Take a moment to capture the Now."
            content.sound = .default
            
            var dateComponents = DateComponents()
            dateComponents.minute = 0
            
            switch timePreference {
            case "Morning":
                dateComponents.hour = 8 // 8:00 AM
            case "Afternoon":
                dateComponents.hour = 14 // 2:00 PM
            default:
                dateComponents.hour = 20 // 8:00 PM
            }
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(identifier: "daily-reflection", content: content, trigger: trigger)
            
            center.add(request)
        }
    }
}
