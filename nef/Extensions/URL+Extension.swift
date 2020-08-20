//  Copyright © 2020 The nef Authors.

import Foundation
import BowEffects

extension URL {
    func outputURL<E: Error>(command: Command) -> IO<E, URL> {
        let filename = "nef-\(command.menuKey) \(Date.now.human)"
        let url = appendingPathComponent(filename).appendingCommandExtensionComponent(command: command)
        return IO.pure(url)^
    }
    
    func appendingCommandExtensionComponent(command: Command) -> URL {
        switch command {
        case .exportSnippetToFile, .exportSnippetToClipboard:
            return appendingPathExtension("jpg")
        case .markdownPage:
            return appendingPathExtension("md")
        default:
            return self
        }
    }
}
