//
//  CustomStackView.swift
//  iOS Journey
//
//  Created by MacBook on 28/09/24.
//

import UIKit

class HorizontalStack: UIStackView{
    
    init(arrangedSubViews: [UIView], spacing: CGFloat = 0, alignmnent: UIStackView.Alignment, distribution: UIStackView.Distribution){
        super.init(frame: .zero)
        arrangedSubViews.forEach{ addArrangedSubview($0) }
        self.spacing = spacing
        self.distribution = distribution
        self.alignment = alignmnent
        
        self.axis = .horizontal
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class VerticalStack: UIStackView{
    
    init(arrangedSubViews: [UIView], spacing: CGFloat, alignment: UIStackView.Alignment, distribution: UIStackView.Distribution){
        super.init(frame: .zero)
        arrangedSubViews.forEach{ addArrangedSubview($0) }
        self.spacing = spacing
        self.distribution = distribution
        self.alignment = alignment
        
        self.axis = .vertical
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
