//  Copyright © 2019 The nef Authors.

import AppKit
import SwiftUI

import nef
import BowEffects


class Assembler {
    private lazy var preferencesDataSource = resolvePreferencesDataSource()
    
    func resolveAboutView() -> some View {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
        return AboutView(version: version, browser: Browser())
    }
    
    func resolvePreferencesView() -> some View {
        return PreferencesView(viewModel: resolvePreferencesViewModel())
    }
    
    // MARK: - utils
    func resolveOpenPanel() -> OpenPanel { OpenPanel() }
    
    func resolveCarbon(code: String, output: URL) -> IO<AppDelegate.Error, URL> {
        let model = CarbonModel(code: code, style: preferencesDataSource.state.carbonStyle)
        return nef.Carbon.render(carbon: model, toFile: output).mapLeft { _ in .carbon }
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
        return PreferencesDataSource(fileManager: .default)
    }
}
