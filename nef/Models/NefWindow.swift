//  Copyright © 2020 The nef Authors.

import Foundation
import AppKit

enum NefWindow {
    struct Config {
        let title: String
        let rect: NSRect
        let needMenu: Bool
    }
    
    case view(NSView, config: Config)
    case controller(NefController)
    case viewController(view: NSView, controller: NefController, config: Config)
}
