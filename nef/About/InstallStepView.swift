//  Copyright © 2019 The nef Authors.

import SwiftUI

struct InstallStepView: View {
    private let image: Image
    private let opacity: CGFloat
    private let description: String
    
    init(image: Image, opacity: CGFloat, description: String) {
        self.image = image
        self.opacity = opacity
        self.description = description
    }
    
    var body: some View {
        Group {
            VStack(spacing: 4) {
                image.opacity(0.85)
                Text(description)
            }
            
            SeparatorView(height: 30, color: .purple)
        }
    }
}
