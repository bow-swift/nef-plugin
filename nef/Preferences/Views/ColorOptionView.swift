//  Copyright © 2019 The nef Authors.

import SwiftUI
import NefModels

struct ColorOptionView: View {
    let changed: (CarbonStyle.Color?) -> Void
    @Binding var value: String
    
    @State private var circleColor: Color = .gray
    
    var body: some View {
        HStack {
            Text("").frame(width: PreferencesView.Layout.leftPanel)
            
            HStack(spacing: 2) {
                Text("└ Hex.  #")
                TextField("", text: $value, onCommit: textFieldChangedValue).frame(width: 80)
                Circle().foregroundColor(CarbonStyle.Color(hex: value)?.color ?? .gray)
                        .offset(x: 12)
                        .frame(width: 22, height: 22)
                
                Spacer()
            }.frame(width: PreferencesView.Layout.rightPanel, alignment: .trailing)
        }
    }
    
    private func textFieldChangedValue() {
        let carbonColor = CarbonStyle.Color(hex: value)
        value = value.uppercased()
        changed(carbonColor)
    }
}
