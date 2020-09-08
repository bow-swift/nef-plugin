//  Copyright © 2020 The nef Authors.

import Foundation

protocol NefController: AnyObject {
    func runAsync(completion: @escaping (Result<Void, Error>) -> Void)
}
