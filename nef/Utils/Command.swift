//  Copyright © 2020 The nef Authors.

enum Command: CustomStringConvertible {
    case about
    case preferences
    case carbon(code: String)
    case clipboardCarbon(code: String = "")
    case markdownPage(playground: String)
    case playgroundBook(package: String)
    case notification(userInfo: [String: Any], action: String)
    
    var description: String {
        switch self {
        case .about: return "about"
        case .preferences: return "preferences"
        case .carbon: return "carbon"
        case .clipboardCarbon: return "clipboardCarbon"
        case .markdownPage: return "markdown"
        case .playgroundBook: return "playground-book"
        case .notification: return "notification"
        }
    }
}
