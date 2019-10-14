//  Copyright © 2019 The nef Authors.

import AppKit

class OpenPanel {
    private let dialog: NSOpenPanel
    private let storage: UserDefaults
    
    init() {
        self.storage = UserDefaults.standard
        self.dialog = NSOpenPanel()
        
        dialog.canChooseFiles = false
        dialog.canChooseDirectories = true
        dialog.allowsMultipleSelection = false
    }
    
    func writableFolder() -> URL? {
        guard let url = retrieveBookmark(), existFolder(at: url) else {
            return selectWritableFolder()
        }
        
        return url
    }
    
    // MARK: private methods
    private func selectWritableFolder() -> URL? {
        guard dialog.runModal() == .OK,
              let selection = dialog.url else { return nil }
        
        closeAccessingBookmark()
        persistBookmark(url: selection)
        
        return selection
    }
    
    private func persistBookmark(url: URL) {
        let data = try? url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
        storage.setValue(data, forKey: Key.bookmark)
    }
    
    private func retrieveBookmark() -> URL? {
        guard let data = storage.data(forKey: Key.bookmark) else { return nil }
        var bookmarkDataIsStale: Bool = true
        let url = try? URL(resolvingBookmarkData: data, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &bookmarkDataIsStale)
        _ = url?.startAccessingSecurityScopedResource()
        return url
    }
    
    private func closeAccessingBookmark() {
        retrieveBookmark()?.stopAccessingSecurityScopedResource()
    }
    
    private func existFolder(at url: URL) -> Bool {
        FileManager.default.fileExists(atPath: url.path)
    }
    
    // MARK: constants
    private enum Key {
        static let bookmark = "OpenPanel-writableFolder-bookmark"
    }
}
