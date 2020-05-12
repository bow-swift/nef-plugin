//  Copyright © 2019 The nef Authors.

import SwiftUI

struct PlaygroundBookView: View {
    @ObservedObject private var progressReport: PlaygroundBookProgressReport
    
    init(progressReport: PlaygroundBookProgressReport) {
        self.progressReport = progressReport
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text(progressReport.details)
                .font(.body).fontWeight(.light)
            ProgressView(total: $progressReport.totalSteps, partial: $progressReport.currentStep, status: $progressReport.status)
                .frame(maxWidth: .infinity)
            
            Spacer()
            
            HStack {
                NefImage.nef
                    .resizable()
                    .frame(width: 64, height: 64)
                    .aspectRatio(contentMode: .fit)
                Text(progressReport.historical)
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
    static let progressReport = PlaygroundBookProgressReport()
    
    static var previews: some View {
        progressReport.historical = "✓ It is a preview 1\n✓ It is a preview 2"
        progressReport.details = "Preview details"
        progressReport.totalSteps = 5
        progressReport.currentStep = 2
        progressReport.status = .inProgress
        
        return PlaygroundBookView(progressReport: progressReport).frame(width: 800, height: 200, alignment: .center)
    }
}
#endif
