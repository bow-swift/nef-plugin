//  Copyright © 2019 The nef Authors.

import AppKit
import SwiftUI

import nef
import Bow
import BowEffects


class Assembler {
    private lazy var preferencesDataSource = resolvePreferencesDataSource()
    private lazy var progressReport = resolvePlaygroundBookProgressReport()
    
    // MARK: - Views
    func resolveAboutView() -> some View {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
        return AboutView(version: version)
    }
    
    func resolvePreferencesView() -> some View {
        PreferencesView(viewModel: resolvePreferencesViewModel())
    }
    
    func resolvePlaygroundBookView() -> some View {
        PlaygroundBookView(progressReport: progressReport)
    }
    
    // MARK: - Utils
    func resolveOpenPanel() -> OpenPanel {
        OpenPanel()
    }
    
    func resolveProgressReport() -> ProgressReport {
        progressReport
    }
    
    // MARK: - private methods
    private func resolvePreferencesViewModel() -> PreferencesViewModel {
        PreferencesViewModel(preferences: preferencesDataSource,
                             colors: CarbonStyle.Color.all,
                             fonts: CarbonStyle.Font.allCases,
                             themes: CarbonStyle.Theme.allCases,
                             sizes: CarbonStyle.Size.allCases)
    }
    
    private func resolvePreferencesDataSource() -> PreferencesDataSource {
        PreferencesDataSource(fileManager: .default)
    }
    
    private func resolvePlaygroundBookProgressReport() -> PlaygroundBookProgressReport {
        PlaygroundBookProgressReport()
    }
}
