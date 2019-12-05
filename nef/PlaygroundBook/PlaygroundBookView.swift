//  Copyright © 2019 The nef Authors.

import SwiftUI

struct PlaygroundBookView: View {
    @ObservedObject private var console: PlaygroundBookConsole
    
    init(console: PlaygroundBookConsole) {
        self.console = console
    }
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressView(total: $console.totalSteps, partial: $console.currentStep, duration: $console.duration)
                .frame(maxWidth: .infinity)
            
            Text("\(console.task)")
            Text("\(console.details.joined(separator: " - "))")
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
         .padding(16)
    }
}
