//  Copyright © 2020 The nef Authors.

import Foundation
import UserNotifications

extension AppDelegate: UNUserNotificationCenterDelegate {
    func registerNotifications() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound]) { granted, _  in }
    }
    
    func showNotification(title: String, body: String, actions: [NefNotificationAction] = []) {
        let notificationCenter = UNUserNotificationCenter.current()
        let notificationId = UUID().uuidString
        let categoryId = "CATEGORY_IDENTIFIER_\(notificationId)"
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.categoryIdentifier = categoryId
        
        let category = UNNotificationCategory(identifier: categoryId,
                                              actions: actions.map(\.unNotificationAction),
                                              intentIdentifiers: [],
                                              hiddenPreviewsBodyPlaceholder: "",
                                              options: .customDismissAction)
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: notificationId, content: content, trigger: trigger)
        
        notificationCenter.delegate = self
        notificationCenter.setNotificationCategories([category])
        notificationCenter.add(request) { _ in }
    }
    
    // MARK: delegate <UNUserNotificationCenterDelegate>
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // TODO
    }
}

enum NefNotificationAction: Equatable {
    case store(title: String)
    
    var title: String {
        switch self {
        case .store(let title): return title
        }
    }
}

// MARK: - Helpers
private extension NefNotificationAction {
    var unNotificationAction: UNNotificationAction {
        .init(identifier: "\(self)",
              title: self.title,
              options: .foreground)
    }
}
