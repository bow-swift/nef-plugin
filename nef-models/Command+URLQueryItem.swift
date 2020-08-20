//  Copyright © 2020 The nef Authors.

import Foundation

public extension Command {
    var item: URLQueryItem {
        switch self {
        case .exportSnippet(let selection):
            return URLQueryItem(name: key, value: selection)
        case .exportSnippetToClipboard(let selection):
            return URLQueryItem(name: key, value: selection)
        case .markdownPage(let playground):
            return URLQueryItem(name: key, value: playground)
        case .playgroundBook(let package):
            return URLQueryItem(name: key, value: package)
        case .preferences, .about, .notification:
            return URLQueryItem(name: key, value: "")
        }
    }
}

public extension URLQueryItem {
    var command: Command? {
        switch name {
        case Command.about.key:
            return .about
        case Command.preferences.key:
            return .preferences
        case Command.exportSnippet(selection: "").key:
            return value.flatMap(Command.exportSnippet)
        case Command.exportSnippetToClipboard(selection: "").key:
            return value.flatMap(Command.exportSnippetToClipboard)
        case Command.markdownPage(playground: "").key:
            return value.flatMap(Command.markdownPage)
        case Command.playgroundBook(package: "").key:
            return value.flatMap(Command.playgroundBook)
        default:
            return nil
        }
    }
}
