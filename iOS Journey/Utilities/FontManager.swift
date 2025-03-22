//
//  FontManager.swift
//  iOS Journey
//
//  Created by Munish on  25/09/24.
//

import UIKit

enum FontFamily: String{
    
    case poppins = "Poppins"
    
    var fontNames: [FontStyle: String]{
        switch self {
        case .poppins:
            let fontDict = Dictionary(uniqueKeysWithValues: FontStyle.allCases.map{ ($0, "\(self.rawValue)-\($0.rawValue)")})
            return  fontDict
        }
    }
        
    enum FontStyle: String, CaseIterable{
        case bold = "Bold"
        case semiBold = "SemiBold"
        case medium = "Medium"
        case regular = "Regular"
        case light = "Light"
    }
}

extension UIFont{
    static func customFont(fontFamily: FontFamily = .poppins, style name: FontFamily.FontStyle, size: CGFloat) -> UIFont{
        guard let fontName = fontFamily.fontNames[name] else{
            return UIFont.systemFont(ofSize: 16)
        }
        return UIFont(name: fontName, size: size) ?? UIFont.systemFont(ofSize: size)
    }
}
