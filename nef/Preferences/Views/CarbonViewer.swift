//  Copyright © 2019 The nef Authors.

import SwiftUI
import nef

struct CarbonViewer: NSViewRepresentable {
    @Binding var state: PreferencesModel
    
    func makeNSView(context: NSViewRepresentableContext<CarbonViewer>) -> NSView {
        let loadingView = LoadingView()
        let carbonView = nef.Render.build.carbonView(code: Constants.code, state: state.carbonStyle)
        carbonView.loadingView = loadingView
        
        carbonView.addSubview(loadingView)
        loadingView.align(toView: carbonView)
        
        return carbonView
    }
    
    func updateNSView(_ view: NSView, context: NSViewRepresentableContext<CarbonViewer>) {
        guard let carbonView = view as? CarbonView else { return }
        carbonView.update(state: state.carbonStyle)
    }
    
    // MARK: - Constants
    enum Constants {
        static let code =
        """
        import Bow
        
        func optionCount(_ option: Option<String>) -> Int {
            return option.fold(
                { 0 },
                { str in str.count })
        }
        
        optionCount(.some("Hello!")) // returns 6
        optionCount(.none())         // returns 0
        """
    }
}
