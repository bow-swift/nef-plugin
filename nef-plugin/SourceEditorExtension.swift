//  Copyright © 2019 The nef Authors.

import Foundation
import XcodeKit
import SourceEditorModels

public protocol XCSourceEditorCommandDefinition {
    var displayName: String { get }
    var identifierKey: String { get }
    var editorDefinitionKey: [XCSourceEditorCommandDefinitionKey : Any] { get }
}


class SourceEditorExtension: NSObject, XCSourceEditorExtension {
    var commandDefinitions: [[XCSourceEditorCommandDefinitionKey : Any]] {
        SourceEditorExtension.commands.map(\.editorDefinitionKey)
    }
    
    static var commands: [MenuEditorCommand] = {
        #if DEBUG
        return debugCommandDefinitions()
        #else
        return appstoreCommandDefinitions()
        #endif
    }()
    
    static func debugCommandDefinitions() -> [MenuEditorCommand] {
        [.preferences,
         .exportSnippetToFile,
         .exportSnippetToClipboard,
         .markdownPage,
         .playgroundBook]
    }
    
    static func appstoreCommandDefinitions() -> [MenuEditorCommand] {
        [.preferences,
         .exportSnippetToFile,
         .exportSnippetToClipboard,
         .markdownPage]
    }
}


// MARK: - Command <XCSourceEditorCommandDefinition>
extension SourceEditorModels.MenuEditorCommand: XCSourceEditorCommandDefinition {
    public var displayName: String {
        switch self {
        case .preferences:
            return "Preferences"
        case .exportSnippetToFile:
            return "Code selection to Image"
        case .exportSnippetToClipboard:
            return "Copy selection to Image clipboard"
        case .markdownPage:
            return "Export Playground page to markdown"
        case .playgroundBook:
            return "Playground Book from Swift Package"
        case .about:
            return "About"
        }
    }
    
    public var identifierKey: String {
        "\(Bundle.namespace).\(key)"
            .replacingOccurrences(of: "_", with: "-")
            .replacingOccurrences(of: " ", with: "-")
    }
    
    public var editorDefinitionKey: [XCSourceEditorCommandDefinitionKey : Any] {
        [.identifierKey: identifierKey,
         .classNameKey: classNameKey,
         .nameKey: displayName]
    }
    
    private var classNameKey: String {
        SourceEditorCommand.className()
    }
}
