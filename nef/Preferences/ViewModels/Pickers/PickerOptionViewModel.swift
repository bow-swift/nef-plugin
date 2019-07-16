//  Copyright © 2019 The nef Authors.

import SwiftUI
import Combine

class PickerOptionViewModel: BindableObject, ActionViewModel {
    public let didChange = PassthroughSubject<PickerOptionViewModel, Never>()
    private let dataSource: PreferencesDataSource
    let options: [OptionItem]
    
    var selection: Int = 0 { didSet { notify() }}
    var option: OptionItem { return options[selection] }
    
    init(dataSource: PreferencesDataSource, options: [OptionItem]) {
        self.dataSource = dataSource
        self.options = options
    }
    
    private func notify() {
        didChange.send(self)
    }
    
    // MARK: delegate methods <ActionViewModel>
    func onAppear() {
        
    }
    
    func tapOnRestore() {
        
    }
}
