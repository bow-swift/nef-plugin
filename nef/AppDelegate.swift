//  Copyright © 2019 The nef Authors.

import SwiftUI
import Bow
import BowEffects

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!
    private let assembler = Assembler()
    private var command: Command?
    @IBOutlet weak var aboutMenuItem: NSMenuItem!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        guard let command = command else { applicationDidFinishLaunching(); return }
        
        switch command {
        case .preferences:
            preferencesDidFinishLaunching()
        case .carbon(let code):
            carbonDidFinishLaunching(code: code)
        case .markdownPage(let playground):
            markdownPageDidFinishLaunching(playground: playground)
        case .swiftPlayground(let package):
            swiftPlaygroundDidFinishLaunching(package: package)
        case .about:
            aboutDidFinishLaunching()
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
    private func applicationDidFinishLaunching() {
        aboutDidFinishLaunching()
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
        
        window = NSWindow.empty
        window.makeKeyAndOrderFront(nil)
        
        carbonIO(code: code).unsafeRunAsync(on: .global(qos: .userInitiated)) { output in
            _ = output.map(self.showFile)
            self.terminate()
        }
    }
    
    private func markdownPageDidFinishLaunching(playground: String) {
        guard !playground.isEmpty else { terminate(); return }
        
        _ = markdownIO(playground: playground).unsafeRunSyncEither().map(self.showFile)
        self.terminate()
    }
    
    private func swiftPlaygroundDidFinishLaunching(package: String) {
        guard !package.isEmpty else { terminate(); return }
        
        window = NSWindow.empty
        window.makeKeyAndOrderFront(nil)
        
        swiftPlaygroundIO(packageContent: package).unsafeRunAsync(on: .global(qos: .userInitiated))  { output in
            _ = output.map(self.showFile)
            self.terminate()
        }
    }
    
    // MARK: Helper methods
    private func carbonIO(code: String) -> IO<AppDelegate.Error, URL> {
        assembler.resolveOpenPanel().writableFolder(create: true).use { folder in
            let file = IO<OpenPanelError, URL>.var()
            let output = IO<OpenPanelError, URL>.var()
            
            return binding(
                  file <- self.outputURL(inFolder: folder, command: .carbon(code: code)),
                output <- self.assembler.resolveCarbon(code: code, output: file.get).mapLeft { _ in .unknown },
            yield: output.get)
        }^.mapLeft { _ in .carbon }
    }
    
    private func markdownIO(playground: String) -> IO<AppDelegate.Error, URL> {
        assembler.resolveOpenPanel().writableFolder(create: true).use { folder in
            let file = IO<OpenPanelError, URL>.var()
            let output = IO<OpenPanelError, URL>.var()
            
            return binding(
                  file <- self.outputURL(inFolder: folder, command: .markdownPage(playground: playground)),
                output <- self.assembler.resolveMarkdownPage(playground: playground, output: file.get).mapLeft { _ in .unknown },
            yield: output.get)
        }^.mapLeft { _ in .markdown }
    }
    
    private func swiftPlaygroundIO(packageContent: String) -> IO<AppDelegate.Error, URL> {
        assembler.resolveOpenPanel().writableFolder(create: true).use { folder in
            let file = IO<OpenPanelError, URL>.var()
            let output = IO<OpenPanelError, URL>.var()
            
            return binding(
                  file <- self.outputURL(inFolder: folder, command: .swiftPlayground(package: packageContent)),
                output <- self.assembler.resolveSwiftPlayground(packageContent: packageContent, name: file.get.lastPathComponent, output: file.get.deletingLastPathComponent()).mapLeft { _ in .unknown },
            yield: output.get)
        }^.mapLeft { _ in .swiftPlayground }
    }

    private func outputURL(inFolder url: URL, command: Command) -> IO<OpenPanelError, URL> {
        let filename = "nef-\(command) \(Date.now.human)"
        return IO.pure(url.appendingPathComponent(filename))^
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
    enum Command: CustomStringConvertible {
        case about
        case preferences
        case carbon(code: String)
        case markdownPage(playground: String)
        case swiftPlayground(package: String)
        
        var description: String {
            switch self {
            case .about: return "about"
            case .preferences: return "preferences"
            case .carbon: return "carbon"
            case .markdownPage: return "markdown"
            case .swiftPlayground: return "swift-playground"
            }
        }
    }
    
    @objc private func handle(event: NSAppleEventDescriptor, withReplyEvent: NSAppleEventDescriptor) {
        let keyword = AEKeyword(keyDirectObject)
        let urlDescriptor = event.paramDescriptor(forKeyword: keyword)
        guard let urlString = urlDescriptor?.stringValue,
            let incomingURL = URL(string: urlString),
            let components = NSURLComponents(url: incomingURL, resolvingAgainstBaseURL: false),
            let queryItems = components.queryItems else { return }
        
        let params = queryItems.map { item in (name: item.name, value: item.value ?? "") }
        self.command = params.first(where: self.isOperation).flatMap(self.operation)
    }
    
    private func isOperation(param: (name: String, value: String)) -> Bool {
        return operation(for: param) != nil
    }
    
    private func operation(for param: (name: String, value: String)) -> Command? {
        switch param {
        case ("preferences", _):
            return .preferences
        case let ("carbon", value):
            return .carbon(code: value)
        case let ("markdownPage", value):
            return .markdownPage(playground: value)
        case let ("swiftplayground", value):
            return .swiftPlayground(package: value)
        case ("about", _):
            return .about
        default:
            return nil
        }
    }
    
    // MARK: Constants
    enum i18n {
        static let preferencesTitle = NSLocalizedString("preferences", comment: "")
        static let aboutTitle = NSLocalizedString("about", comment: "")
    }
    
    enum Error: Swift.Error {
        case carbon
        case markdown
        case swiftPlayground
    }
}
