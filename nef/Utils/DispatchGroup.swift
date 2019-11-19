//  Copyright © 2019 The nef Authors.

import Foundation


func runSync<T>(on queue: DispatchQueue = .main, block: @escaping () -> T?) -> T? {
    guard !Thread.isMainThread else { return block() }
    return queue.sync { block() }
}
