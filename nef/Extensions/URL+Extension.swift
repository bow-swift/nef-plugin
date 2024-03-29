//  Copyright © 2020 The nef Authors.

import Foundation
import SourceEditorModels
import Bow
import BowEffects

extension URL {
    func outputURL<E: Error>(command: Command) -> IO<E, URL> {
        IO.invoke {
            let filename = "nef-\(command.menuKey) \(Date.now.human)"
            let url = appendingPathComponent(filename).appendingCommandExtensionComponent(command: command)
            return url
        }
    }
    
    func outputURL<D, E: Error>(command: Command) -> EnvIO<D, E, URL> {
        let io: IO<E, URL> = outputURL(command: command)
        return io.env()^
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
