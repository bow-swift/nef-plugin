//  Copyright © 2020 The nef Authors.

import Foundation
import SourceEditorModels
import SourceEditorUtils

import nef
import Bow
import BowEffects


class PlaygroundBookController: NefController {
    let packageContent: String
    
    init?(packageContent: String) {
        guard !packageContent.isEmpty else { return nil }
        self.packageContent = packageContent
    }
    
    func runAsync(completion: @escaping (Result<Void, Swift.Error>) -> Void) {
        fatalError()
        //        playgroundBookIO(packageContent: package).unsafeRunAsync(on: .global(qos: .userInitiated))  { output in
        //            guard output.isRight else { return }
        //            Thread.sleep(forTimeInterval: 1)
        //            _ = output.map(self.showFile)
        //            self.terminate()
        //        }
    }
}


//    // MARK: Helper methods
//
//    private func playgroundBookIO(packageContent: String) -> IO<AppDelegate.Error, URL> {
//        assembler.resolveOpenPanel().writableFolder(create: true).use { folder in
//            let file = IO<OpenPanelError, URL>.var()
//            let output = IO<OpenPanelError, URL>.var()
//
//            return binding(
//                  file <- folder.outputURL(command: .playgroundBook(package: packageContent)),
//                output <- self.assembler.resolvePlaygroundBook(packageContent: packageContent, name: file.get.lastPathComponent, output: file.get.deletingLastPathComponent()).mapError { _ in .unknown },
//            yield: output.get)
//        }^.mapError { _ in .swiftPlayground }
//    }
//


// ASSEMBLER: nef
//
//    func resolvePlaygroundBook(packageContent: String, name: String, output: URL) -> IO<AppDelegate.Error, URL> {
//        nef.SwiftPlayground.render(packageContent: packageContent, name: name, output: output)
//                           .provide(progressReport)
//                           .mapError { _ in .swiftPlayground }^
//    }
