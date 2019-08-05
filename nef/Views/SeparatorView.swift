//  Copyright © 2019 The nef Authors.

import SwiftUI

struct SeparatorView: View {
    let height: CGFloat
    let color: Color
    
    var body: some View {
        VStack { Spacer() }
            .frame(width: 1, height: height)
            .background(color.edgesIgnoringSafeArea(.all))
    }
}
