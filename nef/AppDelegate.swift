//  Copyright © 2019 The nef Authors.

import Cocoa
import AppKit
import SwiftUI

import nef
import Markup

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!
    private let textArea = NSText(frame: CarbonScreen.bounds)
    private var code: String = ""
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        carbonDidFinishLaunching()
    }
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        let eventManager = NSAppleEventManager.shared()
        eventManager.setEventHandler(self,
                                     andSelector: #selector(handle(event:withReplyEvent:)),
                                     forEventClass: AEEventClass(kInternetEventClass),
                                     andEventID: AEEventID(kAEGetURL))
    }
    
    // MARK: life cycle
    private func preferencesDidFinishLaunching() {
        //        // Insert code here to initialize your application
        //        window = NSWindow(
        //            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
        //            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
        //            backing: .buffered, defer: false)
        ////        window.contentView = NSHostingView(rootView: ContentView())
        
        
        //        window.setFrameAutosaveName("Main Window")
    }
    
    private func carbonDidFinishLaunching() {
        guard !code.isEmpty else { terminate(); return }
        
        window = NSWindow(contentRect: CarbonScreen.bounds,
                          styleMask: [.titled],
                          backing: .buffered,
                          defer: true,
                          screen: CarbonScreen())
        window.makeKey()
        
        carbon(code: code)
    }
    
    // MARK: actions
    private func carbon(code: String) {
        guard let parentView = window.contentView else { return }
        let outputPath = "/Users/miguelangel/Downloads/output"
        let style = CarbonStyle(background: .bow,
                                theme: .dracula,
                                size: .x2,
                                fontType: .firaCode,
                                lineNumbers: true,
                                watermark: true)
        
        DispatchQueue.main.async {
            nef.carbon(parentView: parentView, code: code, style: style, outputPath: outputPath)
        }
        
    }
    
    private func terminate() {
        NSApplication.shared.terminate(nil)
    }
    
    // MARK: scheme url types
    @objc func handle(event: NSAppleEventDescriptor, withReplyEvent: NSAppleEventDescriptor) {
        let keyword = AEKeyword(keyDirectObject)
        let urlDescriptor = event.paramDescriptor(forKeyword: keyword)
        guard let urlString = urlDescriptor?.stringValue,
            let incomingURL = URL(string: urlString),
            let components = NSURLComponents(url: incomingURL, resolvingAgainstBaseURL: false),
            let queryItems = components.queryItems else { return }
        
        let params = queryItems.map { item in (name: item.name, value: item.value ?? "") }
        let operation = params.first(where: self.isOperation).flatMap(self.operation)
        operation?()
    }
    
    private func isOperation(param: (name: String, value: String)) -> Bool {
        return operation(for: param) != nil
    }
    
    private func operation(for param: (name: String, value: String)) -> (() -> Void)? {
        switch param {
        case let ("carbon", value): return { self.code = value }
        default: return nil
        }
    }
    
    // MARK: private classes
    private class CarbonScreen: NSScreen {
        static let bounds = NSRect(x: 0, y: 0, width: 5000, height: 15000)
        
        override var frame: NSRect { return CarbonScreen.bounds }
        override var visibleFrame: NSRect { return CarbonScreen.bounds }
    }
}
