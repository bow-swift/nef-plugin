//  Copyright © 2019 The nef Authors.

import AppKit
import SourceEditorModels

struct AppScheme {
    let command: MenuEditorCommand
    let code: String
    
    init(command: MenuEditorCommand, code: String = "") {
        self.command = command
        self.code = code
    }
    
    func open() -> AppScheme {
        try! NSWorkspace.shared.open(url, options: .newInstance, configuration: [:])
        return self
    }
    
    private var url: URL {
        var urlComponents = URLComponents()
        urlComponents.scheme = Constants.scheme
        urlComponents.host = "xcode"
        urlComponents.queryItems = [command.item(code: code)]
        return urlComponents.url!
    }
    
    enum Constants {
        static let scheme = "nef-plugin"
    }
}
