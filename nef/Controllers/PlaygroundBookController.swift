//  Copyright © 2020 The nef Authors.

import Foundation
import SourceEditorModels
import SourceEditorUtils

import nef
import Bow
import BowEffects


struct PlaygroundBookConfig {
    let openPanel: OpenPanel
    let progressReport: ProgressReport
    let render: (String, String, URL) -> EnvIO<PlaygroundBookConfig, OpenPanelError, URL>
}

class PlaygroundBookController: NefController {
    let packageContent: String
    let config: PlaygroundBookConfig
    
    init?(packageContent: String, openPanel: OpenPanel, progressReport: ProgressReport) {
        guard !packageContent.isEmpty else { return nil }
        self.packageContent = packageContent
        self.config = .init(openPanel: openPanel, progressReport: progressReport, render: PlaygroundBookController.render)
    }
    
    func runAsync(completion: @escaping (Result<Void, Swift.Error>) -> Void) {
        runIO(packageContent: packageContent).provide(config)
            .map(Browser.showFile)^
            .unsafeRunAsyncResult(on: .global(qos: .userInitiated), completion: completion)
    }
    
    func runIO(packageContent: String) -> EnvIO<PlaygroundBookConfig, OpenPanelError, URL> {
        EnvIO.accessM { config in
            config.openPanel.writableFolder(create: true).use { folder in
                self.render(packageContent: packageContent, into: folder).provide(config)
            }^.env()^
        }^
    }
    
    private func render(packageContent: String, into folder: URL) -> EnvIO<PlaygroundBookConfig, OpenPanelError, URL> {
        EnvIO.accessM { config in
            let file = EnvIO<PlaygroundBookConfig, OpenPanelError, URL>.var()
            let output = EnvIO<PlaygroundBookConfig, OpenPanelError, URL>.var()
            
            return binding(
                  file <- folder.outputURL(command: .playgroundBook(package: packageContent)),
                output <- config.render(packageContent, file.get.lastPathComponent, file.get.deletingLastPathComponent()),
            yield: output.get)^
        }
    }
    
    private static func render(packageContent: String, name: String, output: URL) ->  EnvIO<PlaygroundBookConfig, OpenPanelError, URL> {
        nef.SwiftPlayground.render(packageContent: packageContent, name: name, output: output)
            .contramap(\.progressReport)
            .mapError { _ in OpenPanelError.unknown }
    }
}
