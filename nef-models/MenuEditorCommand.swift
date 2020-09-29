//  Copyright © 2020 The nef Authors.

import Foundation

public enum MenuEditorCommand {
    case about
    case preferences
    case exportSnippetToFile
    case exportSnippetToClipboard
    case markdownPage
    case playgroundBook
    
    public var key: String {
        switch self {
        case .about:
            return "about"
        case .preferences:
            return "preferences"
        case .exportSnippetToFile:
            return "exportSnippet"
        case .exportSnippetToClipboard:
            return "exportSnippetToClipboard"
        case .markdownPage:
            return "markdownPage"
        case .playgroundBook:
            return "playgroundBook"
        }
    }
}
