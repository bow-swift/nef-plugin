//  Copyright © 2019 The nef Authors.

import SwiftUI
import Combine
import NefModels

class PickerColorViewModel: BindableObject {
    public let didChange = PassthroughSubject<PickerColorViewModel, Never>()
    let options: [OptionItem]
    let colors: [String: CarbonStyle.Color]
    
    var selection: Int = 0 { didSet { changedSelection() }}
    var hex = "" { didSet { changedHex() }}
    
    var colorFromHex: CarbonStyle.Color? {
        guard hex.count == 8 else { return nil }
        return CarbonStyle.Color(hex: hex)
    }
    
    var hexFromColor: String? {
        let selectedColor = options[selection].name.lowercased()
        guard let selectedColorKey = colors.keys.first(where: { $0 == selectedColor }),
              let color = colors[selectedColorKey] else { return colorFromHex?.hex }
        
        return color.hex
    }
    
    init(colors: [String: CarbonStyle.Color]) {
        let colorOptions = colors.keys.sorted().map { $0 != "nef" ? $0.capitalized : $0 }.enumerated().map(OptionItem.init)
        let customOption = OptionItem(id: colors.count, name: "-")
        
        self.options = colorOptions + [customOption]
        self.colors = colors
    }
    
    func load() {
        reset()
    }
    
    func reset() {
        let nefSelection = options.enumerated().first(where: { $0.element.name == "nef" })?.offset ?? 0
        self.selection = nefSelection
    }
    
    // MARK: update models and notify
    private func changedSelection() {
        guard let hexValue = hexFromColor else { return }
        
        let hexHasChanged = hex != hexValue
        if hexHasChanged {
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
