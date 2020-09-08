//  Copyright © 2020 The nef Authors.

import Foundation
import AppKit
import UserNotifications

import Bow
import BowEffects

class MacPasteboard: Pasteboard {
    let pasteboard: NSPasteboard
    
    init(pasteboard: NSPasteboard) {
        self.pasteboard = pasteboard
    }
    
    func write<D>(_ image: NSImage) -> EnvIO<D, PasteboardError, Void> {
        EnvIO.invoke { _ in
            self.pasteboard.clearContents()
            if !self.pasteboard.writeObjects([image]) {
                throw PasteboardError.writeToClipboard
            }
        }^
    }
}
