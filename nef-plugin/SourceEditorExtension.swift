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
         .exportSnippetToFile(selection: ""),
         .exportSnippetToClipboard(selection: ""),
         .markdownPage(playground: ""),
         .playgroundBook(package: "")]
    }
    
    static func appstoreCommandDefinitions() -> [Command] {
        [.preferences,
         .exportSnippetToFile(selection: ""),
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
        case .exportSnippetToFile:
            return "Code selection to Image"
        case .exportSnippetToClipboard:
            return "Copy selection to Image clipboard"
        case .markdownPage:
            return "Export Playground page to markdown"
        case .playgroundBook:
            return "Playground Book from Swift Package"
        case .about, .notification:
            return ""
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
