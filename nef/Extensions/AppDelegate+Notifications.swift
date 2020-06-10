//  Copyright © 2020 The nef Authors.

import AppKit
import UserNotifications
import Bow
import BowEffects

struct ClipboardConfig {
    let clipboard: NSPasteboard
    let notificationCenter: UNUserNotificationCenter
}

extension AppDelegate {
    func pasteboardCarbonIO(data: Data) -> EnvIO<ClipboardConfig, AppDelegate.Error, NSImage> {
        func makeImage(_ data: Data) -> IO<AppDelegate.Error, NSImage> {
            data.makeImage().mapError { _ in AppDelegate.Error.carbon }
        }
        
        let image = EnvIO<ClipboardConfig, AppDelegate.Error, NSImage>.var()
        
        return binding(
            image <- makeImage(data).env(),
            |<-self.writeToPasteboard(image.get),
            |<-self.removeOldNotifications(),
            |<-self.showNotification(title: "nef",
                                     body: "Image copied to pasteboard!",
                                     imageData: data,
                                     actions: [.cancel, .saveImage]),
        yield:image.get)^
    }
    
    private func writeToPasteboard(_ image: NSImage) -> EnvIO<ClipboardConfig, AppDelegate.Error, Void> {
        EnvIO.invoke { config in
            config.clipboard.clearContents()
            config.clipboard.writeObjects([image])
        }^
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func isLocalNotification(_ aNotification: Notification) -> Bool {
        guard let userInfo = aNotification.userInfo,
              let launchOption = userInfo["NSApplicationLaunchIsDefaultLaunchKey"] as? Int else { return false }
        
        return launchOption == 0
    }
    
    func registerNotifications() {
        NefNotification.center.delegate = self
        NefNotification.center.requestAuthorization(options: [.alert, .sound]) { granted, _  in }
    }
    
    func removeOldNotifications() -> EnvIO<ClipboardConfig, AppDelegate.Error, Void> {
        EnvIO.invoke { config in
            config.notificationCenter.removeAllDeliveredNotifications()
        }^
    }
    
    func showNotification(title: String, body: String, imageData: Data? = nil, actions: [NefNotification.Action] = [], id: String = UUID().uuidString) -> EnvIO<ClipboardConfig,AppDelegate.Error, Void> {
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
    
    func processNotification(_ userInfo: [String: Any], action: String) -> IO<AppDelegate.Error, Either<Void, URL>> {
        guard let image = userInfo[NefNotification.UserInfoKey.imageData] as? Data else { return IO.raiseError(.notification)^ }
        
        switch action {
        case NefNotification.Action.saveImage.identifier:
            return image.persistImage(command: .pasteboardCarbon()).map(Either.right)^
        case UNNotificationDismissActionIdentifier:
            return IO.pure(.left(()))^
        default:
            return IO.raiseError(.notification)^
        }
    }
}

enum NefNotification {
    static var center: UNUserNotificationCenter { .current() }
}

extension NefNotification {
    enum Action: Equatable {
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
}

extension NefNotification {
    enum UserInfoKey {
        static let imageData = "imageDataUserInfoKey"
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
