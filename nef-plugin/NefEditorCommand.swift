//  Copyright © 2019 The nef Authors.

import Foundation
import XcodeKit
import AppKit

class NefEditorCommand: NSObject, XCSourceEditorCommand {
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void) -> Void {
        defer { completionHandler(nil) }
        guard let command = SourceEditorExtension.Command(rawValue: invocation.commandIdentifier) else { return }
        guard let textRange = invocation.buffer.selections.firstObject as? XCSourceTextRange else { return }
        
        let lines = invocation.buffer.lines.map { "\($0)" }
        let selection = userSelection(textRange: textRange, lines: lines)
        
        switch command {
        case .preferences: preferences()
        case .exportSnippet: carbon(text: selection)
        }
    }
    
    // MARK: Commands
    private func preferences() {
        // TODO
        print("PREFERENCES")
    }
    
    private func carbon(text: String) {
        let codeItem = URLQueryItem(name: Operation.carbon.rawValue, value: text)
        var urlComponents = URLComponents()
        urlComponents.scheme = Constants.scheme
        urlComponents.host = "xcode"
        urlComponents.queryItems = [codeItem]
        
        try! NSWorkspace.shared.open(urlComponents.url!,
                                     options: .newInstance,
                                     configuration: [:])
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
    enum Constants {
        static let scheme = "nef-plugin"
        static let bundleIdentifier = "com.47deg.nef"
    }
    
    enum Operation: String {
        case carbon
    }
}
