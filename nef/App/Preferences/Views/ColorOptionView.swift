//  Copyright © 2019 The nef Authors.

import SwiftUI
import nef

struct ColorOptionView: View {
    @Binding var value: String
    
    var body: some View {
        HStack {
            Text("").frame(width: PreferencesView.Layout.leftPanel)
            
            HStack(spacing: 2) {
                Text("└ Hex.  #")
                TextField("", text: $value, onEditingChanged: textFieldEditingChanged, onCommit: textFieldChangedValue).frame(width: 80)
                Circle().foregroundColor(CarbonStyle.Color(hex: value)?.color ?? .gray)
                        .offset(x: 12)
                        .frame(width: 22, height: 22)
                
                Spacer()
            }.frame(width: PreferencesView.Layout.rightPanel, alignment: .trailing)
        }
    }
    
    private func textFieldEditingChanged(_ editing: Bool) {
        guard !editing, value.count == 6 else { return }
        value = "\(value)FF".uppercased()
    }
    
    private func textFieldChangedValue() {
        value = value.uppercased()
    }
}
