//  Copyright © 2020 The nef Authors.

import Foundation
import Bow
import BowEffects

extension IO {
    func unsafeRunSyncResult(on queue: DispatchQueue = .main) -> Result<A, E> {
        unsafeRunSyncEither(on: queue).toResult()
    }
    
    func unsafeRunSyncResult(on queue: DispatchQueue = .main) -> Result<A, Swift.Error> {
        unsafeRunSyncEither(on: queue).toResult().eraseError()
    }
}

extension Result {
    func eraseError() -> Result<Success, Swift.Error> {
        mapError { e in e as Swift.Error }
    }
}
