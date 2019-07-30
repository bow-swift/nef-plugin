//  Copyright © 2019 The nef Authors.

import Foundation
import NefModels

struct PreferencesModel {
    let showLines: Bool
    let showWatermark: Bool
    let font: CarbonStyle.Font
    let theme: CarbonStyle.Theme
    let size: CarbonStyle.Size
    let color: CarbonStyle.Color
}

extension PreferencesModel: Codable {}
extension PreferencesModel: Equatable {
    static func == (lhs: PreferencesModel, rhs: PreferencesModel) -> Bool {
        return lhs.showLines == rhs.showLines &&
               lhs.font == rhs.font &&
               lhs.theme == rhs.theme &&
               lhs.color == rhs.color
    }
}
