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
            ProgressView(total: $console.totalSteps, partial: $console.currentStep, duration: $console.duration, status: $console.status)
                .frame(maxWidth: .infinity)
            
            Text(console.details)
                .font(.footnote).fontWeight(.ultraLight)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(2)
                .offset(y: -8)
            
            HStack {
                NefImage.nef
                    .resizable()
                    .frame(width: 64, height: 64)
                    .aspectRatio(contentMode: .fit)
                Text(console.historical)
                    .font(.caption).fontWeight(.light)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(3)
                    .offset(x: 16)
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


// MARK: - previews
#if DEBUG
import nef
import BowEffects

struct PlaygroundBookView_Previews: PreviewProvider {
    static let console = PlaygroundBookConsole()
    
    static var previews: some View {
        console.historical = "✓ It is a preview 1\n✓ It is a preview 2"
        console.task    = "Preview"
        console.details = "Preview details"
        console.totalSteps  = 5
        console.currentStep = 2
        console.duration = .seconds(15)
        console.status   = .running
        
        return PlaygroundBookView(console: console).frame(width: 800, height: 200, alignment: .center)
    }
}
#endif
