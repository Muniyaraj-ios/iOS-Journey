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

class LoadingButton: BaseButton {
    
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    @IBInspectable var buttonEnabled: Bool = false{
        didSet{
            if oldValue != buttonEnabled{ buttonEnabled ? EnableButton() : disbleButton() }
        }
    }
    @IBInspectable var titleFont: UIFont = .customFont(style: .semiBold, size: 16){
        didSet{ titleLabel?.font = titleFont }
    }
    @IBInspectable var enableTitle_Text: String = ""{
        didSet{ setTitle(enableTitle_Text, for: .normal) }
    }
    @IBInspectable var disbleTitle_Text: String = ""{
        didSet{ setTitle(disbleTitle_Text, for: .disabled) }
    }
    
    private func disbleButton(){
        isEnabled = false
        backgroundColor = UIColor.disableButtonColor
    }
    private func EnableButton(){
        isEnabled = true
        backgroundColor = UIColor.PrimaryColor
    }
    
    override func initalizeUI() {
        super.initalizeUI()
        setupButton()
    }
    
    private func setupButton() {
        setTitle(enableTitle_Text, for: .normal)
        setTitle(disbleTitle_Text, for: .disabled)
        setTitleColor(.disableTextColor, for: .disabled)
        setTitleColor(.ButtonTextColor, for: .normal)
        titleLabel?.font = titleFont
        buttonEnabled ? EnableButton() : disbleButton()
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .disableTextColor
        
        addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
            activityIndicator.leadingAnchor.constraint(equalTo: titleLabel!.trailingAnchor, constant: 8)
        ])
        
        addTarget(self, action: #selector(buttonPressed), for: [.touchDown,.touchDragInside,.touchDragOutside])
        addTarget(self, action: #selector(buttonReleased), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }
    
    // Function to handle button tap
    @objc private func buttonPressed() {
        backgroundColor = .surfaceButtonColor
        layer.borderWidth = 4
        layer.borderColor = UIColor.focus_borderColor.cgColor
    }
    
    @objc private func buttonReleased() {
        backgroundColor = .PrimaryColor
        layer.borderWidth = 0
        layer.borderColor = UIColor.clear.cgColor
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height / 2
    }
    
    // Function to handle button tap
    func startLoading() {
        buttonEnabled = false
        activityIndicator.startAnimating()
    }
    
    func stopLoading() {
        buttonEnabled = true
        activityIndicator.stopAnimating()
    }
}
