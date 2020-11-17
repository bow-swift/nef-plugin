//  Copyright © 2019 The nef Authors.

import SwiftUI

struct PreferencesView: View {
    @ObservedObject private var viewModel: PreferencesViewModel
    
    init(viewModel: PreferencesViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            // Title bar
            HStack {
                Spacer()
                Text(i18n.title)
                    .font(.system(size: 11))
                    .fontWeight(.regular)
                    .foregroundColor(.blue)
                Spacer()
                
                ImageButton(image: NefImage.restore, color: .blue, action: restore)
                    .frame(width: 14, height: 14)
                    .offset(x: -4)
            }.padding(6)
             .frame(maxWidth: .infinity, maxHeight: 30)
             .border(NefColor.border)
            
            // Preferences options
            OutputFolderView().offset(x: -12, y: 12)
            
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
            
            // Carbon viewer
            CarbonViewer(state: $viewModel.state).frame(maxWidth: .infinity)
                .background(NefColor.background)
                .cornerRadius(12, antialiased: true)
                .padding(22)
            
        }.border(NefColor.border)
         .background(NefColor.panel)
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
        static let title = NSLocalizedString("preferences_title", comment: "")
        
        enum Option {
            static let font = NSLocalizedString("preferences_option_font", comment: "")
            static let theme = NSLocalizedString("preferences_option_theme", comment: "")
            static let color = NSLocalizedString("preferences_option_color", comment: "")
            static let size = NSLocalizedString("preferences_option_size", comment: "")
        }
        
        enum Description {
            static let showLines = NSLocalizedString("preferences_description_lines", comment: "")
            static let showWatermark = NSLocalizedString("preferences_description_watermark", comment: "")
        }
    }
    
    enum Layout {
        static let leftPanel: CGFloat  = 150
        static let rightPanel: CGFloat = 220
    }
    
    enum NefImage {
        static let restore = Image("restore")
    }
    
    enum NefColor {
        static let background = Color("background-color")
        static let panel = Color("panel-color")
        static let border = Color("panel-border-color")
    }
}

// MARK: - CarbonStyle View
import nef

extension CarbonStyle.Font {
    var itemName: String { rawValue }
}

extension CarbonStyle.Size {
    var itemName: String { "\(rawValue)".replacingOccurrences(of: ".0", with: "x") }
}

extension CarbonStyle.Theme {
    var itemName: String { rawValue.replacingOccurrences(of: "-", with: " ").capitalized }
}

extension CarbonStyle {
    static func itemColorName(in value: String) -> String {
        value.lowercased() != "nef" ? value.capitalized : value
    }
}
