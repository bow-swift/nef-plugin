//  Copyright © 2020 The nef Authors.

import Foundation
import BowEffects

extension URL {
    func outputURL(command: Command) -> IO<OpenPanelError, URL> {
        let filename = "nef-\(command) \(Date.now.human)"
        return IO.pure(appendingPathComponent(filename))^
    }
}
