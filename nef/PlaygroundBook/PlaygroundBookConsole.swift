//  Copyright © 2019 The nef Authors.

import Foundation
import SwiftUI

import nef
import Bow
import BowEffects


class PlaygroundBookConsole: Console, ObservableObject {
    enum Status: String {
        case failure
        case succesful
        case running
    }
    
    @Published var totalSteps: UInt  = 0
    @Published var currentStep: UInt = 0
    @Published var task: String = ""
    @Published var details: [String] = []
    @Published var status: Status = .succesful
    @Published var duration: DispatchTimeInterval = .seconds(1)
    
    func printStep<E: Swift.Error>(step: Step, information: String) -> IO<E, Void> {
        IO.invoke { self.update(step: step, task: information, details: [], status: .running, duration: step.estimatedDuration) }^
    }
    
    func printSubstep<E: Swift.Error>(step: Step, information: [String]) -> IO<E, Void> {
        IO.invoke { self.update(step: step, details: information, status: .running, duration: step.estimatedDuration) }^
    }
    
    func printStatus<E: Swift.Error>(step: Step, success: Bool) -> IO<E, Void> {
        IO.invoke { self.update(step: step, details: [], status: success ? .succesful : .failure, duration: step.estimatedDuration) }^
    }
    
    func printStatus<E: Swift.Error>(step: Step, information: String, success: Bool) -> IO<E, Void> {
        IO.invoke { self.update(step: step, details: [information], status: success ? .succesful : .failure, duration: step.estimatedDuration) }^
    }
    
    // MARK: internal helpers
    private func update(step: Step, task: String = "", details: [String], status: Status, duration: DispatchTimeInterval) {
        DispatchQueue.main.async {
            self.totalSteps  = step.total
            self.currentStep = step.partial
            self.task = task
            if !details.isEmpty { self.details = details }
            self.status  = status
            self.duration = duration
        }
    }
}
