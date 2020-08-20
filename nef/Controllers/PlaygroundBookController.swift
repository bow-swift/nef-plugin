//  Copyright © 2020 The nef Authors.

import Foundation

class PlaygroundBookController: NefController {
    let packageContent: String
    
    init?(packageContent: String) {
        guard !packageContent.isEmpty else { return nil }
        self.packageContent = packageContent
    }
    
    func run() -> Result<Void, Error> {
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
