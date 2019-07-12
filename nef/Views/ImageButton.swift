//  Copyright © 2019 The nef Authors.

import SwiftUI

struct ImageButton: View {
    let image: Image
    let color: Color
    let action: () -> Void
    
    @State private var imageColor: Color = .clear
    
    init(image: Image, color: Color, action: @escaping () -> Void) {
        self.image = image
        self.color = color
        self.action = action
    }
    
    var body: some View {
        image.resizable()
            .foregroundColor(imageColor)
            .tapAction {
                self.action()
                self.imageColor = self.color
            }
            .onHover { hover in
                self.imageColor = hover ? self.color.opacity(0.5) : self.color
            }
            .onAppear {
                self.imageColor = self.color
            }
    }
}
