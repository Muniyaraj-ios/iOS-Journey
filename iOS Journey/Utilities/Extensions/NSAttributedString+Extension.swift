//
//  NSAttributedString+Extension.swift
//  iOS Journey
//
//  Created by MacBook on 28/09/24.
//

import UIKit

extension NSAttributedString{
    static func styledString(text: String,style: UIFont,color: UIColor,underline: NSUnderlineStyle = [],paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle())-> NSAttributedString{
        let attributes_: [NSAttributedString.Key: Any] = [
            .font : style,
            .foregroundColor: color,
            .underlineStyle: underline.rawValue,
            .paragraphStyle: paragraphStyle
        ]
        return NSAttributedString(string: text, attributes: attributes_)
    }
    static func createAttributes(font: UIFont, color: UIColor, lineSpacing: CGFloat,alignment: NSTextAlignment = .justified)-> [NSAttributedString.Key: Any]{
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.alignment = alignment
        return [
            .font: font,
            .foregroundColor: color,
            .paragraphStyle: paragraphStyle
        ]
    }
}


extension NSAttributedString{
    static func createdAttributedStringWithImage(imageName: String, imageColor: UIColor = .label, imageSize: CGSize = CGSize(width: 24, height: 24), imageYOffset: CGFloat = -5, text: String, font: UIFont = .customFont(style: .medium, size: 16), textColor: UIColor, imagePosition: ImagePosititon = .before)-> NSAttributedString{
        
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(named: imageName)?.withTintColor(imageColor, renderingMode: .alwaysTemplate)
        
        imageAttachment.bounds = CGRect(x: 0, y: imageYOffset, width: imageSize.width, height: imageSize.height)
        
        let imageString = NSAttributedString(attachment: imageAttachment)
        
        let combineText = imagePosition == .after ? text + " " : "" + text
        let textString = NSAttributedString.styledString(text: combineText, style: font, color: textColor)
        let subText = "  "
        let _/*emptyString*/ = NSAttributedString.styledString(text: subText, style: font, color: textColor)
        
        let fullString = NSMutableAttributedString()
        
        switch imagePosition {
        case .before:
            fullString.append(imageString)
            fullString.append(textString)
        case .after:
            fullString.append(textString)
            fullString.append(imageString)
//            fullString.append(emptyString)
        }
        
        return fullString
    }
    enum ImagePosititon: Int{
        case before = 0
        case after = 1
    }
}
