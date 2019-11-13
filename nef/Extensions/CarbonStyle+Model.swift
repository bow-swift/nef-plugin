//  Copyright © 2019 The nef Authors.

import Foundation
import nef

extension PreferencesModel {
    var style: CarbonStyle {
        CarbonStyle(background: color,
                    theme: theme,
                    size: size,
                    fontType: font,
                    lineNumbers: showLines,
                    watermark: showWatermark)
    }
}
