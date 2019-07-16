//  Copyright © 2019 The nef Authors.

import SwiftUI
import Combine

class CheckViewModel: BindableObject, ActionViewModel {
    public let didChange = PassthroughSubject<CheckViewModel, Never>()
    private let dataSource: PreferencesDataSource
    
    var selection: Bool = true { didSet { notify() }}
    
    init(dataSource: PreferencesDataSource) {
        self.dataSource = dataSource
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
