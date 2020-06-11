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
    func pasteboardCarbonIO(data: Data) -> EnvIO<ClipboardConfig, Clipboard.Error, NSImage> {
        func makeImage(_ data: Data) -> IO<Clipboard.Error, NSImage> {
            data.makeImage().mapError { _ in .invalidData }
        }
        
        let image = EnvIO<ClipboardConfig, Clipboard.Error, NSImage>.var()
        
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
    
    private func writeToPasteboard(_ image: NSImage) -> EnvIO<ClipboardConfig, Clipboard.Error, Void> {
        EnvIO.invoke { config in
            config.clipboard.clearContents()
            if !config.clipboard.writeObjects([image]) {
                throw Clipboard.Error.writeToClipboard
            }
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
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _  in }
    }
    
    func removeOldNotifications() -> EnvIO<ClipboardConfig, Clipboard.Error, Void> {
        EnvIO.invoke { config in
            config.notificationCenter.removeAllDeliveredNotifications()
        }^
    }
    
    func showNotification(title: String, body: String, imageData: Data? = nil, actions: [NefNotification.Action] = [], id: String = UUID().uuidString) -> EnvIO<ClipboardConfig, Clipboard.Error, Void> {
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
    
    func processNotification(_ userInfo: [String: Any], action: String) -> IO<NefNotification.Error, NefNotification.Response> {
        guard let image = userInfo[NefNotification.UserInfoKey.imageData] as? Data else { return IO.raiseError(.noImageData)^ }
        
        switch action {
        case NefNotification.Action.saveImage.identifier:
            return image
                .persistImage(command: .pasteboardCarbon())
                .mapError { _ in .persistImage }
                .map { .saveImage($0) }^
        case UNNotificationDismissActionIdentifier:
            return IO.pure(.dismiss)^
        default:
            return IO.raiseError(.unsupportedAction)^
        }
    }
    
    func showClipboardFile(response: NefNotification.Response) -> EnvIO<NSWorkspace, NefNotification.Error, Void> {
        guard case let .saveImage(url) = response else { return EnvIO.pure(())^ }
        
        return EnvIO.invoke { workspace in
            workspace.activateFileViewerSelecting([url])
        }^
    }
}

enum Clipboard {
    enum Error: Swift.Error {
        case invalidData
        case writeToClipboard
        case carbon
    }
}

enum NefNotification {
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
    
    enum Response {
        case saveImage(URL)
        case dismiss
    }
    
    enum UserInfoKey {
        static let imageData = "imageDataUserInfoKey"
    }
    
    enum Error: Swift.Error {
        case noImageData
        case unsupportedAction
        case persistImage
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
