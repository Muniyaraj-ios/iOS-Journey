//
//  UILabel+Extension.swift
//  iOS Journey
//
//  Created by MacBook on 28/09/24.
//

import UIKit

extension UILabel{
    convenience init(text: String,textColor: UIColor,font: UIFont,alignment: NSTextAlignment = .left,line: Int = 1) {
        self.init(frame: .zero)
        self.text = text
        self.textColor = textColor
        self.font = font
        self.textAlignment = alignment
        self.numberOfLines = line
    }
}
