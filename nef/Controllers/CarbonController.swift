//  Copyright © 2020 The nef Authors.

import Foundation

enum CarbonOutput {
    case clipboard
    case file
}

class CarbonController: NefController {
    let code: String
    let output: CarbonOutput
    
    init?(code: String, output: CarbonOutput) {
        guard !code.isEmpty else { return nil }
        self.code = code
        self.output = output
    }
    
    func run() -> Result<Void, Error> {
        fatalError()
        // -------- CARBON FILE
        //        carbonIO(code: code).unsafeRunAsync(on: .global(qos: .userInitiated)) { output in
        //            _ = output.map(self.showFile)
        //            self.terminate()
        //        }
        
        // -------- CARBON CLIPBOARD
        //        let config = Clipboard.Config(clipboard: .general, notificationCenter: .current())
        //
        //        assembler.resolveCarbon(code: code).env()^.mapError { _ in .carbon }
        //            .flatMap(clipboardCarbonIO)^
        //            .provide(config)
        //            .unsafeRunAsync(on: .global(qos: .userInitiated)) { output in
        //                _ = output.map { _ in
        //                    self.terminate()
        //                }
        //        }
    }
}


//    // MARK: Helper methods
//    private func carbonIO(code: String) -> IO<AppDelegate.Error, URL> {
//        let panel = assembler.resolveOpenPanel()
//        let image = IO<AppDelegate.Error, Data>.var()
//        let output = IO<AppDelegate.Error, URL>.var()
//
//        return binding(
//              image <- self.assembler.resolveCarbon(code: code),
//             output <- image.get.persist(command: .exportSnippet(selection: code)).provide(panel).mapError { _ in .carbon },
//        yield: output.get)^
//    }
