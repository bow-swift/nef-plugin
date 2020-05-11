//  Copyright © 2019 The nef Authors.

import Foundation
import XcodeKit

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void) -> Void {
        guard let command = SourceEditorExtension.Command(rawValue: invocation.commandIdentifier) else { completionHandler(EditorError.invalidCommand); return }
        guard let editor = Editor(invocation: invocation) else { completionHandler(EditorError.unknown); return }
        
        process(command: command, editor: editor, completion: completionHandler)
    }
    
    private func process(command: SourceEditorExtension.Command, editor: Editor, completion: @escaping (Error?) -> Void) {
        switch command {
        case .preferences:
            preferences(completion: completion)
        case .exportSnippet:
            carbon(editor: editor, completion: completion)
        case .exportSnippetToPasteboard:
            pasteboardCarbon(editor: editor, completion: completion)
        case .markdownPage:
            markdownPage(editor: editor, completion: completion)
        case .playgroundBook:
            playgroundBook(editor: editor, completion: completion)
        }
    }

    // MARK: commands
    private func preferences(completion: @escaping (Error?) -> Void) {
        AppScheme(action: .preferences).run()
        terminate(deadline: .now(), completion)
    }
    
    private func carbon(editor: Editor, completion: @escaping (Error?) -> Void) {
        guard Reachability.isConnected else { completion(EditorError.internetConnection); return }
        guard let selection = editor.selection else { completion(EditorError.selection); return }
        
        AppScheme(action: .carbon(selection: selection)).run()
        terminate(deadline: .now() + .seconds(5), completion)
    }
    
    private func pasteboardCarbon(editor: Editor, completion: @escaping (Error?) -> Void) {
        guard Reachability.isConnected else { completion(EditorError.internetConnection); return }
        guard let selection = editor.selection else { completion(EditorError.selection); return }
        
        AppScheme(action: .pasteboardCarbon(selection: selection)).run()
        terminate(deadline: .now() + .seconds(5), completion)
    }
    
    private func markdownPage(editor: Editor, completion: @escaping (Error?) -> Void) {
        guard editor.contentUTI == .playground || editor.contentUTI == .playgroundPage else { completion(EditorError.noPlayground); return }
        
        AppScheme(action: .markdownPage(playground: editor.code)).run()
        terminate(deadline: .now(), completion)
    }
    
    private func playgroundBook(editor: Editor, completion: @escaping (Error?) -> Void) {
        guard editor.contentUTI == .package else { completion(EditorError.noPackage); return }
        
        AppScheme(action: .playgroundBook(package: editor.code)).run()
        terminate(deadline: .now(), completion)
    }
    
    // MARK: helpers
    private func terminate(deadline: DispatchTime, _ completion: @escaping (Error?) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: deadline) { completion(nil) }
    }
    
    // MARK: - Constants
    enum EditorError {
        static let unknown = NSError(domain: "nef editor", code: 1, userInfo: [NSLocalizedDescriptionKey : NSLocalizedString("Undefined error", comment: "")])
        static let invalidCommand = NSError(domain: "nef editor", code: 2, userInfo: [NSLocalizedDescriptionKey : NSLocalizedString("This command has not being implemented", comment: "")])
        static let selection = NSError(domain: "nef editor", code: 3, userInfo: [NSLocalizedDescriptionKey : NSLocalizedString("You must make a code selection first", comment: "")])
        static let internetConnection = NSError(domain: "nef editor", code: 4, userInfo: [NSLocalizedDescriptionKey : NSLocalizedString("You can not create a code snippet without an internet connection", comment: "")])
        static let noPackage = NSError(domain: "nef editor", code: 5, userInfo: [NSLocalizedDescriptionKey : NSLocalizedString("This command only works on Swift Package files", comment: "")])
        static let noPlayground = NSError(domain: "nef editor", code: 6, userInfo: [NSLocalizedDescriptionKey : NSLocalizedString("This command only works on Playground", comment: "")])
    }
}
