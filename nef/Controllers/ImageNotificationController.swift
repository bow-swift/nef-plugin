//  Copyright © 2020 The nef Authors.

import Foundation

class ImageNotificationController: NefController {
    let image: Data
    let action: String
    
    init?(userInfo: [String: Any], action: String) {
        guard let image = userInfo[NefNotification.UserInfoKey.imageData] as? Data else { return nil }
        self.image = image
        self.action = action
    }
    
    func run() -> Result<Void, Error> {
        fatalError()
        //        let config = NotificationConfig(workspace: .shared, openPanel: assembler.resolveOpenPanel())
        //
        //        processNotification(userInfo, action: action)
        //            .flatMap(showClipboardFile)^
        //            .provide(config)
        //            .unsafeRunAsync(on: .global(qos: .userInitiated)) { _ in self.terminate() }
    }
}












/// -------------- AppDelegate+Notification

import AppKit
import UserNotifications
import Bow
import BowEffects

extension ImageNotificationController {
    
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


/// -------------- AppDelegate+Clipboard

import AppKit
import Bow
import BowEffects

extension ImageNotificationController {
    func clipboardCarbonIO(data: Data) -> EnvIO<Clipboard.Config, Clipboard.Error, NSImage> {
        func makeImage(_ data: Data) -> IO<Clipboard.Error, NSImage> {
            data.makeImage().mapError { _ in .invalidData }
        }
        
        let image = EnvIO<Clipboard.Config, Clipboard.Error, NSImage>.var()
        
        return binding(
            image <- makeImage(data).env(),
            |<-self.writeToClipboard(image.get),
            |<-self.removeOldNotifications(),
            |<-self.showNotification(title: "nef",
                                     body: "Image copied to clipboard!",
                                     imageData: data,
                                     actions: [.cancel, .saveImage]),
        yield:image.get)^
    }
    
    func showClipboardFile(response: NefNotification.Response) -> EnvIO<NotificationConfig, NefNotification.Error, Void> {
        guard case let .saveImage(url) = response else { return EnvIO.pure(())^ }
        
        return EnvIO.invoke { config in
            config.workspace.activateFileViewerSelecting([url])
        }^
    }
}

private extension ImageNotificationController {
    func writeToClipboard(_ image: NSImage) -> EnvIO<Clipboard.Config, Clipboard.Error, Void> {
        EnvIO.invoke { config in
            config.clipboard.clearContents()
            if !config.clipboard.writeObjects([image]) {
                throw Clipboard.Error.writeToClipboard
            }
        }^
    }
}

struct NotificationConfig {
    let workspace: NSWorkspace
    let openPanel: OpenPanel
}
