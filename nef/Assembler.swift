//  Copyright © 2019 The nef Authors.

import AppKit
import UserNotifications
import SwiftUI
import nef

class Assembler {
    private lazy var preferencesDataSource = PreferencesDataSource(fileManager: .default)
    private lazy var progressReport = PlaygroundBookProgressReport()
    
    // MARK: - Common methods <helpers>
    fileprivate func resolvePreferencesViewModel() -> PreferencesViewModel {
        PreferencesViewModel(preferences: preferencesDataSource,
                             colors: CarbonStyle.Color.all,
                             fonts: CarbonStyle.Font.allCases,
                             themes: CarbonStyle.Theme.allCases,
                             sizes: CarbonStyle.Size.allCases)
    }
}

// MARK: - Views
extension Assembler {
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
}

// MARK: - Appareance
extension Assembler {
    func resolveCarbonStyle() -> CarbonStyle {
        preferencesDataSource.state.carbonStyle
    }
}

// MARK: - Utils
extension Assembler {
    func resolveOpenPanel() -> OpenPanel {
        OpenPanel()
    }
    
    func resolveProgressReport() -> ProgressReport {
        progressReport
    }
    
    func resolveClipboard() -> Pasteboard {
        MacPasteboard(pasteboard: .general)
    }
    
    func resolveNotificationCenter() -> Notifications {
        MacNotificationController(notificationCenter: .current())
    }
}
