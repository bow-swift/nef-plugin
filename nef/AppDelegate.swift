//  Copyright © 2019 The nef Authors.

import SwiftUI
import SourceEditorModels

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet private weak var aboutMenuItem: NSMenuItem!
    private var window: NSWindow!
    private let app = App(assembler: Assembler())
    var command: Command?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        registerNotifications()

        let window: NefWindow?
        if let command = command {
            window = app.didFinishLaunching(command: command)
        } else if !isLocalNotification(aNotification) {
            window = app.didFinishLaunching()
        } else {
            window = nil
        }
        
        window.flatMap(presentWindow)
    }
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        let eventManager = NSAppleEventManager.shared()
        eventManager.setEventHandler(self, andSelector: #selector(handle(event:withReplyEvent:)),
                                           forEventClass: AEEventClass(kInternetEventClass),
                                           andEventID: AEEventID(kAEGetURL))
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
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
    
    // MARK: Menu actions
    @IBAction func showAbout(_ sender: Any) {
        app.didFinishLaunching(command: .about)
            .flatMap(presentWindow)
    }
    
    // MARK: Presentation
    private func presentWindow(window: NefWindow) {
        switch window {
        case let .view(view, config):
            presentView(view, config: config)
        case let .controller(controller):
            presentController(controller)
        case let .viewController(view, controller, config):
            presentViewController(view: view, controller: controller, config: config)
        }
    }
    
    private func presentView(_ contentView: NSView, config: NefWindow.Config) {
        self.window = NSWindow(contentRect: config.rect,
                               styleMask: [.titled, .closable],
                               backing: .buffered, defer: false)
        
        self.window.center()
        self.window.order(.above, relativeTo: 0)
        self.window.title = config.title
        self.window.setFrameAutosaveName(config.title)
        self.window.contentView = contentView
        self.window.makeKeyAndOrderFront(nil)
        
        self.aboutMenuItem.isHidden = !config.needMenu
    }
    
    private func presentController(_ controller: NefController) {
        self.window = NSWindow.empty
        self.window.makeKeyAndOrderFront(nil)
        self.aboutMenuItem.isHidden = true
        
        controller.runAsync { result in result.terminate() }
    }
    
    private func presentViewController(view: NSView, controller: NefController, config: NefWindow.Config) {
        presentView(view, config: config)
        controller.runAsync { result in result.terminate() }
    }
}
