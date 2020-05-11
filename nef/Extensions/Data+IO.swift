//  Copyright © 2020 The nef Authors.

import Foundation
import Bow
import BowEffects
import AppKit

enum ImageError: Error {
    case invalidData
}

extension Data {
    func writeIO(to url: URL) -> IO<Error, Void> {
        IO.invoke {
            try self.write(to: url)
        }
    }
    
    func makeImage() -> IO<ImageError, NSImage> {
        IO.invoke {
            guard let image = NSImage(data: self) else {
                throw ImageError.invalidData
            }
            return image
        }
    }
}
