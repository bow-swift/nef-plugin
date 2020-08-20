//  Copyright © 2020 The nef Authors.

import Foundation

extension Result {
    
    @discardableResult
    public func fold<B>(_ fe: (Failure) -> B, _ fa: (Success) -> B) -> Result<B, Failure> {
        map(fa).flatMapError { error in .success(fe(error)) }
    }
}
