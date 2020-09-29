//  Copyright © 2020 The nef Authors.

import Foundation
import SourceEditorModels

enum Command {
    case about
    case preferences
    case exportSnippetToFile(selection: String)
    case exportSnippetToClipboard(selection: String)
    case markdownPage(playground: String)
    case playgroundBook(package: String)
    case notification(userInfo: [String: Any], action: String)
}

extension Command {
    var menuKey: String {
        switch self {
        case .about:
            return MenuEditorCommand.about.key
        case .preferences:
            return MenuEditorCommand.preferences.key
        case .exportSnippetToFile:
            return MenuEditorCommand.exportSnippetToFile.key
        case .exportSnippetToClipboard:
            return MenuEditorCommand.exportSnippetToClipboard.key
        case .markdownPage:
            return MenuEditorCommand.markdownPage.key
        case .playgroundBook:
            return MenuEditorCommand.playgroundBook.key
        case .notification:
            return ""
        }
    }
}

extension URLQueryItem {
    var command: Command? {
        switch name {
        case MenuEditorCommand.preferences.key:
            return .preferences
        case MenuEditorCommand.exportSnippetToFile.key:
            return value.flatMap(Command.exportSnippetToFile)
        case MenuEditorCommand.exportSnippetToClipboard.key:
            return value.flatMap(Command.exportSnippetToClipboard)
        case MenuEditorCommand.markdownPage.key:
            return value.flatMap(Command.markdownPage)
        case MenuEditorCommand.playgroundBook.key:
            return value.flatMap(Command.playgroundBook)
        case MenuEditorCommand.about.key:
            return .about
        default:
            return nil
        }
    }
}
