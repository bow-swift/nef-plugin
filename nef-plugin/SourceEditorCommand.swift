//  Copyright © 2019 The nef Authors.

import Foundation
import XcodeKit
import SourceEditorModels

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void) -> Void {
        guard let command = SourceEditorExtension.commands.first(where: { $0.identifierKey == invocation.commandIdentifier }) else {
            completionHandler(EditorError.invalidCommand); return
        }
        guard let editor = Editor(invocation: invocation) else {
            completionHandler(EditorError.unknown); return
        }
        
        _ = schema(command: command, editor: editor)
            .mapError { error in terminateError(error, completion: completionHandler) }
            .map { schema in schema.open() }
            .map { task in terminate(duration: task.estimatedDuration, completion: completionHandler) }
    }
    
    private func schema(command: Command, editor: Editor) -> Result<AppScheme, EditorError> {
        switch command {
        case .preferences:
            return preferences()
        case .exportSnippet:
            return exportSnippet(editor: editor)
        case .exportSnippetToClipboard:
            return exportSnippetToClipboard(editor: editor)
        case .markdownPage:
            return markdownPage(editor: editor)
        case .playgroundBook:
            return playgroundBook(editor: editor)
        }
    }

    // MARK: commands
    private func preferences() -> Result<AppScheme, EditorError> {
        .success(AppScheme(command: .preferences))
    }
    
    private func exportSnippet(editor: Editor) -> Result<AppScheme, EditorError> {
        guard Reachability.isConnected else { return .failure(.internetConnection) }
        guard let selection = editor.selection else { return .failure(.selection) }
        
        let appscheme = AppScheme(command: .exportSnippet(selection: selection),
                                  estimatedDuration: .now() + .seconds(5))
        
        return .success(appscheme)
    }
    
    private func exportSnippetToClipboard(editor: Editor) -> Result<AppScheme, EditorError> {
        guard Reachability.isConnected else { return .failure(.internetConnection) }
        guard let selection = editor.selection else { return .failure(.selection) }
        
        let appscheme = AppScheme(command: .exportSnippetToClipboard(selection: selection),
                                  estimatedDuration: .now() + .seconds(5))
        
        return .success(appscheme)
    }
    
    private func markdownPage(editor: Editor) -> Result<AppScheme, EditorError> {
        guard editor.contentUTI == .playground || editor.contentUTI == .playgroundPage else {
            return .failure(.playgroundNotFound)
        }
        
        let appscheme = AppScheme(command: .markdownPage(playground: editor.code))
        return .success(appscheme)
    }
    
    private func playgroundBook(editor: Editor) -> Result<AppScheme, EditorError> {
        guard editor.contentUTI == .package else {
            return .failure(.packageNotFound)
        }
        
        let appscheme = AppScheme(command: .playgroundBook(package: editor.code))
        return .success(appscheme)
    }
    
    // MARK: helpers
    func terminate(duration: DispatchTime, completion: @escaping (Error?) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: duration) {
            completion(nil)
        }
    }
    
    func terminateError(_ error: EditorError, completion: @escaping (Error?) -> Void) -> Error {
        DispatchQueue.main.async {
            let e = NSError(domain: Bundle.namespace, code: error.rawValue, userInfo: [NSLocalizedDescriptionKey: error.localizedDescription])
            completion(e)
        }
        
        return error
    }
}
