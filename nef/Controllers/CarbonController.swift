//  Copyright © 2020 The nef Authors.

import Foundation
import AppKit
import SourceEditorModels
import SourceEditorUtils

import nef
import Bow
import BowEffects


enum CarbonError: Swift.Error {
    case render(Error)
    case openPanel
    case invalidData
    case writeToClipboard
}


struct CarbonFileConfig {
    let style: CarbonStyle
    let progressReport: ProgressReport
    let panel: OpenPanel
    let render: (String, CarbonStyle) -> EnvIO<ProgressReport, CarbonError, Data>
}

class CarbonFileController: NefController {
    let code: String
    let config: CarbonFileConfig
    
    init?(code: String, style: CarbonStyle, progressReport: ProgressReport, panel: OpenPanel) {
        guard !code.isEmpty else { return nil }
        self.code = code
        self.config = .init(style: style, progressReport: progressReport, panel: panel, render: CarbonController.render)
    }
    
    func runAsync(completion: @escaping (Result<Void, Swift.Error>) -> Void) {
        runIO(code: code).provide(config)
            .map(Browser.showFile)^
            .unsafeRunAsyncResult(on: .global(qos: .userInitiated), completion: completion)
    }
    
    func runIO(code: String) -> EnvIO<CarbonFileConfig, CarbonError, URL> {
        let env = EnvIO<CarbonFileConfig, CarbonError, CarbonFileConfig>.var()
        let data = EnvIO<CarbonFileConfig, CarbonError, Data>.var()
        let output = EnvIO<CarbonFileConfig, CarbonError, URL>.var()
        
        return binding(
               env <- .ask(),
              data <- env.get.render(code, env.get.style).contramap(\.progressReport),
            output <- data.get.persist(command: .exportSnippet(selection: code))
                              .contramap(\.panel)
                              .mapError { _ in .openPanel },
        yield: output.get)^
    }
}


struct CarbonClipboardConfig {
    let style: CarbonStyle
    let progressReport: ProgressReport
    let clipboard: Clipboard
    let notifications: Notifications
    let render: (String, CarbonStyle) -> EnvIO<ProgressReport, CarbonError, Data>
}

class CarbonClipboardController: NefController {
    let code: String
    let config: CarbonClipboardConfig
    
    init?(code: String, style: CarbonStyle, progressReport: ProgressReport, clipboard: Clipboard, notifications: Notifications) {
        guard !code.isEmpty else { return nil }
        self.code = code
        self.config = .init(style: style, progressReport: progressReport, clipboard: clipboard, notifications: notifications, render: CarbonController.render)
    }
    
    func runAsync(completion: @escaping (Result<Void, Swift.Error>) -> Void) {
        runIO(code: code).provide(config)
            .as(())^
            .unsafeRunAsyncResult(on: .global(qos: .userInitiated), completion: completion)
    }
    
    func runIO(code: String) -> EnvIO<CarbonClipboardConfig, CarbonError, NSImage> {
        let env = EnvIO<CarbonClipboardConfig, CarbonError, CarbonClipboardConfig>.var()
        let image = EnvIO<CarbonClipboardConfig, CarbonError, NSImage>.var()
        let data = EnvIO<CarbonClipboardConfig, CarbonError, Data>.var()
        
        return binding(
               env <- .ask(),
              data <- env.get.render(code, env.get.style).contramap(\.progressReport),
             image <- data.get.makeImage().mapError { _ in .invalidData }^,
                   |<-env.get.clipboard.write(image.get).mapError { _ in .writeToClipboard },
                   |<-env.get.notifications.removeAllDelivered(),
                   |<-env.get.notifications.show(title: "nef",
                                                 body: "Image copied to clipboard!",
                                                 options: .init(imageData: data.get, actions: [.cancel, .saveImage])),
        yield: image.get)^
    }
}


// MARK: - Helpers
enum CarbonController {
    static func render(code: String, style: CarbonStyle) -> EnvIO<ProgressReport, CarbonError, Data> {
        nef.Carbon.render(code: code, style: style)
            .mapError { e in .render(e) }^
    }
}

fileprivate extension Data {
    func makeImage<D>() -> EnvIO<D, CarbonError, NSImage> {
        EnvIO.invoke { _ in
            guard let image = NSImage(data: self) else {
                throw CarbonError.invalidData
            }
            return image
        }
    }
}
