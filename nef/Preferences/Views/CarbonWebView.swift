//  Copyright © 2019 The nef Authors.

import AppKit
import WebKit

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
    
    func update(state: PreferencesModel) {
        guard self.state != state else { return }
        self.state = state
        
        loadingView.show()
        let request = urlRequest(from: state)
        load(request)
    }
    
    private func urlRequest(from model: PreferencesModel) -> URLRequest {
        let backgroundColorItem = URLQueryItem(name: "bg", value: "\(model.color)")
        let themeItem = URLQueryItem(name: "t", value: model.theme.rawValue)
        let windowsThemeItem = URLQueryItem(name: "wt", value: "none")
        let languageItem = URLQueryItem(name: "l", value: "swift")
        let dropShadowItem = URLQueryItem(name: "ds", value: "true")
        let shadowYoffsetItem = URLQueryItem(name: "dsyoff", value: "20px")
        let shadowBlurItem = URLQueryItem(name: "dsblur", value: "68px")
        let windowsControlItem = URLQueryItem(name: "wc", value: "true")
        let autoAdjustWidthItem = URLQueryItem(name: "wa", value: "true")
        let verticalPaddingItem = URLQueryItem(name: "pv", value: "56px")
        let horizontalPaddingItem = URLQueryItem(name: "ph", value: "56px")
        let lineNumbersItem = URLQueryItem(name: "ln", value: model.showLines ? "true" : "false")
        let fontItem = URLQueryItem(name: "fm", value: model.font.rawValue)
        let fontSizeItem = URLQueryItem(name: "fs", value: "15px")
        let exportSizeCondition = URLQueryItem(name: "si", value: "false")
        let exportSize = URLQueryItem(name: "es", value: "4x")
        let lineHeightItem = URLQueryItem(name: "lh", value: "150%25")
        let carbonWatermarkItem = URLQueryItem(name: "wm", value: "false")
        let codeItem = URLQueryItem(name: "code", value: Constants.code)
        
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "carbon.now.sh"
        urlComponents.queryItems = [backgroundColorItem, themeItem, windowsThemeItem, languageItem, dropShadowItem, shadowYoffsetItem, shadowBlurItem, windowsControlItem, autoAdjustWidthItem, verticalPaddingItem, horizontalPaddingItem, lineNumbersItem, fontItem, fontSizeItem, lineHeightItem, exportSizeCondition, exportSize, carbonWatermarkItem, codeItem]
        
        let url = urlComponents.url?.absoluteString.urlEncoding ?? "https://github.com/bow-swift/nef"
        return URLRequest(url: URL(string: url)!)
    }
    
    // MARK: delegate <WKNavigationDelegate>
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        loadingView.show()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        resetPosition(completionHandler: loadingView.hide)
    }
    
    // MARK: private methods <animation>
    private func insertLoadingView() {
        addSubview(loadingView)
        loadingView.align(toView: self)
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

private extension String {
    var urlEncoding: String {
        return replacingOccurrences(of: "+", with: "%2B")
    }
}
