//  Copyright © 2019 The nef Authors.

import AppKit

class OpenPanel {
    private let dialog: NSOpenPanel
    @Bookmark(key: Key.bookmark) private var bookmark: URL?
    
    init() {
        self.dialog = NSOpenPanel()
        
        dialog.canChooseFiles = false
        dialog.canChooseDirectories = true
        dialog.allowsMultipleSelection = false
    }
    
    func writableFolder(create: Bool) -> URL? {
        guard let bookmark = bookmark else {
            return create ? selectWritableFolder() : nil
        }
        
        return bookmark
    }
    
    func selectWritableFolder() -> URL? {
        guard dialog.runModal() == .OK,
              let selection = dialog.url else { return nil }
        
        bookmark = selection
        return selection
    }
    
    // MARK: constants
    private enum Key {
        static let bookmark = "OpenPanel-writableFolder-bookmark"
    }
}
