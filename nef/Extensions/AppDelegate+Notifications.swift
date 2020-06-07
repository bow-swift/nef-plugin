//  Copyright © 2020 The nef Authors.

import AppKit
import UserNotifications
import Bow
import BowEffects

extension AppDelegate: UNUserNotificationCenterDelegate {
    func isLocalNotification(_ aNotification: Notification) -> Bool {
        guard let userInfo = aNotification.userInfo,
              let launchOption = userInfo["NSApplicationLaunchIsDefaultLaunchKey"] as? Int else { return false }
        
        return launchOption == 0
    }
    
    func registerNotifications() {
        notificationCenter.delegate = self
        notificationCenter.requestAuthorization(options: [.alert, .sound]) { granted, _  in }
    }
    
    func showNotification(title: String, body: String, imageData: Data? = nil, actions: [NefNotificationAction] = [], id: String = UUID().uuidString) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.categoryIdentifier = id
        
        if let data = imageData {
            content.userInfo = [Self.imageDataUserInfoKey: data]
        }
        
        let category = UNNotificationCategory(identifier: id,
                                              actions: actions.map(\.unNotificationAction),
                                              intentIdentifiers: [],
                                              hiddenPreviewsBodyPlaceholder: "",
                                              options: .customDismissAction)
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        notificationCenter.removeAllDeliveredNotifications()
        notificationCenter.setNotificationCategories([category])
        notificationCenter.add(request)
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
    
    func processNotification(_ userInfo: [String: Any], action: String) -> IO<AppDelegate.Error, Either<Void, URL>> {
        guard let image = userInfo[Self.imageDataUserInfoKey] as? Data else { return IO.raiseError(.notification)^ }
        
        switch action {
        case NefNotificationAction.saveImage.identifier:
            return image.persistImage(command: .pasteboardCarbon()).map(Either.right)^
        case UNNotificationDismissActionIdentifier:
            return IO.pure(.left(()))^
        default:
            return IO.raiseError(.notification)^
        }
    }
}

private extension AppDelegate {
    static let imageDataUserInfoKey = "imageDataUserInfoKey"
    var notificationCenter: UNUserNotificationCenter { .current() }
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
