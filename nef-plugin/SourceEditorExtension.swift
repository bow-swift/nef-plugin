//  Copyright © 2019 The nef Authors.

import Foundation
import XcodeKit

class SourceEditorExtension: NSObject, XCSourceEditorExtension {
    
    var commandDefinitions: [[XCSourceEditorCommandDefinitionKey: Any]] {
        return [preferences, carbon]
    }
    
    // MARK: editor options <nef>
    private let nefClassName = NefEditorCommand.className()
    
    private var preferences: [XCSourceEditorCommandDefinitionKey: Any] {
        return [.identifierKey: Command.preferences.rawValue,
                .classNameKey: nefClassName,
                .nameKey: i18n.preferences]
    }
    
    private var carbon: [XCSourceEditorCommandDefinitionKey: Any] {
        return [.identifierKey: Command.exportSnippet.rawValue,
                .classNameKey: nefClassName,
                .nameKey: i18n.exportSnippet]
    }
    
    // MARK: - Constants
    enum i18n {
        static let preferences = NSLocalizedString("Preferences", comment: "")
        static let exportSnippet = NSLocalizedString("Export code snippet", comment: "")
    }
    
    enum Command: String {
        case preferences
        case exportSnippet
    }
}
