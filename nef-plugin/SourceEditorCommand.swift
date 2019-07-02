//  Copyright © 2019 The nef Authors.

import Foundation
import XcodeKit

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        guard let textRange = invocation.buffer.selections.firstObject as? XCSourceTextRange else {
            completionHandler(nil)
            return
        }
        
        let lines = invocation.buffer.lines.map { "\($0)" }
        
        switch invocation.commandIdentifier {
        case Command.preferences:
            preferences()
        case Command.exportSnippet:
            exportSnippet(textRange: textRange, lines: lines)
        default:
            break
        }
        
        completionHandler(nil)
    }
    
    // MARK: Commands
    private func preferences() {
        // TODO
    }
    
    private func exportSnippet(textRange: XCSourceTextRange, lines: [String]) {
        let hasSelection = (textRange.start.column != textRange.end.column) ||
            (textRange.start.column == 0 && textRange.end.column == 0 && textRange.start.line != textRange.end.line)
        guard lines.count > 0, hasSelection else { return }
        
        let start = textRange.start.line
        let end = textRange.end.line + 1
        let selection = lines[start..<end].joined().trimmingCharacters(in: .newlines)
        
        // TODO: export using carbon
        
    }
    
    // MARK: Constants
    enum Command { // defined in Info.plist
        static let preferences = "preferences"
        static let exportSnippet = "carbon"
    }
}
