//  Copyright © 2019 The nef Authors.

import SwiftUI

struct PlaygroundBookView: View {
    @ObservedObject private var console: PlaygroundBookConsole
    
    init(console: PlaygroundBookConsole) {
        self.console = console
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text("\(console.task)")
                .font(.body).fontWeight(.light)
            ProgressView(total: $console.totalSteps, partial: $console.currentStep, duration: $console.duration)
                .frame(maxWidth: .infinity)
            
            Text(console.details)
                .font(.footnote).fontWeight(.ultraLight)
                .offset(y: -8)
            
            HStack {
                NefImage.nef
                    .resizable()
                    .frame(width: 56, height: 56)
                    .aspectRatio(contentMode: .fit)
                Text(console.historical)
                    .font(.caption).fontWeight(.light)
                    .offset(x: 16)
                    .lineLimit(3)
                Spacer()
            }.padding(.init(top: -8, leading: 8, bottom: 8, trailing: 0))
            
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
         .padding(16)
    }
    
    // MARK: - Constants
    enum NefImage {
        static let spm = Image("spm")
        static let nef = Image("nef-favicon")
    }
}
