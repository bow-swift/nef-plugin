//  Copyright © 2019 The nef Authors.

import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!
    private let assembler = Assembler()
    private var command: Command?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        guard let command = command else { applicationDidFinishLaunching(); return }
        
        switch command {
        case .preferences:
            preferencesDidFinishLaunching()
        case .carbon(let code):
            carbonDidFinishLaunching(code: code)
        }
    }
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        let eventManager = NSAppleEventManager.shared()
        eventManager.setEventHandler(self,
                                     andSelector: #selector(handle(event:withReplyEvent:)),
                                     forEventClass: AEEventClass(kInternetEventClass),
                                     andEventID: AEEventID(kAEGetURL))
    }
    
    // MARK: life cycle
    private func applicationDidFinishLaunching() {
        preferencesDidFinishLaunching()
    }
    
    private func preferencesDidFinishLaunching() {
        window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 800, height: 550),
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
        guard let carbonWindow = carbonWindow(code: code) else { terminate(); return }
        
        window = carbonWindow
        window.makeKey()
    }
    
    // MARK: private methods
    private func carbonWindow(code: String) -> NSWindow? {
        return assembler.resolveCarbonWindow(code: code, completion: terminate)
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
        default:
            return nil
        }
    }
    
    // MARK: Constants
    enum Command {
        case preferences
        case carbon(code: String)
    }
    
    enum i18n {
        static let preferencesTitle = NSLocalizedString("Preferences", comment: "")
    }
}
