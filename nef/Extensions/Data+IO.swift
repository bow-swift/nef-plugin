//  Copyright © 2020 The nef Authors.

import Foundation
import SourceEditorModels
import Bow
import BowEffects

extension Data {
    
    func persist(command: Command) -> EnvIO<OpenPanel, OpenPanelError, URL> {
        func writeIO(to url: URL) -> IO<OpenPanelError, URL> {
            IO<Error, Void>.invoke { try self.write(to: url) }
                .mapError { _ in OpenPanelError.unknown }^
                .as(url)^
        }
        
        return EnvIO.accessM { panel in
            panel.writableFolder(create: true).use { folder in
                folder.outputURL(command: command)
                      .flatMap(writeIO)^
            }^.env()
        }^
    }
}
