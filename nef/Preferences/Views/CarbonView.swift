//  Copyright © 2019 The nef Authors.

import SwiftUI

struct CarbonView: NSViewRepresentable {
    @Binding var state: PreferencesModel
    
    func makeNSView(context: NSViewRepresentableContext<CarbonView>) -> CarbonWebView {
        return CarbonWebView(state: state)
    }
    
    func updateNSView(_ view: CarbonWebView, context: NSViewRepresentableContext<CarbonView>) {
        view.update(state: state)
    }
}
