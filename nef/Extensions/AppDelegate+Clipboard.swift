//  Copyright © 2020 The nef Authors.

import AppKit
import Bow
import BowEffects

extension AppDelegate {
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

private extension AppDelegate {
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
