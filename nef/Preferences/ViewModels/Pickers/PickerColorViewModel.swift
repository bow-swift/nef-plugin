//  Copyright © 2019 The nef Authors.

import SwiftUI
import Combine
import NefModels

class PickerColorViewModel: BindableObject, ActionViewModel {
    public let didChange = PassthroughSubject<PickerColorViewModel, Never>()
    private let dataSource: PreferencesDataSource
    
    let options: [OptionItem]
    let colors: [String: CarbonStyle.Color]
    var selectedColor: CarbonStyle.Color { colorFromHex! }
    
    var selection: Int = 0 { didSet { changedSelection() }}
    var hex = "" { didSet { changedHex() }}
    
    init(dataSource: PreferencesDataSource, colors: [String: CarbonStyle.Color]) {
        let colorOptions = colors.keys.sorted().map { $0 != "nef" ? $0.capitalized : $0 }.enumerated().map(OptionItem.init)
        let customOption = OptionItem(id: colors.count, name: "-")
        
        self.dataSource = dataSource
        self.options = colorOptions + [customOption]
        self.colors = colors
    }
    
    // MARK: delegate methods <ActionViewModel>
    func onAppear() {
        reset()
    }
    
    func tapOnRestore() {
        reset()
    }
    
    // MARK: internal attributes
    private var colorFromHex: CarbonStyle.Color? {
        guard hex.count == 8 else { return nil }
        return CarbonStyle.Color(hex: hex)
    }
    
    private var hexFromColor: String? {
        let selectedColor = options[selection].name.lowercased()
        guard let selectedColorKey = colors.keys.first(where: { $0 == selectedColor }),
            let color = colors[selectedColorKey] else { return colorFromHex?.hex }
        
        return color.hex
    }
    
    // MARK: update models and notify
    private func reset() {
        let nefSelection = options.enumerated().first(where: { $0.element.name == "nef" })?.offset ?? 0
        self.selection = nefSelection
    }
    
    private func changedSelection() {
        guard let hexValue = hexFromColor else { return }
        
        let hasHexChanged = hex != hexValue
        if hasHexChanged {
            hex = hexValue
        } else {
            didChange.send(self)
        }
    }
    
    private func changedHex() {
        let keys = options.map { $0.name.lowercased() }
        guard let color = colorFromHex,
              let carbonColor = CarbonStyle.Color.all.first(where: { _, value in color.description == value.description }),
              let selection = keys.enumerated().first(where: { $0.element == carbonColor.key.lowercased() })?.offset else {
                
                setSelectionCustomColor()
                return
        }
        
        self.selection = selection
    }
    
    private func setSelectionCustomColor() {
        selection = options.count - 1
    }
}
