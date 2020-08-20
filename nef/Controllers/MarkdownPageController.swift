//  Copyright © 2020 The nef Authors.

import Foundation

class MarkdownPageController: NefController {
    let page: String
    
    init?(page: String) {
        guard !page.isEmpty else { return nil }
        self.page = page
    }
    
    func run() -> Result<Void, Error> {
        fatalError()
        //        _ = markdownIO(playground: playground)
        //                .unsafeRunSyncEither()
        //                .map(self.showFile)
        //        self.terminate()
    }
}



//    // MARK: Helper methods

//
//    private func markdownIO(playground: String) -> IO<AppDelegate.Error, URL> {
//        assembler.resolveOpenPanel().writableFolder(create: true).use { folder in
//            let file = IO<OpenPanelError, URL>.var()
//            let output = IO<OpenPanelError, URL>.var()
//
//            return binding(
//                  file <- folder.outputURL(command: .markdownPage(playground: playground)),
//                output <- self.assembler.resolveMarkdownPage(playground: playground, output: file.get).mapError { _ in .unknown },
//            yield: output.get)
//        }^.mapError { _ in .markdown }^
//    }
