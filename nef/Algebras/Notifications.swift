//  Copyright © 2020 The nef Authors.

import Foundation
import AppKit
import BowEffects

protocol Notifications {
    func removeAllDelivered<D, E: Swift.Error>() -> EnvIO<D, E, Void>
    func show<D, E: Swift.Error>(title: String, body: String, options: NotificationOptions) -> EnvIO<D, E, Void>
}


struct NotificationOptions {
    let imageData: Data?
    let actions: [NefNotification.Action]
    let identifier: String
    
    init(imageData: Data? = nil, actions: [NefNotification.Action] = [], identifier: String = UUID().uuidString) {
        self.imageData = imageData
        self.actions = actions
        self.identifier = identifier
    }
}
