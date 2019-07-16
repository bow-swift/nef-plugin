//  Copyright © 2019 The nef Authors.

import AppKit
import SwiftUI

import nef
import NefModels

class Assembler {
    
    lazy var preferencesDataSource = resolvePreferencesDataSource()
    
    func resolvePreferencesView() -> some View {
        return PreferencesView(viewModel: resolvePreferencesViewModel())
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
    
    // MARK: - private methods
    private func resolvePreferencesViewModel() -> PreferencesViewModel {
        return PreferencesViewModel(preferences: preferencesDataSource,
                                    colors: CarbonStyle.Color.all,
                                    fonts: CarbonStyle.Font.allCases,
                                    themes: CarbonStyle.Theme.allCases,
                                    sizes: CarbonStyle.Size.allCases)
    }
    
    private func resolvePreferencesDataSource() -> PreferencesDataSource {
        return PreferencesDataSource()
    }
}
