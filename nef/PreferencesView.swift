//  Copyright © 2019 The nef Authors.

import SwiftUI
import NefModels

struct PreferencesView: View {
    private let fonts  = CarbonStyle.Font.allCases
    private let themes = CarbonStyle.Theme.allCases
    private let colors = CarbonStyle.Color.all.keys.sorted()
    private let sizes  = CarbonStyle.Size.allCases

    private var fontItems: [OptionItem]  { fonts.map { $0.rawValue.capitalized }.enumerated().map(OptionItem.init) }
    private var themeItems: [OptionItem] { themes.map { $0.rawValue.replacingOccurrences(of: "-", with: " ").capitalized }.enumerated().map(OptionItem.init) }
    private var colorItems: [OptionItem] { colors.map { $0 != "nef" ? $0.capitalized : $0 }.enumerated().map(OptionItem.init) }
    private var sizeItems: [OptionItem]  { sizes.map { "\($0.rawValue)".replacingOccurrences(of: ".0", with: "x") }.enumerated().map(OptionItem.init)  }
    
    @State private var selectedFont: Int  = 0
    @State private var selectedTheme: Int = 0
    @State private var selectedSize: Int  = 0
    @State private var selectedColor: Int = 0
    
    @State private var option: Int = 0
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text(i18n.title)
                    .font(.system(size: 11))
                    .fontWeight(.regular)
                    .color(.blue)
                Spacer()
            }.padding(6)
             .frame(maxWidth: .infinity)
             .border(Color(red: 0.78, green: 0.78, blue: 0.78))
            
            VStack {
                PickerOptionView(title: i18n.font, items: fontItems, selection: $selectedFont)
                PickerOptionView(title: i18n.theme, items: themeItems, selection: $selectedTheme)
                PickerOptionView(title: i18n.size, items: sizeItems, selection: $selectedSize)
                PickerOptionView(title: i18n.color, items: colorItems, selection: $selectedColor)
            }.padding(20)
            
            Spacer()
        }.border(Color(red: 0.78, green: 0.78, blue: 0.78))
         .background(Color(red: 1, green: 1, blue: 1))
         .frame(maxWidth: .infinity, maxHeight: .infinity)
         .padding(20)
    }
}

enum i18n {
    static let title = NSLocalizedString("Preferences", comment: "")
    
    static let font = NSLocalizedString("Font", comment: "")
    static let theme = NSLocalizedString("Theme", comment: "")
    static let color = NSLocalizedString("Color", comment: "")
    static let size = NSLocalizedString("Size", comment: "")
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        PreferencesView()
    }
}
#endif
