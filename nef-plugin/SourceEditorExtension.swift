//  Copyright © 2019 The nef Authors.

import Foundation
import XcodeKit

class SourceEditorExtension: NSObject, XCSourceEditorExtension {
    
    // MARK: editor options <nef>
    enum Command: String {
        case preferences
        case exportSnippet
        case exportSnippetToClipboard
        case markdownPage
        case playgroundBook
    }
}
