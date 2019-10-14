//  Copyright © 2019 The nef Authors.

import AppKit
import SwiftUI
import nef
import NefModels

class Assembler {
    
    private lazy var preferencesDataSource = resolvePreferencesDataSource()
    
    func resolveAboutView() -> some View {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
        return AboutView(version: version, browser: Browser())
    }
    
    func resolvePreferencesView() -> some View {
        return PreferencesView(viewModel: resolvePreferencesViewModel())
    }
    
    func resolveCarbonWindow(code: String, outputPath: String, completion: @escaping (_ status: Bool) -> Void) -> NSWindow {
        nef.carbon(code: code,
                   style: preferencesDataSource.state.style,
                   outputPath: outputPath,
                   success: { completion(true) }, failure: { _ in completion(false) })
    }
    
    // MARK: - utils
    func resolveOpenPanel() -> OpenPanel { OpenPanel() }
    
    // MARK: - private methods
    private func resolvePreferencesViewModel() -> PreferencesViewModel {
        return PreferencesViewModel(preferences: preferencesDataSource,
                                    colors: CarbonStyle.Color.all,
                                    fonts: CarbonStyle.Font.allCases,
                                    themes: CarbonStyle.Theme.allCases,
                                    sizes: CarbonStyle.Size.allCases)
    }
    
    private func resolvePreferencesDataSource() -> PreferencesDataSource {
        return PreferencesDataSource(fileManager: .default)
    }
}
