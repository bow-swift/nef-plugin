//  Copyright © 2020 The nef Authors.

import Foundation
import Bow
import BowEffects

extension IO {
    func unsafeRunAsyncResult(on queue: DispatchQueue = .main, completion: @escaping (Result<A, E>) -> Void) {
        unsafeRunAsync(on: queue) { either in
            completion(either.toResult())
        }
    }
    
    func unsafeRunAsyncResult(on queue: DispatchQueue = .main, completion: @escaping (Result<A, Swift.Error>) -> Void) {
        unsafeRunAsync(on: queue) { either in
            completion(either.toResult().eraseError())
        }
    }
}

extension Result {
    func eraseError() -> Result<Success, Swift.Error> {
        mapError { e in e as Swift.Error }
    }
}
