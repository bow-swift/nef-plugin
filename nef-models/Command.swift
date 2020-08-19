//  Copyright © 2020 The nef Authors.

import Foundation

public enum Command {
    case preferences
    case exportSnippet(selection: String)
    case exportSnippetToClipboard(selection: String)
    case markdownPage(playground: String)
    case playgroundBook(package: String)
    
    public var key: String {
        switch self {
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
        }
    }
    
    public var code: String {
        switch self {
        case .preferences:
            return ""
        case .exportSnippet(let seleccion):
            return seleccion
        case .exportSnippetToClipboard(let selection):
            return selection
        case .markdownPage(let playground):
            return playground
        case .playgroundBook(let package):
            return package
        }
    }
}
