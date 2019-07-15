//  Copyright © 2019 The nef Authors.

import SwiftUI
import Combine

class PickerOptionViewModel: BindableObject {
    public let didChange = PassthroughSubject<PickerOptionViewModel, Never>()
    private let options: [OptionItem]
    var selection: Int = 0 { didSet { notify() }}
    
    var option: OptionItem { return options[selection] }
    
    init(options: [OptionItem]) {
        self.options = options
    }
    
    private func notify() {
        didChange.send(self)
    }
}
