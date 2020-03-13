//  Copyright © 2020 The nef Authors.

import Foundation
import Bow
import BowEffects

extension Data {
    func writeIO(to url: URL) -> IO<Error, Void> {
        IO.invoke {
            try self.write(to: url)
        }
    }
}
