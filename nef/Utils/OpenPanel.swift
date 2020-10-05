//  Copyright © 2019 The nef Authors.

import AppKit
import BowEffects

typealias BookmarkResource = Resource<IOPartial<OpenPanelError>, URL>

enum OpenPanelError: Error {
    case denied
    case unknown
}

class OpenPanel {
    private let dialog: NSOpenPanel
    @Bookmark(key: Key.bookmark) private var bookmark: URL?
    
    init() {
        self.dialog = NSOpenPanel()
        
        dialog.canChooseFiles = false
        dialog.canChooseDirectories = true
        dialog.allowsMultipleSelection = false
    }
    
    func writableFolder(create: Bool) -> BookmarkResource {
        Resource.from(acquire: {
            IO.invoke {
                if self.bookmark == nil && create { self.bookmark = self.runUserSelectionModal() }
                guard let url = self.bookmark else { throw OpenPanelError.denied }
                url.openAccessingResource()
                return url
            }
        }, release: { url, _ in
            IO.invoke {
                url.closeAccessingResource()
            }
        })
    }
    
    func selectWritableFolder() -> BookmarkResource {
        Resource.from(acquire: {
            IO.invoke {
                self.bookmark = self.runUserSelectionModal()
                guard let url = self.bookmark else { throw OpenPanelError.denied }
                url.openAccessingResource()
                return url
            }
        }, release: { url, _ in
            IO.invoke {
                url.closeAccessingResource()
            }
        })
    }
    
    // MARK: private methods
    private func runUserSelectionModal() -> URL? {
        runSync {
            guard self.dialog.runModal() == .OK,
                  let url = self.dialog.url else { return nil }
            return url
        }
    }
    
    // MARK: constants
    private enum Key {
        static let bookmark = "OpenPanel-writableFolder-bookmark"
    }
}
