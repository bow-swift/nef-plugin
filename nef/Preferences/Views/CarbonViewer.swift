//  Copyright © 2019 The nef Authors.

import SwiftUI

struct CarbonViewer: NSViewRepresentable {
    @Binding var state: PreferencesModel
    
    func makeNSView(context: NSViewRepresentableContext<CarbonViewer>) -> CarbonWebView {
        return CarbonWebView(state: state)
    }
    
    func updateNSView(_ view: CarbonWebView, context: NSViewRepresentableContext<CarbonViewer>) {
        view.update(state: state)
    }
}
