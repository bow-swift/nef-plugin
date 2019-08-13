//  Copyright © 2019 The nef Authors.

import SwiftUI

struct FixedToggle: View {
    private let title: String
    private let description: String
    private let isOn: Bool
    
    @ObservedObject private var state: InmutableState<Bool>
    
    init(title: String, description: String, isOn: Bool) {
        self.title = title
        self.description = description
        self.isOn = isOn
        self.state = InmutableState(state: isOn)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if !title.isEmpty { Text(title) }
            Toggle(description, isOn: $state.value)
        }
    }
}

private class InmutableState<T>: ObservableObject {
    var value: T
    init(state: T) {
        self.value = state
    }
}
