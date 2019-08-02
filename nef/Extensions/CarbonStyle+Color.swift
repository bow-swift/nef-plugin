//  Copyright © 2019 The nef Authors.

import SwiftUI
import NefModels

extension CarbonStyle.Color {
    var color: Color {
        Color(red: Double(r)/255.0, green: Double(g)/255.0, blue: Double(b)/255.0, opacity: a)
    }
    
    var hex: String {
        let opacity = UInt8(255 * a)
        return "\(r.hex)\(g.hex)\(b.hex)\(opacity.hex)"
    }
}

private extension UInt8 {
    var hex: String { String(format: "%02X", self) }
}
