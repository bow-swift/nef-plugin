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
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _  in }
    }
    
    func removeOldNotifications() -> EnvIO<Clipboard.Config, Clipboard.Error, Void> {
        EnvIO.invoke { config in
            config.notificationCenter.removeAllDeliveredNotifications()
        }^
    }
    
    func showNotification(title: String, body: String, imageData: Data? = nil, actions: [NefNotification.Action] = [], id: String = UUID().uuidString) -> EnvIO<Clipboard.Config, Clipboard.Error, Void> {
        EnvIO.invoke { config in
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.categoryIdentifier = id
            
            if let data = imageData {
                content.userInfo = [NefNotification.UserInfoKey.imageData: data]
            }
            
            let category = UNNotificationCategory(identifier: id,
                                                  actions: actions.map(\.unNotificationAction),
                                                  intentIdentifiers: [],
                                                  hiddenPreviewsBodyPlaceholder: "",
                                                  options: .customDismissAction)
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)
            let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
            
            config.notificationCenter.setNotificationCategories([category])
            config.notificationCenter.add(request)
        }^
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
    
    func processNotification(_ userInfo: [String: Any], action: String) -> EnvIO<NotificationConfig, NefNotification.Error, NefNotification.Response> {
        guard let image = userInfo[NefNotification.UserInfoKey.imageData] as? Data else {
            return EnvIO.raiseError(.noImageData)^
        }
        
        switch action {
        case NefNotification.Action.saveImage.identifier:
            return image
                .persist(command: .exportSnippetToClipboard(selection: ""))
                .mapError { _ in .persistImage }
                .contramap(\.openPanel)
                .map { .saveImage($0) }^
        case UNNotificationDismissActionIdentifier:
            return EnvIO.pure(.dismiss)^
        default:
            return EnvIO.raiseError(.unsupportedAction)^
        }
    }
}

enum Clipboard {
    enum Error: Swift.Error {
        case invalidData
        case writeToClipboard
        case carbon
    }
    
    struct Config {
        let clipboard: NSPasteboard
        let notificationCenter: UNUserNotificationCenter
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
