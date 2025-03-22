//
//  UIImageView+Extension.swift
//  iOS Journey
//
//  Created by Munish on  28/09/24.
//

import UIKit

extension UIImageView{
    convenience init(cornerRadius: CGFloat,mode: UIView.ContentMode = .scaleAspectFit) {
        self.init(image: nil)
        self.layer.cornerRadius = cornerRadius
        self.contentMode = mode
        self.clipsToBounds = true
    }
}
