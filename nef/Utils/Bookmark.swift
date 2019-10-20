//  Copyright © 2019 The nef Authors.

import Foundation

@propertyWrapper
struct Bookmark {
    private let key: String
    private let storage = UserDefaults.standard
    
    init(key: String) {
        self.key = key
    }

    var wrappedValue: URL? {
        get {
            guard let url = retrieveBookmark(), existItem(at: url) else { return nil }
            openAccessingBookmark()
            return url
        }
        set {
            guard let url = newValue else { return }
            closeAccessingBookmark()
            persistBookmark(url: url)
        }
    }
    
    // MARK: private methods <storage>
    private func persistBookmark(url: URL) {
        let data = try? url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
        storage.setValue(data, forKey: key)
    }
    
    private func retrieveBookmark() -> URL? {
        guard let data = storage.data(forKey: key) else { return nil }
        var bookmarkDataIsStale: Bool = true
        return try? URL(resolvingBookmarkData: data, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &bookmarkDataIsStale)
    }
    
    // MARK: private methods <grant access>
    private func openAccessingBookmark() {
        _ = retrieveBookmark()?.startAccessingSecurityScopedResource()
    }
    
    private func closeAccessingBookmark() {
        retrieveBookmark()?.stopAccessingSecurityScopedResource()
    }
    
    // MARK: helpers
    private func existItem(at url: URL) -> Bool {
        FileManager.default.fileExists(atPath: url.path)
    }
}
