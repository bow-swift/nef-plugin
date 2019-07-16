//  Copyright © 2019 The nef Authors.

import SwiftUI
import NefModels

struct PreferencesView: View {
    @ObjectBinding private var checkLinesViewModel: CheckViewModel
    @ObjectBinding private var checkWatermarkViewModel: CheckViewModel
    @ObjectBinding private var colorViewModel: PickerColorViewModel
    @ObjectBinding private var fontViewModel: PickerOptionViewModel
    @ObjectBinding private var themeViewModel: PickerOptionViewModel
    @ObjectBinding private var sizeViewModel: PickerOptionViewModel
    
    private var actionViewModels: [ActionViewModel] { [checkLinesViewModel, checkWatermarkViewModel, colorViewModel, fontViewModel, themeViewModel, sizeViewModel] }
    
    init(checkLinesViewModel: CheckViewModel,
         checkWatermarkViewModel: CheckViewModel,
         colorViewModel: PickerColorViewModel,
         fontViewModel: PickerOptionViewModel,
         themeViewModel: PickerOptionViewModel,
         sizeViewModel: PickerOptionViewModel) {
        
        self.checkLinesViewModel = checkLinesViewModel
        self.checkWatermarkViewModel = checkWatermarkViewModel
        self.colorViewModel = colorViewModel
        self.fontViewModel = fontViewModel
        self.themeViewModel = themeViewModel
        self.sizeViewModel = sizeViewModel
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
                CheckOptionView(text: i18n.Description.showLines, nested: false, selection: $checkLinesViewModel.selection)
                CheckOptionView(text: i18n.Description.showWatermark, nested: true, selection: $checkWatermarkViewModel.selection)
            }.padding(.all).offset(x: -12)

            VStack {
                PickerOptionView(title: i18n.Option.font, items: fontViewModel.options, selection: $fontViewModel.selection)
                PickerOptionView(title: i18n.Option.theme, items: themeViewModel.options, selection: $themeViewModel.selection)
                PickerOptionView(title: i18n.Option.size, items: sizeViewModel.options, selection: $sizeViewModel.selection)
                PickerOptionView(title: i18n.Option.color, items: colorViewModel.options, selection: $colorViewModel.selection)
                ColorOptionView(value: $colorViewModel.hex)
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
        actionViewModels.forEach { $0.onAppear() }
    }
    
    private func restore() {
        actionViewModels.forEach { $0.tapOnRestore() }
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
