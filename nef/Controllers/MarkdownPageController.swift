//  Copyright © 2020 The nef Authors.

import Foundation
import SourceEditorModels
import SourceEditorUtils

import nef
import Bow
import BowEffects


struct MarkdownPageConfig {
    let openPanel: OpenPanel
    let progressReport: ProgressReport
    let render: (String, URL) -> EnvIO<MarkdownPageConfig, MarkdownPageError, URL>
}

enum MarkdownPageError: Swift.Error {
    case render(Error)
    case openPanel
}

class MarkdownPageController: NefController {
    let page: String
    let config: MarkdownPageConfig
    
    init?(page: String, openPanel: OpenPanel, progressReport: ProgressReport) {
        guard !page.isEmpty else { return nil }
        self.page = page
        self.config = MarkdownPageConfig(openPanel: openPanel, progressReport: progressReport, render: MarkdownPageController.render)
    }
    
    func runAsync(completion: @escaping (Result<Void, Swift.Error>) -> Void) {
        runIO(page: page).provide(config)
            .map(Browser.showFile)^
            .unsafeRunAsyncResult(completion: completion)
    }
    
    func runIO(page: String) -> EnvIO<MarkdownPageConfig, OpenPanelError, URL> {
        EnvIO { env in
            env.openPanel.writableFolder(create: true).use { folder in
                self.markdownIO(folder: folder, page: page)
                    .provide(env)^
                    .mapError { _ in .unknown }
            }
        }^
    }
    
    private func markdownIO(folder: URL, page: String) -> EnvIO<MarkdownPageConfig, MarkdownPageError, URL> {
        let env = EnvIO<MarkdownPageConfig, MarkdownPageError, MarkdownPageConfig>.var()
        let file = EnvIO<MarkdownPageConfig, MarkdownPageError, URL>.var()
        let output = EnvIO<MarkdownPageConfig, MarkdownPageError, URL>.var()
        
        return binding(
               env <- .ask(),
              file <- folder.outputURL(command: .markdownPage(playground: page)).env(),
            output <- env.get.render(page, file.get),
        yield: output.get)^
    }
    
    private static func render(content: String, toFile file: URL) -> EnvIO<MarkdownPageConfig, MarkdownPageError, URL> {
        nef.Markdown.render(content: content, toFile: file)
            .contramap(\.progressReport)
            .mapError { e in .render(e) }
    }
}
