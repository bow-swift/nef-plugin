//  Copyright © 2019 The nef Authors.

import Foundation
import AppKit

class Browser {
    func open(url: String) {
        guard let url = URL(string: url) else { return }
        NSWorkspace.shared.open(url)
    }
}
