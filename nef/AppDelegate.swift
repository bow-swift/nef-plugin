//  Copyright © 2019 The nef Authors.

import Cocoa
import SwiftUI

import AppKit
import WebKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.setFrameAutosaveName("Main Window")
test()
//        window.contentView = NSHostingView(rootView: ContentView())

        window.makeKeyAndOrderFront(nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


    
     let webView = WKWebView(frame: CarbonScreen.bounds)
    private func test() {
        window.contentView?.addSubview(webView)
        if let url = URL(string: "https://carbon.now.sh/?bg=rgba(126%2C211%2C33%2C0)&t=one-dark&wt=none&l=swift&ds=true&dsyoff=20px&dsblur=68px&wc=true&wa=true&pv=56px&ph=56px&ln=true&fm=Space%20Mono&fs=14px&lh=151%25&si=false&es=4x&wm=false") {
            let request = URLRequest(url: url)
            DispatchQueue.main.async {
                self.webView.load(request)
                
            }
            
        }
    }
    
    private class CarbonScreen: NSScreen {
        static let bounds = NSRect(x: 0, y: 0, width: 1000, height: 1000)
        
        override var frame: NSRect { return CarbonScreen.bounds }
        override var visibleFrame: NSRect { return CarbonScreen.bounds }
    }
}

