//  Copyright © 2020 The nef Authors.

import Foundation
import BowEffects

extension URL {
    func outputURL(command: Command) -> IO<OpenPanelError, URL> {
        let filename = "nef-\(command) \(Date.now.human)"
        let url = appendingPathComponent(filename).appendingCommandExtensionComponent(command: command)
        return IO.pure(url)^
    }
    
    func appendingCommandExtensionComponent(command: Command) -> URL {
        let ext: String
        switch command {
        case .carbon, .pasteboardCarbon: ext = "jpg"
        case .markdownPage: ext = "md"
        default: ext = ""
        }
        
        return appendingPathExtension(ext)
    }
}
