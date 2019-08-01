//  Copyright © 2019 The nef Authors.

import AppKit
import WebKit
import nef
import NefModels

class CarbonWebView: WKWebView, WKNavigationDelegate {
    private let loadingView: LoadingView
    private var state: PreferencesModel
    
    init(state: PreferencesModel) {
        self.loadingView = LoadingView()
        self.state = state
        super.init(frame: .zero, configuration: WKWebViewConfiguration())
        
        self.navigationDelegate = self
        insertLoadingView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillMove(toSuperview newSuperview: NSView?) {
        guard newSuperview != nil else { return }
        loadCarbonWebView()
    }
    
    func update(state: PreferencesModel) {
        guard self.state != state else { return }
        self.state = state
        loadCarbonWebView()
    }
    
    private func insertLoadingView() {
        addSubview(loadingView)
        loadingView.align(toView: self)
    }
    
    private func loadCarbonWebView() {
        loadingView.show()
        
        let carbon = Carbon(code: Constants.code, style: state.style)
        let request = nef.carbonURLRequest(withConfiguration: carbon)
        load(request)
    }
    
    // MARK: delegate <WKNavigationDelegate>
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        loadingView.show()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        resetPosition(completionHandler: loadingView.hide)
    }
    
    // MARK: javascript <helpers>
    private func resetPosition(completionHandler: @escaping () -> Void) {
        let javaScript = "var main = document.getElementsByClassName('main')[0];" +
                         "var container = document.getElementsByClassName('export-container')[0];" +
                         "main.replaceWith(container);" +
                         "container.className = 'export-container';" +
                         "container.setAttribute('style', 'position: absolute; width: 100%; height: 200px; top: 0px');"
        
        evaluateJavaScript(javaScript) { (_, _) in
            DispatchQueue.main.asyncAfter(wallDeadline: .now() + .milliseconds(500), execute: completionHandler)
        }
    }
    
    // MARK: - Constants
    enum Constants {
        static let code =
        """
        import Bow
        
        func optionCount(_ option: Option<String>) -> Int {
            return option.fold(
                { 0 },
                { str in str.count })
        }
        
        optionCount(.some("Hello!")) // returns 6
        optionCount(.none())         // returns 0
        """
    }
}
