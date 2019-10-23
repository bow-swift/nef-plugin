//  Copyright © 2019 The nef Authors.

import Foundation


func runSync<T>(on queue: DispatchQueue = .main, block: @escaping () -> T?) -> T? {
    guard !DispatchQueue.isMainThread else { return block() }
    return queue.sync { block() }
}


extension DispatchQueue {
    public static var currentLabel: String {
        return String(validatingUTF8: __dispatch_queue_get_label(nil)) ?? ""
    }
    
    public static var isMainThread: Bool {
        currentLabel == "com.apple.main-thread"
    }
}
