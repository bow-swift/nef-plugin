//  Copyright © 2019 The nef Authors.

import Foundation
import XcodeKit

class SourceEditorExtension: NSObject, XCSourceEditorExtension {
    
    // MARK: editor options <nef>
    enum Command: String {
        case preferences
        case exportSnippet
    }
    
    // MARK: - Constants
    enum i18n {
        static let preferences = NSLocalizedString("preferences", comment: "")
        static let exportSnippet = NSLocalizedString("plugin_carbon", comment: "")
    }
}
