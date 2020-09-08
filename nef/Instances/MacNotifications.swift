//  Copyright © 2020 The nef Authors.

import Foundation
import AppKit
import UserNotifications

import Bow
import BowEffects

class MacNotificationController: Notifications {
    let notificationCenter: UNUserNotificationCenter
    
    init(notificationCenter: UNUserNotificationCenter) {
        self.notificationCenter = notificationCenter
    }
    
    func removeAllDelivered<D, E: Swift.Error>() -> EnvIO<D, E, Void> {
        EnvIO.invoke { _ in
            self.notificationCenter.removeAllDeliveredNotifications()
        }^
    }
    
    func show<D, E: Swift.Error>(title: String, body: String, options: NotificationOptions) -> EnvIO<D, E, Void> {
        EnvIO.invoke { _ in
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.categoryIdentifier = options.identifier
            
            if let imageData = options.imageData {
                content.userInfo = [NefNotification.UserInfoKey.imageData: imageData]
            }
            
            let category = UNNotificationCategory(identifier: options.identifier,
                                                  actions: options.actions.map(\.unNotificationAction),
                                                  intentIdentifiers: [],
                                                  hiddenPreviewsBodyPlaceholder: "",
                                                  options: .customDismissAction)
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)
            let request = UNNotificationRequest(identifier: options.identifier, content: content, trigger: trigger)
            
            self.notificationCenter.setNotificationCategories([category])
            self.notificationCenter.add(request)
        }^
    }
}

// MARK: - Helpers
private extension NefNotification.Action {
    var unNotificationAction: UNNotificationAction {
        .init(identifier: identifier,
              title: title,
              options: .foreground)
    }
}
