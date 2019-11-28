//  Copyright © 2019 The nef Authors.

import AppKit

struct AppScheme {
    enum Action {
        case preferences
        case carbon(selection: String)
        case markdownPage(playground: String)
        case swiftplayground(package: String)
        
        var item: URLQueryItem {
            switch self {
            case .preferences: return URLQueryItem(name: "preferences", value: nil)
            case let .carbon(selection): return URLQueryItem(name: "carbon", value: selection)
            case let .markdownPage(playground): return URLQueryItem(name: "markdownPage", value: playground)
            case let .swiftplayground(package): return URLQueryItem(name: "swiftplayground", value: package)
            }
        }
    }
    
    let action: AppScheme.Action
    
    func run() {
        try! NSWorkspace.shared.open(url, options: .newInstance, configuration: [:])
    }
    
    private var url: URL {
        var urlComponents = URLComponents()
        urlComponents.scheme = Constants.scheme
        urlComponents.host = "xcode"
        urlComponents.queryItems = [action.item]
        return urlComponents.url!
    }
    
    // MARK: - Constants
    enum Constants {
        static let scheme = "nef-plugin"
    }
}
