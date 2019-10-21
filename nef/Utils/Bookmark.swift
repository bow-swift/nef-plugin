//  Copyright © 2019 The nef Authors.

import Foundation

@propertyWrapper
struct Bookmark {
    private let key: String
    private let storage: UserDefaults
    
    init(key: String, storage: UserDefaults = UserDefaults.standard) {
        self.key = key
        self.storage = storage
    }

    var wrappedValue: URL? {
        get {
            guard let url = retrieveBookmark(), existItem(at: url) else { return nil }
            return url
        }
        set {
            guard let url = newValue else { return }
            persistBookmark(url: url)
        }
    }
    
    // MARK: private methods <storage>
    private func persistBookmark(url: URL) {
        guard let data = try? url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil) else { return }
        storage.setValue(data, forKey: key)
    }
    
    private func retrieveBookmark() -> URL? {
        guard let data = storage.data(forKey: key) else { return nil }
        var bookmarkDataIsStale: Bool = true
        return try? URL(resolvingBookmarkData: data, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &bookmarkDataIsStale)
    }
    
    // MARK: helpers
    private func existItem(at url: URL) -> Bool {
        FileManager.default.fileExists(atPath: url.path)
    }
}


extension URL {
    func openAccessingResource() {
        _ = self.startAccessingSecurityScopedResource()
    }
    
    func closeAccessingResource() {
        self.stopAccessingSecurityScopedResource()
    }
}
