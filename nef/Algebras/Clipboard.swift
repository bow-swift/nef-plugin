//  Copyright © 2020 The nef Authors.

import Foundation
import AppKit
import BowEffects

enum ClipboardError: Swift.Error {
    case writeToClipboard
}

protocol Clipboard {
    func write<D>(_ image: NSImage) -> EnvIO<D, ClipboardError, Void>
}
