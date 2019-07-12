//  Copyright © 2019 The nef Authors.

import SwiftUI

struct PickerOptionView: View {
    let title: String
    let items: [OptionItem]
    
    @Binding var selection: Int
    
    var body: some View {
        HStack {
            Text("\(title):")
                .frame(width: 50, alignment: .trailing)
            Picker(selection: $selection, label: Text(title)) { self.texts(from: self.items) }
                .frame(width: 200)
        }
    }
    
    private func texts(from items: [OptionItem]) -> some View {
        ForEach(items) { item in
            Text(item.name).tag(item.id)
        }
    }
}
