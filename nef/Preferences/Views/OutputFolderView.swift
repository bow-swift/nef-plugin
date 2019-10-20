//  Copyright © 2019 The nef Authors.

import SwiftUI

struct OutputFolderView: View {
    
    private let openPanel = OpenPanel()
    @State var outputPath: String = ""
    
    var body: some View {
        HStack(alignment: .top) {
            Text("\(i18n.title):")
                .frame(width: PreferencesView.Layout.leftPanel, alignment: .trailing)
            
            HStack(alignment: .bottom) {
                Text(outputPath)
                    .font(.system(.caption)).fontWeight(.light)
                    .lineLimit(1)
                    .ligthGray
                
                Text("➤")
                    .font(.system(.caption)).fontWeight(.light)
                    .regularGray
            }.frame(width: PreferencesView.Layout.rightPanel+Constant.rightPanelExtraWidth, alignment: .leading)
             .onTapGesture { self.selectWritableFolder() }
            
        }.offset(x: Constant.rightPanelExtraWidth/2)
         .onAppear(perform: onAppear)
    }
    
    private func onAppear() {
        outputPath = openPanel.writableFolder(create: false)?.path ?? ""
    }
    
    private func selectWritableFolder() {
        guard let url = openPanel.selectWritableFolder() else { return }
        outputPath = url.path
    }
    
    // MARK: - Constants
    enum i18n {
        static let title = NSLocalizedString("output_folder_title", comment: "")
    }
    
    enum Constant {
        static let rightPanelExtraWidth: CGFloat = 180
    }
}


fileprivate extension View {
    var ligthGray: some View { self.foregroundColor(.init(white: 0.7)) }
    var regularGray: some View { self.foregroundColor(.init(white: 0.6)) }
}
