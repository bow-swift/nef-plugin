//  Copyright © 2019 The nef Authors.

import AppKit
import SwiftUI

import nef
import NefModels

class Assembler {
    
    lazy var preferencesDataSource = resolvePreferencesDataSource()
    
    func resolvePreferencesView() -> some View {
        return PreferencesView(checkLinesViewModel: resolveCheckLinesViewModel(),
                               checkWatermarkViewModel: resolveCheckWatermarkViewModel(),
                               colorViewModel: resolveColorViewModel(),
                               fontViewModel: resolveFontViewModel(),
                               themeViewModel: resolveThemeViewModel(),
                               sizeViewModel: resolveSizeViewModel())
    }
    
    func resolveCarbonWindow(code: String, completion: @escaping () -> Void) -> NSWindow? {
        guard let downloadsFolder = try? FileManager.default.url(for: .downloadsDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else { return nil }
        
        let filename = "nef \(Date.now.human)"
        let outputPath = downloadsFolder.appendingPathComponent(filename).path
        
        let style = CarbonStyle(background: .nef,
                                theme: .dracula,
                                size: .x3,
                                fontType: .firaCode,
                                lineNumbers: true,
                                watermark: true)
        
        return nef.carbon(code: code,
                          style: style,
                          outputPath: outputPath,
                          success: completion, failure: { _ in completion() })
    }
    
    // MARK: - View-Models
    private func resolveCheckLinesViewModel() -> CheckViewModel {
        return CheckViewModel(dataSource: preferencesDataSource)
    }
    
    private func resolveCheckWatermarkViewModel() -> CheckViewModel {
        return CheckViewModel(dataSource: preferencesDataSource)
    }
    
    private func resolveColorViewModel() -> PickerColorViewModel {
        return PickerColorViewModel(dataSource: preferencesDataSource,
                                    colors: CarbonStyle.Color.all)
    }
    
    private func resolvePreferencesDataSource() -> PreferencesDataSource {
        return PreferencesDataSource()
    }
    
    private func resolveFontViewModel() -> PickerOptionViewModel {
        let fonts  = CarbonStyle.Font.allCases
        let fontItems = fonts.map { $0.rawValue.capitalized }.enumerated().map(OptionItem.init)
        
        return PickerOptionViewModel(dataSource: preferencesDataSource,
                                     options: fontItems)
    }
    
    private func resolveThemeViewModel() -> PickerOptionViewModel {
        let themes = CarbonStyle.Theme.allCases
        let themeItems = themes.map { $0.rawValue.replacingOccurrences(of: "-", with: " ").capitalized }.enumerated().map(OptionItem.init)
        
        return PickerOptionViewModel(dataSource: preferencesDataSource,
                                     options: themeItems)
    }
    
    private func resolveSizeViewModel() -> PickerOptionViewModel {
        let sizes  = CarbonStyle.Size.allCases
        let sizeItems = sizes.map { "\($0.rawValue)".replacingOccurrences(of: ".0", with: "x") }.enumerated().map(OptionItem.init)
        
        return PickerOptionViewModel(dataSource: preferencesDataSource,
                                     options: sizeItems)
    }
}
