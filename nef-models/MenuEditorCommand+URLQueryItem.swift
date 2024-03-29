//  Copyright © 2020 The nef Authors.

import Foundation

public extension MenuEditorCommand {
    func item(code: String) -> URLQueryItem {
        switch self {
        case .exportSnippetToFile, .exportSnippetToClipboard, .markdownPage, .playgroundBook:
            return URLQueryItem(name: key, value: code)
        case .preferences, .about:
            return URLQueryItem(name: key, value: "")
        }
    }
}
