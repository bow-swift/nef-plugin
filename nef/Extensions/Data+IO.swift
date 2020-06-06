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
    
    func persistImage(command: Command, assembler: Assembler = Assembler()) -> IO<AppDelegate.Error, URL> {
        assembler.resolveOpenPanel().writableFolder(create: true).use { folder in
            let output = IO<OpenPanelError, URL>.var()
            return binding(
                output <- folder.outputURL(command: command),
                       |<-self.writeIO(to: output.get).mapError { _ in .unknown },
            yield: output.get)
        }^.mapError { _ in .carbon }^
    }
}
