//  Copyright © 2019 The nef Authors.

import XcodeKit

struct Editor {
    let code: String
    let contentUTI: ContentUTI
    let selection: String?
    
    enum ContentUTI: String {
        case package = "com.apple.dt.swiftpm-package-manifest"
        case swift = "public.swift-source"
        case objc = "public.objective-c-source"
        case h = "public.c-header"
        case hpp = "public.c-plus-plus-header"
        case c = "public.c-source"
        case cpp = "public.c-plus-plus-source"
        case metal = "com.apple.metal"
        case unknown
    }
}


extension Editor {
    
    init?(invocation: XCSourceEditorCommandInvocation) {
        guard let textRange = invocation.buffer.selections.firstObject as? XCSourceTextRange else { return nil }
        let lines = invocation.buffer.lines.map { "\($0)" }
        
        self.selection = Editor.selection(textRange: textRange, lines: lines)
        self.code = invocation.buffer.completeBuffer
        self.contentUTI = Editor.ContentUTI(rawValue: invocation.buffer.contentUTI) ?? .unknown
    }
    
    // MARK: - Helpers methods
    private static func selection(textRange: XCSourceTextRange, lines: [String]) -> String? {
        let hasSelection = (textRange.start.column != textRange.end.column) ||
            (textRange.start.column == 0 && textRange.end.column == 0 && textRange.start.line != textRange.end.line)
        guard lines.count > 0, hasSelection else { return nil }
        
        let start = textRange.start.line
        let end = min(textRange.end.line + 1, lines.count)
        let selection = lines[start..<end].joined().trimmingCharacters(in: .newlines)
        let selectionTrimmed = removeLeadingExtraMargin(selection)
        
        return selectionTrimmed
    }
    
    private static func removeLeadingExtraMargin(_ code: String) -> String {
        let lines = code.components(separatedBy: "\n")
        guard let firstLine = lines.first,
              let leading = firstLine.map({ $0 }).enumerated().first(where: { $0.element != " " })?.offset else { return code }
        
        return lines.map { $0.dropFirst(leading) }.joined(separator: "\n")
    }
}
