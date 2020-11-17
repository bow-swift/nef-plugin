//  Copyright © 2020 The nef Authors.

import UserNotifications

enum NefNotification {
    enum Action: Equatable {
        case saveImage
        case cancel
        
        var title: String {
            switch self {
            case .saveImage: return "Save to disk"
            case .cancel: return "Cancel"
            }
        }
        
        var identifier: String {
            switch self {
            case .saveImage: return String(describing: self)
            case .cancel: return UNNotificationDismissActionIdentifier
            }
        }
    }
    
    enum Response {
        case saveImage(URL)
        case dismiss
    }
    
    enum UserInfoKey {
        static let imageData = "imageDataUserInfoKey"
        static let description = "descriptionUserInfoKey"
    }
    
    enum Error: Swift.Error {
        case noImageData
        case unsupportedAction
        case persistImage
    }
}
