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
    
    func runAsync(completion: @escaping (Result<Void, Swift.Error>) -> Void) {
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
    

    
//    func processNotification(_ userInfo: [String: Any], action: String) -> EnvIO<NotificationConfig, NefNotification.Error, NefNotification.Response> {
//        guard let image = userInfo[NefNotification.UserInfoKey.imageData] as? Data else {
//            return EnvIO.raiseError(.noImageData)^
//        }
//        
//        switch action {
//        case NefNotification.Action.saveImage.identifier:
//            return image
//                .persist(command: .exportSnippetToClipboard(selection: ""))
//                .mapError { _ in .persistImage }
//                .contramap(\.openPanel)
//                .map { .saveImage($0) }^
//        case UNNotificationDismissActionIdentifier:
//            return EnvIO.pure(.dismiss)^
//        default:
//            return EnvIO.raiseError(.unsupportedAction)^
//        }
//    }
}





/// -------------- AppDelegate+Clipboard

import AppKit
import Bow
import BowEffects

//extension ImageNotificationController {
//    func showClipboardFile(response: NefNotification.Response) -> EnvIO<NotificationConfig, NefNotification.Error, Void> {
//        guard case let .saveImage(url) = response else { return EnvIO.pure(())^ }
//        
//        return EnvIO.invoke { config in
//            config.workspace.activateFileViewerSelecting([url])
//        }^
//    }
//}


//struct NotificationConfig {
//    let workspace: NSWorkspace
//    let openPanel: OpenPanel
//}
