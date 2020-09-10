//  Copyright © 2019 The nef Authors.

import SwiftUI
import Bow
import BowEffects
import SourceEditorModels

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var command: Command?
    private let assembler = Assembler()
    private var window: NSWindow!
    @IBOutlet private weak var aboutMenuItem: NSMenuItem!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        registerNotifications()
        
        if let command = command {
            commandDidFinishLaunching(command: command)
        } else {
            defaultDidFinishLaunching(aNotification)
        }
    }
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        let eventManager = NSAppleEventManager.shared()
        eventManager.setEventHandler(self,
                                     andSelector: #selector(handle(event:withReplyEvent:)),
                                     forEventClass: AEEventClass(kInternetEventClass),
                                     andEventID: AEEventID(kAEGetURL))
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    // MARK: Aplication actions
    @IBAction func showAbout(_ sender: Any) {
        aboutDidFinishLaunching()
    }
    
    // MARK: life cycle
    private func defaultDidFinishLaunching(_ aNotification: Notification) {
        guard !isLocalNotification(aNotification) else { return }
        aboutDidFinishLaunching()
    }
    
    private func commandDidFinishLaunching(command: Command) {
        switch command {
        case .preferences:
            preferencesDidFinishLaunching()
        case .exportSnippetToFile(let selection):
            carbonDidFinishLaunching(code: selection)
        case .exportSnippetToClipboard(let selection):
            clipboardCarbonDidFinishLaunching(code: selection)
        case .markdownPage(let playground):
            markdownPageDidFinishLaunching(playground: playground)
        case .playgroundBook(let package):
            playgroundBookDidFinishLaunching(package: package)
        case .notification(let userInfo, let action):
            notificationDidFinishLaunching(userInfo: userInfo, action: action)
        case .about:
            aboutDidFinishLaunching()
        }
    }
    
    private func emptyDidFinishLaunching() {
        window = NSWindow.empty
        window.makeKeyAndOrderFront(nil)
    }
    
    private func aboutDidFinishLaunching() {
        window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 350, height: 350),
                          styleMask: [.titled, .closable],
                          backing: .buffered, defer: false)
        
        window.center()
        window.title = i18n.aboutTitle
        window.setFrameAutosaveName(i18n.aboutTitle)
        window.contentView = NSHostingView(rootView: assembler.resolveAboutView())
        window.makeKeyAndOrderFront(nil)
        
        aboutMenuItem.isHidden = true
    }
    
    private func preferencesDidFinishLaunching() {
        window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 800, height: 768),
                          styleMask: [.titled, .closable, .miniaturizable],
                          backing: .buffered, defer: false)
        
        window.center()
        window.title = i18n.preferencesTitle
        window.setFrameAutosaveName(i18n.preferencesTitle)
        window.contentView = NSHostingView(rootView: assembler.resolvePreferencesView())
        window.makeKeyAndOrderFront(nil)
    }
    
    private func carbonDidFinishLaunching(code: String) {
        guard !code.isEmpty else { terminate(); return }
        emptyDidFinishLaunching()
        
        carbonIO(code: code).unsafeRunAsync(on: .global(qos: .userInitiated)) { output in
            _ = output.map(self.showFile)
            self.terminate()
        }
    }
    
    private func clipboardCarbonDidFinishLaunching(code: String) {
        guard !code.isEmpty else { terminate(); return }
        emptyDidFinishLaunching()
        
        let config = Clipboard.Config(clipboard: .general, notificationCenter: .current())
        
        assembler.resolveCarbon(code: code).env()^.mapError { _ in .carbon }
            .flatMap(clipboardCarbonIO)^
            .provide(config)
            .unsafeRunAsync(on: .global(qos: .userInitiated)) { output in
                _ = output.map { _ in
                    self.terminate()
                }
        }
    }
    
    private func markdownPageDidFinishLaunching(playground: String) {
        guard !playground.isEmpty else { terminate(); return }
        
        _ = markdownIO(playground: playground)
                .unsafeRunSyncEither()
                .map(self.showFile)
        self.terminate()
    }
    
    private func playgroundBookDidFinishLaunching(package: String) {
        guard !package.isEmpty else { terminate(); return }
        
        window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 800, height: 150),
                          styleMask: [.titled, .closable],
                          backing: .buffered, defer: false)
        
        window.center()
        window.order(.above, relativeTo: 0)
        window.title = i18n.playgroundBookTitle
        window.setFrameAutosaveName(i18n.playgroundBookTitle)
        window.contentView = NSHostingView(rootView: assembler.resolvePlaygroundBookView())
        window.makeKeyAndOrderFront(nil)
        
        playgroundBookIO(packageContent: package).unsafeRunAsync(on: .global(qos: .userInitiated))  { output in
            guard output.isRight else { return }
            Thread.sleep(forTimeInterval: 1)
            _ = output.map(self.showFile)
            self.terminate()
        }
    }
    
    private func notificationDidFinishLaunching(userInfo: [String: Any], action: String) {
        emptyDidFinishLaunching()
        
        let config = NotificationConfig(workspace: .shared, openPanel: assembler.resolveOpenPanel())
        
        processNotification(userInfo, action: action)
            .flatMap(showClipboardFile)^
            .provide(config)
            .unsafeRunAsync(on: .global(qos: .userInitiated)) { _ in self.terminate() }
    }
    
    // MARK: Helper methods
    private func carbonIO(code: String) -> IO<AppDelegate.Error, URL> {
        let panel = assembler.resolveOpenPanel()
        let image = IO<AppDelegate.Error, Data>.var()
        let output = IO<AppDelegate.Error, URL>.var()
        
        return binding(
              image <- self.assembler.resolveCarbon(code: code),
             output <- image.get.persist(command: .exportSnippetToFile(selection: code)).provide(panel).mapError { _ in .carbon },
        yield: output.get)^
    }
    
    private func markdownIO(playground: String) -> IO<AppDelegate.Error, URL> {
        assembler.resolveOpenPanel().writableFolder(create: true).use { folder in
            let file = IO<OpenPanelError, URL>.var()
            let output = IO<OpenPanelError, URL>.var()
            
            return binding(
                  file <- folder.outputURL(command: .markdownPage(playground: playground)),
                output <- self.assembler.resolveMarkdownPage(playground: playground, output: file.get).mapError { _ in .unknown },
            yield: output.get)
        }^.mapError { _ in .markdown }^
    }
    
    private func playgroundBookIO(packageContent: String) -> IO<AppDelegate.Error, URL> {
        assembler.resolveOpenPanel().writableFolder(create: true).use { folder in
            let file = IO<OpenPanelError, URL>.var()
            let output = IO<OpenPanelError, URL>.var()
            
            return binding(
                  file <- folder.outputURL(command: .playgroundBook(package: packageContent)),
                output <- self.assembler.resolvePlaygroundBook(packageContent: packageContent, name: file.get.lastPathComponent, output: file.get.deletingLastPathComponent()).mapError { _ in .unknown },
            yield: output.get)
        }^.mapError { _ in .swiftPlayground }
    }
    
    private func showFile(_ file: URL) {
        NSWorkspace.shared.activateFileViewerSelecting([file])
    }
    
    private func terminate() {
        DispatchQueue.main.async {
            NSApplication.shared.terminate(nil)
        }
    }
    
    // MARK: scheme url types    
    @objc private func handle(event: NSAppleEventDescriptor, withReplyEvent: NSAppleEventDescriptor) {
        let keyword = AEKeyword(keyDirectObject)
        let urlDescriptor = event.paramDescriptor(forKeyword: keyword)
        guard let urlString = urlDescriptor?.stringValue,
            let incomingURL = URL(string: urlString),
            let components = NSURLComponents(url: incomingURL, resolvingAgainstBaseURL: false),
            let queryItems = components.queryItems else { return }
        
        self.command = queryItems.compactMap(\.command).first
    }
    
    // MARK: Constants
    enum i18n {
        static let preferencesTitle = NSLocalizedString("preferences", comment: "")
        static let aboutTitle = NSLocalizedString("about", comment: "")
        static let playgroundBookTitle = NSLocalizedString("playground-book", comment: "")
    }
    
    enum Error: Swift.Error {
        case carbon
        case markdown
        case swiftPlayground
        case notification
    }
}
