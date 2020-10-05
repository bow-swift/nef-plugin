//  Copyright © 2020 The nef Authors.

import Foundation

private class DummyClass {}

extension Bundle {
    static var namespace: String {
        Bundle(for: DummyClass.self).bundleIdentifier!
    }
}
