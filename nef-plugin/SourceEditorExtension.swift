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
    
    static var commands: [Command] = {
        #if DEBUG
        return debugCommandDefinitions()
        #else
        return appstoreCommandDefinitions()
        #endif
    }()
    
    static func debugCommandDefinitions() -> [Command] {
        [.preferences,
         .exportSnippet(selection: ""),
         .exportSnippetToClipboard(selection: ""),
         .markdownPage(playground: ""),
         .playgroundBook(package: "")]
    }
    
    static func appstoreCommandDefinitions() -> [Command] {
        [.preferences,
         .exportSnippet(selection: ""),
         .exportSnippetToClipboard(selection: ""),
         .markdownPage(playground: "")]
    }
}


// MARK: - Command <XCSourceEditorCommandDefinition>
extension SourceEditorModels.Command: XCSourceEditorCommandDefinition {
    public var displayName: String {
        switch self {
        case .preferences:
            return "Preferences"
        case .exportSnippet:
            return "Code selection → Image (File)"
        case .exportSnippetToClipboard:
            return "Code selection → Image (Clipboard)"
        case .markdownPage:
            return "Playground       → Markdown"
        case .playgroundBook:
            return "Swift Package  → Playground Book (iPad)"
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
