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
    
    // MARK: private methods
    private func carbonIO(code: String) -> IO<AppDelegate.Error, URL> {
        func outputURL(inFolder url: URL) -> IO<OpenPanelError, URL> {
            let filename = "nef \(Date.now.human)"
            return IO.pure(url.appendingPathComponent(filename))^
        }
        
        return assembler.resolveOpenPanel().writableFolder(create: true).use { folder in
            let file = IO<OpenPanelError, URL>.var()
            let output = IO<OpenPanelError, URL>.var()
            
            return binding(
                  file <- outputURL(inFolder: folder),
                output <- self.assembler.resolveCarbon(code: code, output: file.get).mapLeft { _ in .unknown },
            yield: output.get)
        }^.mapLeft { _ in .carbon }
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
        case ("about", _):
            return .about
        default:
            return nil
        }
    }
    
    // MARK: Constants
    enum Command {
        case about
        case preferences
        case carbon(code: String)
    }
    
    enum i18n {
        static let preferencesTitle = NSLocalizedString("preferences", comment: "")
        static let aboutTitle = NSLocalizedString("about", comment: "")
    }
    
    // MARK: Errors
    enum Error: Swift.Error {
        case carbon
    }
}
