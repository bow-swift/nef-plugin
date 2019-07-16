//  Copyright © 2019 The nef Authors.

import SwiftUI
import NefModels

struct PreferencesView: View {
    private let fonts  = CarbonStyle.Font.allCases
    private let themes = CarbonStyle.Theme.allCases
    private let sizes  = CarbonStyle.Size.allCases

    private var fontItems: [OptionItem]  { fonts.map { $0.rawValue.capitalized }.enumerated().map(OptionItem.init) }
    private var themeItems: [OptionItem] { themes.map { $0.rawValue.replacingOccurrences(of: "-", with: " ").capitalized }.enumerated().map(OptionItem.init) }
    private var sizeItems: [OptionItem]  { sizes.map { "\($0.rawValue)".replacingOccurrences(of: ".0", with: "x") }.enumerated().map(OptionItem.init)  }
    
    @State private var selectedFont: Int  = 0
    @State private var selectedTheme: Int = 0
    @State private var selectedSize: Int  = 0
    @State private var showLines = true
    @State private var showWatermark = true
    
    @ObjectBinding private var colorViewModel: PickerColorViewModel
    
    init(colorViewModel: PickerColorViewModel) {
        self.colorViewModel = colorViewModel
    }
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text(i18n.title)
                    .font(.system(size: 11))
                    .fontWeight(.regular)
                    .color(.blue)
                Spacer()
                
                ImageButton(image: Image("restore"), color: .blue, action: restore)
                    .frame(width: 20, height: 20)
            }.padding(6)
                .frame(maxWidth: .infinity, maxHeight: 30)
                .border(NefColor.gray)

            VStack {
                CheckOptionView(text: i18n.Description.showLines, nested: false, selection: $showLines)
                CheckOptionView(text: i18n.Description.showWatermark, nested: true, selection: $showWatermark)
            }.padding(.all).offset(x: -12)

            VStack {
                PickerOptionView(title: i18n.Option.font, items: fontItems, selection: $selectedFont)
                PickerOptionView(title: i18n.Option.theme, items: themeItems, selection: $selectedTheme)
                PickerOptionView(title: i18n.Option.size, items: sizeItems, selection: $selectedSize)
                PickerOptionView(title: i18n.Option.color, items: colorViewModel.options, selection: $colorViewModel.selection)
                ColorOptionView(value: $colorViewModel.hex)
            }.padding(.bottom).offset(x: -12)

            Spacer()
        }.border(NefColor.gray)
         .background(NefColor.white)
         .frame(maxWidth: .infinity, maxHeight: .infinity)
         .padding(20)
         .onAppear(perform: setInitialValues)
    }
    
    // MARK: private methods
    private func restore() {
        setInitialValues()
        persist()
    }
    
    private func setInitialValues() {
        selectedFont = fonts.enumerated().first(where: { $0.element == .firaCode })?.offset ?? 0
        selectedTheme = themes.enumerated().first(where: { $0.element == .dracula })?.offset ?? 0
        selectedSize = sizes.enumerated().first(where: { $0.element == .x2 })?.offset ?? 0
        colorViewModel.reset()
        showLines = true
        showWatermark = true
    }
    
    private func persist() {
        // TODO
    }
    
    // MARK: - Constants
    enum i18n {
        static let title = NSLocalizedString("Carbon", comment: "")
        
        enum Option {
            static let font = NSLocalizedString("Font type", comment: "")
            static let theme = NSLocalizedString("Theme", comment: "")
            static let color = NSLocalizedString("Background color", comment: "")
            static let size = NSLocalizedString("Size", comment: "")
        }
        
        enum Description {
            static let showLines = NSLocalizedString("Line numbers", comment: "")
            static let showWatermark = NSLocalizedString("Watermark", comment: "")
        }
    }
    
    enum Layout {
        static let leftPanel: CGFloat  = 150
        static let rightPanel: CGFloat = 220
    }
    
    enum NefColor {
        static let gray = Color(red: 0.78, green: 0.78, blue: 0.78)
        static let white = Color(red: 1, green: 1, blue: 1)
    }
}
