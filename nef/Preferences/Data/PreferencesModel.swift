//  Copyright © 2019 The nef Authors.

import Foundation
import NefModels

struct PreferencesModel: Codable {
    let showLines: Bool
    let showWatermark: Bool
    let font: CarbonStyle.Font
    let theme: CarbonStyle.Theme
    let size: CarbonStyle.Size
    let color: CarbonStyle.Color
}
