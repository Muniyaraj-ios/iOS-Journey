//
//  Button+UIKit.swift
//  iOS Journey
//
//  Created by MacBook on 30/09/24.
//

import UIKit

class CustomButton: BaseButton{
    
    private let imageButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("", for: .normal)
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "13.9K"
        label.textColor = .white
        label.font = .customFont(style: .regular, size: 14)
        return label
    }()
    
    var stack = UIStackView()
    
    
    override func initalizeUI() {
        super.initalizeUI()
        setupUI()
    }
    
    private func setupUI(){
        stack = VerticalStack(arrangedSubViews: [imageButton, label], spacing: 20, alignment: .center, distribution: .fill)
        stack.isBaselineRelativeArrangement = true
        stack.layoutMargins = .init(top: 8, left: 8, bottom: 8, right: 8)
        addSubview(stack)
        stack.makeEdgeConstraints(toView: self)
        imageButton.sizeConstraints(width: 45, height: 45)
    }
}
