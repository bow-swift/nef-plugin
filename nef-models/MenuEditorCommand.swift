//  Copyright © 2020 The nef Authors.

import Foundation

public enum MenuEditorCommand: String {
    case about
    case preferences
    case exportSnippetToFile
    case exportSnippetToClipboard
    case markdownPage
    case playgroundBook
    
    public var key: String { rawValue }
}
