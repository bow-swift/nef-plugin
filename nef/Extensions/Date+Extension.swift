//  Copyright © 2019 The nef Authors.

import Foundation

extension Date {
    static var now: Date { Date() }
    
    var human: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd HH.mm.ss"
        return formatter.string(from: self)
    }
}
