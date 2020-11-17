//  Copyright © 2019 The nef Authors.

import Foundation
import AppKit

public enum Browser {
    public enum Error: Swift.Error {
        case invalidURL
        case notOpened
    }
    
    @discardableResult
    public static func open(url: String, options: NSWorkspace.LaunchOptions = []) -> Result<Void, Browser.Error> {
        guard let url = URL(string: url) else { return .failure(.invalidURL) }
        return open(url: url, options: options)
    }
    
    @discardableResult
    public static func open(url: URL, options: NSWorkspace.LaunchOptions = []) -> Result<Void, Browser.Error> {
        do {
            try NSWorkspace.shared.open(url, options: options, configuration: [:])
            return .success(())
        } catch {
            return .failure(.notOpened)
        }
    }
    
    public static func showFile(_ file: URL) {
        NSWorkspace.shared.activateFileViewerSelecting([file])
    }
}


