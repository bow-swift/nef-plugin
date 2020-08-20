//  Copyright © 2020 The nef Authors.

import AppKit
import UserNotifications

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func registerNotifications() {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _  in }
    }
    
    func isLocalNotification(_ aNotification: Notification) -> Bool {
        guard let userInfo = aNotification.userInfo,
              let launchOption = userInfo["NSApplicationLaunchIsDefaultLaunchKey"] as? Int else { return false }
        
        return launchOption == 0
    }
    
    // MARK: delegate <UNUserNotificationCenterDelegate>
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        guard let userInfo = response.notification.request.content.userInfo as? [String: Any] else { return }
        command = .notification(userInfo: userInfo, action: response.actionIdentifier)
        applicationDidFinishLaunching(Notification(name: .NSThreadWillExit))
        completionHandler()
    }
}
