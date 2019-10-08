//  Copyright © 2019 The nef Authors.

import AppKit

class LoadingView: NSView {
    private let activity = NSProgressIndicator(frame: NSRect(x: 0, y: 0, width: Layout.activitySize, height: Layout.activitySize))
    
    init() {
        super.init(frame: .zero)
        insertActivityIndicator()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show() {
        self.layer?.backgroundColor = LoadingView.Color.background.cgColor
        activity.startAnimation(nil)
    }
    
    func hide() {
        self.activity.stopAnimation(nil)
        self.layer?.backgroundColor = LoadingView.Color.clear.cgColor
    }
    
    override func layout() {
        super.layout()
        
        let width_2 = frame.width * 0.5
        let height_2 = frame.height * 0.5
        activity.setFrameOrigin(NSPoint(x: width_2 - Layout.activitySize_2,
                                        y: height_2 - Layout.activitySize_2))
    }
    
    private func insertActivityIndicator() {
        activity.style = .spinning
        activity.controlSize = .regular
        activity.controlTint = .graphiteControlTint
        activity.isIndeterminate = true
        activity.isDisplayedWhenStopped = false
        
        addSubview(activity)
    }
    
    // MARK: - Constants
    enum Layout {
        static let activitySize: CGFloat = 25
        static let activitySize_2: CGFloat = activitySize * 0.5
    }
    
    enum Color {
        static let background = NSColor(named: "background-color")!
        static let clear = NSColor.clear
    }
}
