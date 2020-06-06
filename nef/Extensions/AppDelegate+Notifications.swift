//  Copyright © 2020 The nef Authors.

import Foundation
import UserNotifications

extension AppDelegate: UNUserNotificationCenterDelegate {
    func registerNotifications() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound]) { granted, _  in }
    }
    
    func showNotification(title: String, body: String, imageData: Data? = nil, actions: [NefNotificationAction] = []) {
        let notificationCenter = UNUserNotificationCenter.current()
        let notificationId = UUID().uuidString
        let categoryId = "CATEGORY_IDENTIFIER_\(notificationId)"
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.categoryIdentifier = categoryId
        
        if let data = imageData {
            content.userInfo = ["imageData": data]
        }
        
        let category = UNNotificationCategory(identifier: categoryId,
                                              actions: actions.map(\.unNotificationAction),
                                              intentIdentifiers: [],
                                              hiddenPreviewsBodyPlaceholder: "",
                                              options: .customDismissAction)
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: notificationId, content: content, trigger: trigger)
        
        notificationCenter.delegate = self
        notificationCenter.setNotificationCategories([category])
        notificationCenter.add(request)
    }
    
    // MARK: delegate <UNUserNotificationCenterDelegate>
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if let data = userInfo["imageData"] {
            switch response.actionIdentifier {
            case NefNotificationAction.saveImage.identifier:
                print("do stuff: \(data)")
            case UNNotificationDismissActionIdentifier:
                break
            default:
                break
            }
        }
        completionHandler()
    }
}

enum NefNotificationAction: Equatable {
    case saveImage
    case cancel
    
    var title: String {
        switch self {
        case .saveImage: return "Save to disk"
        case .cancel: return "Cancel"
        }
    }
    
    var identifier: String {
        switch self {
        case .saveImage: return String(describing: self)
        case .cancel: return UNNotificationDismissActionIdentifier
        }
    }
}

// MARK: - Helpers
private extension NefNotificationAction {
    var unNotificationAction: UNNotificationAction {
        .init(identifier: identifier,
              title: title,
              options: .foreground)
    }
}
