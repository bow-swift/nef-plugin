//  Copyright © 2019 The nef Authors.

import SwiftUI

struct PreferencesView: View {
    @ObjectBinding private var viewModel: PreferencesViewModel
    
    init(viewModel: PreferencesViewModel) {
        self.viewModel = viewModel
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
                CheckOptionView(text: i18n.Description.showLines, nested: false, selection: $viewModel.showLines)
                CheckOptionView(text: i18n.Description.showWatermark, nested: true, selection: $viewModel.showWatermark)
            }.padding(.all).offset(x: -12)

            VStack {
                PickerOptionView(title: i18n.Option.font, items: viewModel.fontItems, selection: $viewModel.selectionFont)
                PickerOptionView(title: i18n.Option.theme, items: viewModel.themeItems, selection: $viewModel.selectionTheme)
                PickerOptionView(title: i18n.Option.size, items: viewModel.sizeItems, selection: $viewModel.selectionSize)
                PickerOptionView(title: i18n.Option.color, items: viewModel.colorItems, selection: $viewModel.selectionColor)
                ColorOptionView(value: $viewModel.hex)
            }.padding(.bottom).offset(x: -12)

            Spacer()
        }.border(NefColor.gray)
         .background(NefColor.white)
         .frame(maxWidth: .infinity, maxHeight: .infinity)
         .padding(20)
         .onAppear(perform: onAppear)
    }
    
    // MARK: private methods
    private func onAppear() {
        viewModel.onAppear()
    }
    
    private func restore() {
        viewModel.tapOnRestore()
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

// MARK: - CarbonStyle View
import NefModels

extension CarbonStyle.Font {
    var itemName: String { rawValue.capitalized }
}

extension CarbonStyle.Size {
    var itemName: String { "\(rawValue)".replacingOccurrences(of: ".0", with: "x") }
}

extension CarbonStyle.Theme {
    var itemName: String { rawValue.replacingOccurrences(of: "-", with: " ").capitalized }
}

extension String {
    var itemColorName: String { self != "nef" ? capitalized : self }
}
