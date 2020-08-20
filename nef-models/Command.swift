//  Copyright © 2020 The nef Authors.

import Foundation

public enum Command {
    case about
    case preferences
    case exportSnippet(selection: String)
    case exportSnippetToClipboard(selection: String)
    case markdownPage(playground: String)
    case playgroundBook(package: String)
    case notification(userInfo: [String: Any], action: String)
    
    public var key: String {
        switch self {
        case .about:
            return "about"
        case .preferences:
            return "preferences"
        case .exportSnippet:
            return "exportSnippet"
        case .exportSnippetToClipboard:
            return "exportSnippetToClipboard"
        case .markdownPage:
            return "markdownPage"
        case .playgroundBook:
            return "playgroundBook"
        case .notification:
            return "notification"
        }
    }
}
