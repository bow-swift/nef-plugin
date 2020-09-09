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
}

class CarbonFileController: NefController {
    let code: String
    let config: CarbonFileConfig
    
    init?(code: String, style: CarbonStyle, progressReport: ProgressReport, panel: OpenPanel) {
        guard !code.isEmpty else { return nil }
        self.code = code
        self.config = .init(style: style, progressReport: progressReport, panel: panel)
    }
    
    func runAsync(completion: @escaping (Result<Void, Swift.Error>) -> Void) {
        runIO(code: code).provide(config)
            .map(Browser.showFile)^
            .unsafeRunAsyncResult(on: .global(qos: .userInitiated), completion: completion)
    }
    
    func runIO(code: String) -> EnvIO<CarbonFileConfig, CarbonError, URL> {
        let env = EnvIO<CarbonFileConfig, CarbonError, CarbonFileConfig>.var()
        let image = EnvIO<CarbonFileConfig, CarbonError, Data>.var()
        let output = EnvIO<CarbonFileConfig, CarbonError, URL>.var()
        
        return binding(
               env <- .ask(),
             image <- nef.Carbon.render(code: code, style: env.get.style)
                                .contramap(\.progressReport).mapError { e in .render(e) },
            output <- image.get.persist(command: .exportSnippet(selection: code))
                               .contramap(\.panel).mapError { _ in .openPanel },
        yield: output.get)^
    }
}


struct CarbonClipboardConfig {
    let style: CarbonStyle
    let progressReport: ProgressReport
    let pasteboard: Pasteboard
    let notifications: Notifications
}

class CarbonClipboardController: NefController {
    let code: String
    let config: CarbonClipboardConfig
    
    init?(code: String, style: CarbonStyle, progressReport: ProgressReport, pasteboard: Pasteboard, notifications: Notifications) {
        guard !code.isEmpty else { return nil }
        self.code = code
        self.config = .init(style: style, progressReport: progressReport, pasteboard: pasteboard, notifications: notifications)
    }
    
    func runAsync(completion: @escaping (Result<Void, Swift.Error>) -> Void) {
        runIO(code: code).provide(config)
            .as(())^
            .unsafeRunAsyncResult(on: .global(qos: .userInitiated), completion: completion)
    }
    
    func runIO(code: String) -> EnvIO<CarbonClipboardConfig, CarbonError, NSImage> {
        let env = EnvIO<CarbonClipboardConfig, CarbonError, CarbonClipboardConfig>.var()
        let data = EnvIO<CarbonClipboardConfig, CarbonError, Data>.var()
        let image = EnvIO<CarbonClipboardConfig, CarbonError, NSImage>.var()
        
        return binding(
               env <- .ask(),
              data <- nef.Carbon.render(code: code, style: env.get.style)
                                .contramap(\.progressReport).mapError { e in .render(e) },
             image <- data.get.makeImage().mapError { _ in .invalidData },
                   |<-env.get.pasteboard.write(image.get).mapError { _ in .writeToClipboard },
                   |<-env.get.notifications.removeAllDelivered(),
                   |<-env.get.notifications.show(title: "nef",
                                                 body: "Image copied to clipboard!",
                                                 options: .init(imageData: data.get, actions: [.cancel, .saveImage])),
        yield: image.get)^
    }
}


// MARK: - Helpers
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
