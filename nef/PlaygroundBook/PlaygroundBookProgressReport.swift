//  Copyright © 2019 The nef Authors.

import SwiftUI
import Bow
import BowEffects
import nef

class PlaygroundBookProgressReport: ProgressReport, ObservableObject {
    @Published var totalSteps: UInt  = 1
    @Published var currentStep: UInt = 1
    @Published var details: String = ""
    @Published var historical: String = ""
    @Published var status: nef.ProgressEventStatus = .successful
    
    private var progressDescription: [String] = []
    
    func notify<E: Swift.Error, A: CustomProgressDescription>(_ event: ProgressEvent<A>) -> IO<E, Void> {
        updateUI(event)
        progressDescription = progressDescription.combine([event.step.progressDescription])
        return .pure(())^
    }
    
    private func updateUI<A: CustomProgressDescription>(_ event: ProgressEvent<A>) {
        DispatchQueue.main.async {
            self.totalSteps = event.step.totalSteps
            self.currentStep = event.step.currentStep
            self.details = event.step.progressDescription
            self.historical = self.progressDescription.map { "✓ \($0)"}.joined(separator: "\n")
            self.status = event.status
        }
    }
}
