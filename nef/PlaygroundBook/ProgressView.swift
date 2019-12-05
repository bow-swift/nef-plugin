//  Copyright © 2019 The nef Authors.

import SwiftUI
import AppKit

struct ProgressView: NSViewRepresentable {
    @Binding var total: UInt
    @Binding var partial: UInt
    @Binding var duration: DispatchTimeInterval
    @Binding var status: PlaygroundBookConsole.Status
    
    func makeNSView(context: NSViewRepresentableContext<ProgressView>) -> NSProgressIndicator {
        let view = NSProgressIndicator()
        view.maxValue = Double(total)
        view.minValue = 0
        view.doubleValue = 0.1
        view.isIndeterminate = false
        return view
    }
    
    func updateNSView(_ view: NSProgressIndicator, context: NSViewRepresentableContext<ProgressView>) {
        guard status != .failure else { showError(indicator: view); return }
        guard view.doubleValue < Double(self.partial) else { return }
        
        let maxValue = Double(self.total)
        let minValue = Double(0)
        let partial  = Double(self.partial)
        let completed = partial == maxValue
        
        view.maxValue = maxValue
        view.minValue = minValue
        
        if !completed {
            view.doubleValue = max(partial - 1, 0)
            animate(progress: view, value: partial, duration: duration.double ?? 1)
        } else {
            view.doubleValue = partial
        }
    }
    
    private func showError(indicator view: NSProgressIndicator) {
        view.layer?.filters = [CIFilter.monocrome(intensity: 0.75)]
        animate(progress: view, value: view.doubleValue, duration: 0)
    }
    
    private func animate(progress: NSProgressIndicator, value: Double, duration: Double) {
        NSAnimationContext.runAnimationGroup { context in
            context.duration = duration
            progress.animator().setValue(value, forKey: "doubleValue")
        }
    }
}


private extension CIFilter {
    static func monocrome(intensity: CGFloat) -> CIFilter {
        let filter = CIFilter(name: "CIColorMonochrome")!
        filter.setValue(CIColor.gray, forKey: "inputColor")
        filter.setValue(intensity, forKey: "inputIntensity")
        return filter
    }
}
