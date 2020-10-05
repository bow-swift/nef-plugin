//  Copyright © 2020 The nef Authors.

import Foundation

enum EditorError: Int, Error {
    case unknown
    case invalidCommand
    case selection
    case internetConnection
    case packageNotFound
    case playgroundNotFound
    
    var localizedDescription: String {
        switch self {
        case .unknown:
            return NSLocalizedString("Undefined error", comment: "")
        case .invalidCommand:
            return NSLocalizedString("This command has not been implemented", comment: "")
        case .selection:
            return NSLocalizedString("You must make a code selection first", comment: "")
        case .internetConnection:
            return NSLocalizedString("You cannot create a code snippet without an Internet connection", comment: "")
        case .packageNotFound:
            return NSLocalizedString("This command only works on Swift Package files", comment: "")
        case .playgroundNotFound:
            return NSLocalizedString("This command only works on Playgrounds or Playground pages", comment: "")
        }
    }
}
