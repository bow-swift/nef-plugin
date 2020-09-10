//  Copyright © 2020 The nef Authors.

import Foundation

extension Result {
    
    @discardableResult
    public func fold<B>(_ fe: (Failure) -> B, _ fa: (Success) -> B) -> B {
        switch self {
        case let .failure(error): return fe(error)
        case let .success(value): return fa(value)
        }
    }
}
