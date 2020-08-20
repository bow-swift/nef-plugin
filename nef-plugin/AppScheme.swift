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
    
    var url: URL {
        var urlComponents = URLComponents()
        urlComponents.scheme = "nef-plugin"
        urlComponents.host = "xcode"
        urlComponents.queryItems = [command.item(code: code)]
        return urlComponents.url!
    }
}
