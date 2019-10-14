//  Copyright © 2019 The nef Authors.

import AppKit

extension NSWindow {
    
    static var empty: NSWindow {
        let window = NSWindow()
        window.setFrame(.zero, display: false)
        return window
    }
}
