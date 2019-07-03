//  Copyright © 2019 The nef Authors.

import Foundation
import XcodeKit

class NefEditorCommand: NSObject, XCSourceEditorCommand {
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        defer { completionHandler(nil) }
        guard let command = SourceEditorExtension.Command(rawValue: invocation.commandIdentifier) else { return }
        guard let textRange = invocation.buffer.selections.firstObject as? XCSourceTextRange else { return }
        
        let lines = invocation.buffer.lines.map { "\($0)" }
        let selection = userSelection(textRange: textRange, lines: lines)
        
        switch command {
        case .preferences: preferences(text: selection)
        case .exportSnippet: carbon(text: selection)
        }
    }
    
    // MARK: Commands
    private func preferences(text: String) {
        // TODO
        print("PREFERENCES")
    }
    
    private func carbon(text: String) {
        // TODO: export using carbon
        print("CARBON")
    }
    
    // MARK: private methods
    private func userSelection(textRange: XCSourceTextRange, lines: [String]) -> String {
        let hasSelection = (textRange.start.column != textRange.end.column) ||
            (textRange.start.column == 0 && textRange.end.column == 0 && textRange.start.line != textRange.end.line)
        guard lines.count > 0, hasSelection else { return lines.joined() }
        
        let start = textRange.start.line
        let end = textRange.end.line + 1
        let selection = lines[start..<end].joined().trimmingCharacters(in: .newlines)
        
        return selection
    }
    
    // MARK: Constants
    enum Command { // defined in Info.plist
        static let preferences = "preferences"
        static let exportSnippet = "carbon"
    }
}
