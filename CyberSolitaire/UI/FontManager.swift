//
//  FontManager.swift
//  CyberSolitaire
//
//  Created by 윤범태 on 6/2/25.
//

import Foundation
import CoreGraphics
import CoreText

public struct FontManager {
  /// https://stackoverflow.com/questions/71916171/how-to-change-font-in-xcode-swift-playgrounds-swiftpm-project
  public static func registerFonts() {
    registerFont(bundle: Bundle.main, fontName: "7 Segment", fontExtension: ".ttf") //change according to your ext.
  }
  
  fileprivate static func registerFont(bundle: Bundle, fontName: String, fontExtension: String) {
    print(Bundle.main)
    guard let fontURL = bundle.url(forResource: fontName, withExtension: fontExtension),
          let fontDataProvider = CGDataProvider(url: fontURL as CFURL),
          let font = CGFont(fontDataProvider) else {
      fatalError("Couldn't create font from data")
    }
    
    var error: Unmanaged<CFError>?
    
    CTFontManagerRegisterGraphicsFont(font, &error)
  }
}
