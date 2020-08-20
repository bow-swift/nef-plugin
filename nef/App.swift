//  Copyright © 2020 The nef Authors.

import SwiftUI
import SourceEditorModels

struct App {
    private let assembler: Assembler
    
    init(assembler: Assembler) {
        self.assembler = assembler
    }
    
    // MARK: life-cycle
    func didFinishLaunching(command: Command) -> NefWindow? {
        switch command {
        case .preferences:
            return preferencesWindow()
        case .exportSnippet(let selection):
            return carbonWindow(code: selection)
        case .exportSnippetToClipboard(let selection):
            return clipboardCarbonWindow(code: selection)
        case .markdownPage(let page):
            return markdownPageWindow(page: page)
        case .playgroundBook(let packageContent):
            return playgroundBookWindow(packageContent: packageContent)
        case .notification(let userInfo, let action):
            return notificationWindow(userInfo: userInfo, action: action)
        case .about:
            return aboutWindow()
        }
    }
    
    func didFinishLaunching() -> NefWindow? {
        didFinishLaunching(command: .about)
    }
    
    // MARK: Routes
    private func aboutWindow() -> NefWindow? {
        .view(NSHostingView(rootView: assembler.resolveAboutView()),
              config: .init(title: i18n.WindowTitle.about,
                            rect: NSRect(x: 0, y: 0, width: 350, height: 350),
                            needMenu: false))
    }
    
    private func preferencesWindow() -> NefWindow? {
        .view(NSHostingView(rootView: assembler.resolvePreferencesView()),
              config: .init(title: i18n.WindowTitle.preferences,
                            rect: NSRect(x: 0, y: 0, width: 800, height: 768),
                            needMenu: true))
    }
    
    private func carbonWindow(code: String) -> NefWindow? {
        CarbonController(code: code, output: .file)
            .flatMap(NefWindow.controller)
    }
    
    private func clipboardCarbonWindow(code: String) -> NefWindow? {
        CarbonController(code: code, output: .clipboard)
            .flatMap(NefWindow.controller)
    }
    
    private func markdownPageWindow(page: String) -> NefWindow? {
        MarkdownPageController(page: page)
            .flatMap(NefWindow.controller)
    }
    
    private func playgroundBookWindow(packageContent: String) -> NefWindow? {
        guard let controller = PlaygroundBookController(packageContent: packageContent) else { return nil }
        
        let view = NSHostingView(rootView: assembler.resolvePlaygroundBookView())
        let config = NefWindow.Config(title: i18n.WindowTitle.playgroundBook,
                                      rect: NSRect(x: 0, y: 0, width: 800, height: 150),
                                      needMenu: true)
        
        return .viewController(view: view, controller: controller, config: config)
    }
    
    private func notificationWindow(userInfo: [String: Any], action: String) -> NefWindow? {
        ImageNotificationController(userInfo: userInfo, action: action)
            .flatMap(NefWindow.controller)
    }
}


extension i18n {
    enum WindowTitle {
        static let preferences = NSLocalizedString("preferences", comment: "")
        static let about = NSLocalizedString("about", comment: "")
        static let playgroundBook = NSLocalizedString("playground-book", comment: "")
    }
}


//    enum Error: Swift.Error {
//        case carbon
//        case markdown
//        case swiftPlayground
//        case notification
//    }
