//  Copyright © 2019 The nef Authors.

import SwiftUI
import AppKit

struct ProgressView: NSViewRepresentable {
    @Binding var total: UInt
    @Binding var partial: UInt
    @Binding var duration: DispatchTimeInterval
    
    func makeNSView(context: NSViewRepresentableContext<ProgressView>) -> NSProgressIndicator {
        let view = NSProgressIndicator()
        view.maxValue = Double(total)
        view.minValue = 0
        view.doubleValue = 0.1
        view.isIndeterminate = false
        return view
    }
    
    func updateNSView(_ view: NSProgressIndicator, context: NSViewRepresentableContext<ProgressView>) {
        let maxValue = Double(total)
        let minValue = Double(0)
        let partial = Double(self.partial)
        let completed = partial == maxValue
        
        guard view.doubleValue < partial else { return }
        
        view.maxValue = maxValue
        view.minValue = minValue
        
        if !completed {
            view.doubleValue = max(partial - 1, 0)
            animate(progress: view, value: partial, duration: duration.double ?? 1)
        } else {
            view.doubleValue = partial
        }
    }
    
    private func animate(progress: NSProgressIndicator, value: Double, duration: Double) {
        NSAnimationContext.runAnimationGroup { context in
            context.duration = duration
            progress.animator().setValue(value, forKey: "doubleValue")
        }
    }
}
