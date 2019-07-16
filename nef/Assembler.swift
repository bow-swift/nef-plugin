//  Copyright © 2019 The nef Authors.

import SwiftUI
import NefModels

class Assembler {
    
    func resolvePreferencesView() -> some View {
        return PreferencesView(colorViewModel: resolveColorViewModel())
    }
    
    private func resolveColorViewModel() -> PickerColorViewModel {
        return PickerColorViewModel(dataSource: resolvePreferencesDataSource(),
                                    colors: CarbonStyle.Color.all)
    }
    
    private func resolvePreferencesDataSource() -> PreferencesDataSource {
        return PreferencesDataSource()
    }
}
