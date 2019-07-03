//  Copyright © 2019 The nef Authors.

import Foundation

import AppNef
import Markup

func exportSnippet(code: String) {
    let style = CarbonStyle(background: .bow,
                            theme: .dracula,
                            size: .x2,
                            fontType: .firaCode,
                            lineNumbers: true,
                            watermark: true)
    
    DispatchQueue.main.async {
        carbon(code: code, style: style, outputPath: "/Users/miguelangel/Desktop/output")
    }

}
