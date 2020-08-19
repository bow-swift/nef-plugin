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
            return NSLocalizedString("This command has not being implemented", comment: "")
        case .selection:
            return NSLocalizedString("You must make a code selection first", comment: "")
        case .internetConnection:
            return NSLocalizedString("You can not create a code snippet without an internet connection", comment: "")
        case .packageNotFound:
            return NSLocalizedString("This command only works on Swift Package files", comment: "")
        case .playgroundNotFound:
            return NSLocalizedString("This command only works on Playground or Playground pages", comment: "")
        }
    }
}
