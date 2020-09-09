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
    let action: String
    let config: NotificationConfig
    
    init?(userInfo: [String: Any], action: String, openPanel: OpenPanel) {
        guard let image = userInfo[NefNotification.UserInfoKey.imageData] as? Data else { return nil }
        self.image = image
        self.action = action
        self.config = .init(openPanel: openPanel)
    }
    
    func runAsync(completion: @escaping (Result<Void, Swift.Error>) -> Void) {
        runIO(image: image, action: action).provide(config)
            .map(Browser.showFile)^
            .unsafeRunAsyncResult(completion: completion)
    }
    
    func runIO(image: Data, action: String) -> EnvIO<NotificationConfig, NefNotification.Error, URL> {
        processNotification(image: image, action: action)
            .flatMap(clipboardFile)^
    }
    
    private func processNotification(image: Data, action: String) -> EnvIO<NotificationConfig, NefNotification.Error, NefNotification.Response> {
        switch action {
        case NefNotification.Action.saveImage.identifier:
            return persistImage(image)
        case NefNotification.Action.cancel.identifier:
            return EnvIO.pure(.dismiss)^
        default:
            return EnvIO.raiseError(.unsupportedAction)^
        }
    }
    
    private func persistImage(_ image: Data) -> EnvIO<NotificationConfig, NefNotification.Error, NefNotification.Response> {
        image.persist(command: .exportSnippetToClipboard(selection: ""))
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
