//  Copyright © 2020 The nef Authors.

import SwiftUI
import Bow
import BowEffects
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
            return preferencesView()
//        case .exportSnippet(let selection):
//            return carbonView(code: selection)
//        case .exportSnippetToClipboard(let selection):
//            return clipboardCarbonView(code: selection)
//        case .markdownPage(let playground):
//            return markdownPageView(playground: playground)
//        case .playgroundBook(let package):
//            return playgroundBookView(package: package)
//        case .notification(let userInfo, let action):
//            return notificationView(userInfo: userInfo, action: action)
        case .about:
            return aboutView()
            
            
        default:
            return nil
        }
    }
    
    func didFinishLaunching() -> NefWindow? {
        didFinishLaunching(command: .about)
    }
    
    // MARK: Views
    private func aboutView() -> NefWindow {
        .view(NSHostingView(rootView: assembler.resolveAboutView()),
              config: .init(title: i18n.WindowTitle.about,
                            rect: NSRect(x: 0, y: 0, width: 350, height: 350),
                            needMenu: false))
    }
    
    private func preferencesView() -> NefWindow {
        .view(NSHostingView(rootView: assembler.resolvePreferencesView()),
              config: .init(title: i18n.WindowTitle.preferences,
                            rect: NSRect(x: 0, y: 0, width: 800, height: 768),
                            needMenu: true))
    }
}

extension i18n {
    enum WindowTitle {
        static let preferences = NSLocalizedString("preferences", comment: "")
        static let about = NSLocalizedString("about", comment: "")
        static let playgroundBook = NSLocalizedString("playground-book", comment: "")
    }
}







    
    
//
//    private func carbonDidFinishLaunching(code: String) {
//        guard !code.isEmpty else { terminate(); return }
//        emptyDidFinishLaunching()
//
//        carbonIO(code: code).unsafeRunAsync(on: .global(qos: .userInitiated)) { output in
//            _ = output.map(self.showFile)
//            self.terminate()
//        }
//    }
//
//    private func clipboardCarbonDidFinishLaunching(code: String) {
//        guard !code.isEmpty else { terminate(); return }
//        emptyDidFinishLaunching()
//
//        let config = Clipboard.Config(clipboard: .general, notificationCenter: .current())
//
//        assembler.resolveCarbon(code: code).env()^.mapError { _ in .carbon }
//            .flatMap(clipboardCarbonIO)^
//            .provide(config)
//            .unsafeRunAsync(on: .global(qos: .userInitiated)) { output in
//                _ = output.map { _ in
//                    self.terminate()
//                }
//        }
//    }
//
//    private func markdownPageDidFinishLaunching(playground: String) {
//        guard !playground.isEmpty else { terminate(); return }
//
//        _ = markdownIO(playground: playground)
//                .unsafeRunSyncEither()
//                .map(self.showFile)
//        self.terminate()
//    }
//
//    private func playgroundBookDidFinishLaunching(package: String) {
//        guard !package.isEmpty else { terminate(); return }
//
//        window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 800, height: 150),
//                          styleMask: [.titled, .closable],
//                          backing: .buffered, defer: false)
//
//        window.center()
//        window.order(.above, relativeTo: 0)
//        window.title = i18n.playgroundBookTitle
//        window.setFrameAutosaveName(i18n.playgroundBookTitle)
//        window.contentView = NSHostingView(rootView: assembler.resolvePlaygroundBookView())
//        window.makeKeyAndOrderFront(nil)
//
//        playgroundBookIO(packageContent: package).unsafeRunAsync(on: .global(qos: .userInitiated))  { output in
//            guard output.isRight else { return }
//            Thread.sleep(forTimeInterval: 1)
//            _ = output.map(self.showFile)
//            self.terminate()
//        }
//    }
//
//    private func notificationDidFinishLaunching(userInfo: [String: Any], action: String) {
//        emptyDidFinishLaunching()
//
//        let config = NotificationConfig(workspace: .shared, openPanel: assembler.resolveOpenPanel())
//
//        processNotification(userInfo, action: action)
//            .flatMap(showClipboardFile)^
//            .provide(config)
//            .unsafeRunAsync(on: .global(qos: .userInitiated)) { _ in self.terminate() }
//    }
//
//    // MARK: Helper methods
//    private func carbonIO(code: String) -> IO<AppDelegate.Error, URL> {
//        let panel = assembler.resolveOpenPanel()
//        let image = IO<AppDelegate.Error, Data>.var()
//        let output = IO<AppDelegate.Error, URL>.var()
//
//        return binding(
//              image <- self.assembler.resolveCarbon(code: code),
//             output <- image.get.persist(command: .exportSnippet(selection: code)).provide(panel).mapError { _ in .carbon },
//        yield: output.get)^
//    }
//
//    private func markdownIO(playground: String) -> IO<AppDelegate.Error, URL> {
//        assembler.resolveOpenPanel().writableFolder(create: true).use { folder in
//            let file = IO<OpenPanelError, URL>.var()
//            let output = IO<OpenPanelError, URL>.var()
//
//            return binding(
//                  file <- folder.outputURL(command: .markdownPage(playground: playground)),
//                output <- self.assembler.resolveMarkdownPage(playground: playground, output: file.get).mapError { _ in .unknown },
//            yield: output.get)
//        }^.mapError { _ in .markdown }^
//    }
//
//    private func playgroundBookIO(packageContent: String) -> IO<AppDelegate.Error, URL> {
//        assembler.resolveOpenPanel().writableFolder(create: true).use { folder in
//            let file = IO<OpenPanelError, URL>.var()
//            let output = IO<OpenPanelError, URL>.var()
//
//            return binding(
//                  file <- folder.outputURL(command: .playgroundBook(package: packageContent)),
//                output <- self.assembler.resolvePlaygroundBook(packageContent: packageContent, name: file.get.lastPathComponent, output: file.get.deletingLastPathComponent()).mapError { _ in .unknown },
//            yield: output.get)
//        }^.mapError { _ in .swiftPlayground }
//    }
//
//
//    
//
//
//    enum Error: Swift.Error {
//        case carbon
//        case markdown
//        case swiftPlayground
//        case notification
//    }
//}
