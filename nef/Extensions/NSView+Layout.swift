//  Copyright © 2019 The nef Authors.

import AppKit

extension NSView {
    func align(toView view: NSView, leading: CGFloat = 0, trailing: CGFloat = 0) {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: view.topAnchor),
            self.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: leading),
            self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: trailing)
        ])
    }
}
