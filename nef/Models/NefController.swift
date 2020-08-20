//  Copyright © 2020 The nef Authors.

import Foundation

protocol NefController: AnyObject {
    func run() -> Result<Void, Error>
}
