//  Copyright © 2019 The nef Authors.

import SwiftUI
import nef

extension CarbonStyle.Color {
    var color: Color {
        Color(red: Double(r)/255.0, green: Double(g)/255.0, blue: Double(b)/255.0, opacity: a)
    }
}
