//  Copyright © 2019 The nef Authors.

import Foundation

class PreferencesDataSource {
    
    init() {
        // TODO
    }
    
    var state: PreferencesModel { self.default }
    
    var `default`: PreferencesModel {
        return PreferencesModel(showLines: true,
                                showWatermark: true,
                                font: .firaCode,
                                theme: .dracula,
                                size: .x2,
                                color: .nef)
    }
    
    func persist(model: PreferencesModel) {
        // TODO
    }
}
