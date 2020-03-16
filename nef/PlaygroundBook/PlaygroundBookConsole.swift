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
    @Published var details: String = ""
    @Published var historical: String = ""
    
    @Published var status: Status = .succesful
    @Published var duration: DispatchTimeInterval = .seconds(1)
    
    private var lastTasks: [String] = []
    
    func printStep<E: Swift.Error>(step: Step, information: String) -> IO<E, Void> {
        IO.invoke { self.update(step: step, task: information, details: [], status: .running) }^
    }
    
    func printSubstep<E: Swift.Error>(step: Step, information: [String]) -> IO<E, Void> {
        IO.invoke { self.update(step: step, details: information, status: .running) }^
    }
    
    func printStatus<E: Swift.Error>(step: Step, success: Bool) -> IO<E, Void> {
        IO.invoke { self.update(step: step, details: [], status: success ? .succesful : .failure) }^
    }
    
    func printStatus<E: Swift.Error>(step: Step, information: String, success: Bool) -> IO<E, Void> {
        IO.invoke { self.update(step: step, details: [information], status: success ? .succesful : .failure) }^
    }
    
    func printStatus<E: Swift.Error>(success: Bool) -> IO<E, Void> {
        IO.invoke { self.update(step: Step.empty, details: [], status: success ? .succesful : .failure) }^
    }
    
    func printStatus<E: Swift.Error>(information: String, success: Bool) -> IO<E, Void> {
        IO.invoke { self.update(step: Step.empty, details: [information], status: success ? .succesful : .failure) }^
    }
    
    // MARK: internal helpers
    private func update(step: Step, task: String = "", details: [String], status: Status) {
        DispatchQueue.main.async {
            self.totalSteps  = step.total
            self.currentStep = step.partial
            
            self.task = step.total == step.partial ? "Completed!"
                                                   : status == .failure ? "Error!" : task
            self.details = details.isEmpty ? self.details : details.joined(separator: " - ")
            self.historical = self.lastTasks.map { "✓ \($0)"}.joined(separator: "\n")
            
            self.status  = status
            self.duration = step.estimatedDuration
            
            if !task.isEmpty { self.lastTasks.insert(task, at: 0) }
        }
    }
}
