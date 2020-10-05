//  Copyright © 2020 The nef Authors.

import Foundation
import AppKit
import UserNotifications

import Bow
import BowEffects

class MacClipboard: Clipboard {
    let pasteboard: NSPasteboard
    
    init(pasteboard: NSPasteboard = .general) {
        self.pasteboard = pasteboard
    }
    
    func write<D>(_ image: NSImage) -> EnvIO<D, ClipboardError, Void> {
        EnvIO.invoke { _ in
            self.pasteboard.clearContents()
            if !self.pasteboard.writeObjects([image]) {
                throw ClipboardError.writeToClipboard
            }
        }^
    }
}
