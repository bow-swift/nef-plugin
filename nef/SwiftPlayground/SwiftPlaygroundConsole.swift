//  Copyright © 2019 The nef Authors.

import Foundation
import nef
import Bow
import BowEffects

class SwiftPlaygroundConsole: Console {
    func printStep<E: Swift.Error>(step: Step, information: String) -> IO<E, Void> {
        IO.pure(())^
    }
    
    func printSubstep<E: Swift.Error>(step: Step, information: [String]) -> IO<E, Void> {
        IO.pure(())^
    }
    
    func printStatus<E: Swift.Error>(step: Step, success: Bool) -> IO<E, Void> {
        IO.pure(())^
    }
    
    func printStatus<E: Swift.Error>(step: Step, information: String, success: Bool) -> IO<E, Void> {
        IO.pure(())^
    }
}
