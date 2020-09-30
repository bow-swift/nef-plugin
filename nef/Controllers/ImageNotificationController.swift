//  Copyright © 2020 The nef Authors.

import Foundation
import SourceEditorUtils
import Bow
import BowEffects


struct NotificationConfig {
    let openPanel: OpenPanel
}

class ImageNotificationController: NefController {
    let image: Data
    let code: String
    let action: String
    let config: NotificationConfig
    
    init?(userInfo: [String: Any], action: String, openPanel: OpenPanel) {
        guard let image = userInfo[NefNotification.UserInfoKey.imageData] as? Data,
              let code = userInfo[NefNotification.UserInfoKey.description] as? String else { return nil }
        self.image = image
        self.code = code
        self.action = action
        self.config = .init(openPanel: openPanel)
    }
    
    func runAsync(completion: @escaping (Result<Void, Swift.Error>) -> Void) {
        runIO(image: image, code: code, action: action).provide(config)
            .map(Browser.showFile)^
            .unsafeRunAsyncResult(completion: completion)
    }
    
    func runIO(image: Data, code: String, action: String) -> EnvIO<NotificationConfig, NefNotification.Error, URL> {
        processNotification(image: image, code: code, action: action)
            .flatMap(clipboardFile)^
    }
    
    private func processNotification(image: Data, code: String, action: String) -> EnvIO<NotificationConfig, NefNotification.Error, NefNotification.Response> {
        switch action {
        case NefNotification.Action.saveImage.identifier:
            return persistImageClipboard(image: image, code: code)
        case NefNotification.Action.cancel.identifier:
            return EnvIO.pure(.dismiss)^
        default:
            return EnvIO.raiseError(.unsupportedAction)^
        }
    }
    
    private func persistImageClipboard(image: Data, code: String) -> EnvIO<NotificationConfig, NefNotification.Error, NefNotification.Response> {
        image.persist(command: .exportSnippetToClipboard(selection: code))
             .contramap(\.openPanel)
             .mapError { _ in .persistImage }.map { .saveImage($0) }^
    }
    
    private func clipboardFile(response: NefNotification.Response) -> EnvIO<NotificationConfig, NefNotification.Error, URL> {
        EnvIO.invoke { config in
            guard case let .saveImage(url) = response else {
                throw NefNotification.Error.noImageData
            }
            return url
        }^
    }
}
