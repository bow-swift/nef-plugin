//  Copyright © 2019 The nef Authors.

import Foundation
import XcodeKit
import SourceEditorModels

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void) -> Void {
        perform(with: invocation)
            .fold(
                { error in
                    terminateError(error, completion: completionHandler)
                },
                { schema in
                    terminate(deadline: .now() + .seconds(4), completion: completionHandler)
                }
            )
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
        case .exportSnippetToFile:
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
        
        let appscheme = AppScheme(command: .exportSnippetToFile(selection: selection))
        return .success(appscheme)
    }
    
    private func exportSnippetToClipboard(editor: Editor) -> Result<AppScheme, EditorError> {
        guard Reachability.isConnected else { return .failure(.internetConnection) }
        guard let selection = editor.selection else { return .failure(.selection) }
        
        let appscheme = AppScheme(command: .exportSnippetToClipboard(selection: selection))
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
    
    // MARK: - Terminate <helpers>
    private func terminate(deadline: DispatchTime, completion: @escaping (Error?) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            completion(nil)
        }
    }
    
    private func terminateError(_ error: EditorError, completion: @escaping (Error?) -> Void) {
        DispatchQueue.main.async {
            let e = NSError(domain: Bundle.namespace, code: error.rawValue, userInfo: [NSLocalizedDescriptionKey: error.localizedDescription])
            completion(e)
        }
    }
}
