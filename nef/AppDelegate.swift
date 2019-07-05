//  Copyright © 2019 The nef Authors.

import Cocoa
import AppKit
import SwiftUI

import nef
import Markup

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!
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
        // TODO
    }
    
    private func preferencesDidFinishLaunching() {
        // TODO
    }
    
    private func carbonDidFinishLaunching(code: String) {
        guard !code.isEmpty else { terminate(); return }
        guard let carbonWindow = carbonWindow(code: code) else { terminate(); return }
        
        window = carbonWindow
        window.makeKey()
    }
    
    // MARK: actions
    private func carbonWindow(code: String) -> NSWindow? {
        guard let downloadsFolder = try? FileManager.default.url(for: .downloadsDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else { return nil }
        
        let filename = "nef"
        let outputPath = downloadsFolder.appendingPathComponent(filename).path
        let style = CarbonStyle(background: .nef,
                                theme: .dracula,
                                size: .x1,
                                fontType: .firaCode,
                                lineNumbers: true,
                                watermark: true)
        
        return nef.carbon(code: code,
                          style: style,
                          outputPath: outputPath,
                          success: terminate, failure: terminate)
    }
    
    private func terminate() {
        DispatchQueue.main.async {
            NSApplication.shared.terminate(nil)
        }
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
    
    // MARK: Commands
    enum Command {
        case preferences
        case carbon(code: String)
    }
}
