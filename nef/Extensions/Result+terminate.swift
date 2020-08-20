//  Copyright © 2020 The nef Authors.

import AppKit
import Bow

extension Result {
    
    func terminate() {
        func terminate() {
            DispatchQueue.main.async {
                NSApplication.shared.terminate(nil)
            }
        }
            
        fold({ _ in terminate() }, { _ in terminate() })
    }
}
