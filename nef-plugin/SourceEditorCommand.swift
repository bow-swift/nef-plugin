//  Copyright © 2019 The nef Authors.

import Foundation
import XcodeKit
import SourceEditorModels

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void) -> Void {
        perform(with: invocation).terminate(completion: completionHandler)
    }
    
    private func perform(with invocation: XCSourceEditorCommandInvocation) -> Result<AppScheme, EditorError> {
        guard let command = SourceEditorExtension.commands.first(where: { $0.identifierKey == invocation.commandIdentifier }) else {
            return .failure(.invalidCommand)
        }
        
        guard let editor = Editor(invocation: invocation) else {
            return .failure(.unknown)
        }
        
        return appScheme(command: command, editor: editor).map { scheme in scheme.open() }
    }
    
    private func appScheme(command: Command, editor: Editor) -> Result<AppScheme, EditorError> {
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
        case .about, .notification:
            return .failure(.unknown)
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
}

// MARK: - Terminate <helpers>
extension Result where Success == AppScheme, Failure == EditorError {
    
    @discardableResult
    func terminate(completion: @escaping (Error?) -> Void) -> Result {
        flatMapError { error in
            terminateError(error, completion: completion)
        }.flatMap { schema in
            terminate(duration: schema.estimatedDuration, completion: completion)
        }
    }
    
    private func terminate(duration: DispatchTime, completion: @escaping (Error?) -> Void) -> Result {
        DispatchQueue.main.asyncAfter(deadline: duration) {
            completion(nil)
        }
        
        return self
    }
    
    private func terminateError(_ error: Failure, completion: @escaping (Error?) -> Void) -> Result {
        DispatchQueue.main.async {
            let e = NSError(domain: Bundle.namespace, code: error.rawValue, userInfo: [NSLocalizedDescriptionKey: error.localizedDescription])
            completion(e)
        }
        
        return self
    }
}
