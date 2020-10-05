//  Copyright © 2019 The nef Authors.

import AppKit
import SwiftUI

import nef
import BowEffects


class Assembler {
    private lazy var preferencesDataSource = resolvePreferencesDataSource()
    private lazy var progressReport = resolvePlaygroundBookProgressReport()
    
    
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
    
    // MARK: - utils
    func resolveOpenPanel() -> OpenPanel { OpenPanel() }
    
    func resolveCarbon(code: String) -> IO<AppDelegate.Error, Data> {
        nef.Carbon.render(code: code, style: preferencesDataSource.state.carbonStyle)
            .provide(progressReport)
            .mapError { _ in .carbon }
    }
    
    func resolveMarkdownPage(playground: String, output: URL) -> IO<AppDelegate.Error, URL> {
        nef.Markdown.render(content: playground, toFile: output)
            .provide(progressReport)
            .mapError { _ in .markdown }
    }
    
    func resolvePlaygroundBook(packageContent: String, name: String, output: URL) -> IO<AppDelegate.Error, URL> {
        nef.SwiftPlayground.render(packageContent: packageContent, name: name, output: output)
                           .provide(progressReport)
                           .mapError { _ in .swiftPlayground }^
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
