//  Copyright © 2020 The nef Authors.

import Foundation
import AppKit
import BowEffects

enum PasteboardError: Swift.Error {
    case writeToClipboard
}

protocol Pasteboard {
    func write<D>(_ image: NSImage) -> EnvIO<D, PasteboardError, Void>
}
