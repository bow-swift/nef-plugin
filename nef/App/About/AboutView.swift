//  Copyright © 2019 The nef Authors.

import SwiftUI
import SourceEditorUtils

struct AboutView: View {
    private let version: String
    
    init(version: String) {
        self.version = version
    }
    
    @State var option: Bool = true
    
    var body: some View {
        VStack(spacing: 16) {
            nefView
            SeparatorView(height: 16, color: NefColor.separator)
            
            InstallStepView(image: NefImage.preferences, opacity: 0.85, description: i18n.installPreferences)
                .onTapGesture(perform: openPreferences)
            InstallStepView(image: NefImage.extensions, opacity: 0.9, description: i18n.installExtensions)
                .onTapGesture(perform: openPreferences)
            FixedToggle(title: "nef", description: i18n.nefExtension, isOn: true)
            
            Spacer()
            
            githubView.padding(8)
            Text(i18n.copyright)
                .foregroundColor(.init(white: 0.7))
            
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
         .padding(16)
    }
    
    // MARK: internal subviews
    private var nefView: some View {
        HStack(spacing: 6) {
            NefImage.logo
                .resizable().frame(width: 50, height: 50)
                .foregroundColor(.init(white: 0.4))
            nefVersionView
        }
    }
    
    private var nefVersionView: some View {
        VStack {
            Text("nef")
                .font(.system(size: 30)).fontWeight(.bold)
            Text("\(version)")
                .font(.system(size: 10))
                .foregroundColor(.gray)
        }
    }
    
    private var githubView: some View {
        Text(i18n.github)
            .foregroundColor(.blue)
            .onTapGesture(perform: openGithub)
    }
    
    // MARK: actions
    private func openPreferences() {
        Browser.open(url: "x-apple.systempreferences:com.apple.preferences")
    }
    
    private func openGithub() {
        Browser.open(url: Constants.githubURL)
    }
    
    // MARK: Constants
    enum NefImage {
        static let logo = Image("nef-favicon")
        static let preferences = Image("system-preferences")
        static let extensions = Image("system-extensions")
    }
    
    enum NefColor {
        static let separator = Color("panel-border-color")
    }
    
    enum Constants {
        static let githubURL = "https://github.com/bow-swift/nef#features"
    }
    
    enum i18n {
        static let copyright = NSLocalizedString("copyright", comment: "")
        static let github = NSLocalizedString("github", comment: "")
        static let installPreferences = NSLocalizedString("install_preferences", comment: "")
        static let installExtensions = NSLocalizedString("install_extensions", comment: "")
        static let nefExtension = NSLocalizedString("nef_extension", comment: "")
    }
}
