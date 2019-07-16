//  Copyright © 2019 The nef Authors.

import SwiftUI
import Combine
import NefModels

class PreferencesViewModel: BindableObject {
    public let didChange = PassthroughSubject<PreferencesViewModel, Never>()
    
    private let preferences: PreferencesDataSource
    private let colors: [String: CarbonStyle.Color]
    private let fonts: [CarbonStyle.Font]
    private let themes: [CarbonStyle.Theme]
    private let sizes: [CarbonStyle.Size]
    
    let colorItems: [OptionItem]
    let fontItems:  [OptionItem]
    let themeItems: [OptionItem]
    let sizeItems:  [OptionItem]

    var showLines: Bool = false     { didSet { changedOption() }}
    var showWatermark: Bool = false { didSet { changedOption() }}
    var selectionFont: Int = 0  { didSet { changedOption() }}
    var selectionTheme: Int = 0 { didSet { changedOption() }}
    var selectionSize: Int = 0  { didSet { changedOption() }}
    var selectionColor: Int = 0 { didSet { changedColor()  }}
    var hex = "" { didSet { changedHex() }}
    
    init(preferences: PreferencesDataSource,
         colors: [String: CarbonStyle.Color],
         fonts: [CarbonStyle.Font],
         themes: [CarbonStyle.Theme],
         sizes: [CarbonStyle.Size]) {
        
        self.preferences = preferences
        
        self.colors = colors
        self.fonts = fonts
        self.themes = themes
        self.sizes = sizes
        
        let colorOptions = colors.keys.sorted().map { $0.itemColorName }.enumerated().map(OptionItem.init)
        self.colorItems = colorOptions + [OptionItem(id: colors.count, name: "-")]
        self.fontItems  = fonts.map { $0.itemName }.enumerated().map(OptionItem.init)
        self.themeItems = themes.map { $0.itemName }.enumerated().map(OptionItem.init)
        self.sizeItems  = sizes.map { $0.itemName }.enumerated().map(OptionItem.init)
    }
  
    // MARK: internal attributes
    private var currentFont: CarbonStyle.Font   { fonts.first(where:  { selectionFromFont($0)  == selectionFont  })! }
    private var currentTheme: CarbonStyle.Theme { themes.first(where: { selectionFromTheme($0) == selectionTheme })! }
    private var currentSize: CarbonStyle.Size   { sizes.first(where:  { selectionFromSize($0)  == selectionSize  })! }
    private var currentColor: CarbonStyle.Color { colorFromHex ?? .nef }
    
    private var colorFromHex: CarbonStyle.Color? {
        guard hex.count == 8 else { return nil }
        return CarbonStyle.Color(hex: hex)
    }
    
    private var hexFromColor: String? {
        let selectedColor = colorItems[selectionColor].name.lowercased()
        guard let selectedColorKey = colors.keys.first(where: { $0 == selectedColor }),
              let color = colors[selectedColorKey] else { return colorFromHex?.hex }
        
        return color.hex
    }
    
    // MARK: private methods
    private func apply(state: PreferencesModel) {
        self.showLines = state.showLines
        self.showWatermark = state.showWatermark
        self.selectionFont = selectionFromFont(state.font) ?? 0
        self.selectionTheme = selectionFromTheme(state.theme) ?? 0
        self.selectionSize = selectionFromSize(state.size) ?? 0
        self.selectionColor = selectionFromColor(state.color) ?? 0
    }
    
    private func persistState() {
        let state = PreferencesModel(showLines: showLines,
                                     showWatermark: showWatermark,
                                     font: currentFont,
                                     theme: currentTheme,
                                     size: currentSize,
                                     color: currentColor)
        
        preferences.persist(model: state)
    }
    
    // MARK: helpers
    func selectionFromFont(_ font: CarbonStyle.Font) -> Int? {
        return fontItems.enumerated().first(where: { $0.element.name == font.itemName })?.offset
    }
    
    func selectionFromTheme(_ theme: CarbonStyle.Theme) -> Int? {
        return themeItems.enumerated().first(where: { $0.element.name == theme.itemName })?.offset
    }
    
    func selectionFromSize(_ size: CarbonStyle.Size) -> Int? {
        return sizeItems.enumerated().first(where: { $0.element.name == size.itemName })?.offset
    }
    
    func selectionFromColor(_ color: CarbonStyle.Color) -> Int? {
        guard let carbonColor = CarbonStyle.Color.all.first(where: { _, value in color.description == value.description }) else { return nil }
        let keys = colorItems.map { $0.name.lowercased() }
        return keys.enumerated().first(where: { $0.element == carbonColor.key.lowercased() })?.offset
    }
    
    // MARK: update models and notify
    private func changedOption() {
        publishChanges()
    }
    
    private func changedColor() {
        guard let hexValue = hexFromColor else { return }
        
        let hasHexChanged = hex != hexValue
        if hasHexChanged {
            hex = hexValue
        } else {
            publishChanges()
        }
    }
    
    private func publishChanges() {
        persistState()
        didChange.send(self)
    }
    
    private func changedHex() {
        guard let color = colorFromHex,
              let selection = selectionFromColor(color) else { setSelectionCustomColor(); return }
        
        selectionColor = selection
    }
    
    private func setSelectionCustomColor() {
        selectionColor = colorItems.count - 1
    }
}


// MARK: delegate methods <ActionViewModel>
extension PreferencesViewModel: ActionViewModel {
    
    func onAppear() {
        apply(state: preferences.state)
    }
    
    func tapOnRestore() {
        apply(state: preferences.default)
        preferences.persist(model: preferences.default)
    }
}
