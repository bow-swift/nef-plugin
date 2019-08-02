//  Copyright © 2019 The nef Authors.

import SwiftUI

struct CheckOptionView: View {
    let text: String
    let nested: Bool
    
    @Binding var selection: Bool
    
    var body: some View {
        HStack {
            Text(nested ? "" : "\(i18n.title):")
                .frame(width: PreferencesView.Layout.leftPanel, alignment: .trailing)
            
            Toggle(isOn: $selection) { Text(text) }
                .frame(width: PreferencesView.Layout.rightPanel, alignment: .leading)
        }
    }
    
    // MARK: - Constants
    enum i18n {
        static let title = NSLocalizedString("Show", comment: "")
    }
}
