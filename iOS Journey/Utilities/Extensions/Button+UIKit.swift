//
//  Button+UIKit.swift
//  iOS Journey
//
//  Created by Munish on  30/09/24.
//

import UIKit

class CustomButton: BaseButton{
    
    lazy var imageViewButton: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "heart")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        imageView.isUserInteractionEnabled = false
        return imageView
    }()
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "13.9K"
        label.textColor = .white
        label.isUserInteractionEnabled = false
        return label
    }()
    
    var stack = UIStackView()
    
    let type: CustomContentType
    
    init(type: CustomContentType) {
        self.type = type
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    override func initalizeUI() {
//        super.initalizeUI()
//        setupUI()
//    }
    
    private func setupUI(){
        stack = VerticalStack(arrangedSubViews: [imageViewButton, label], spacing: 20, alignment: .center, distribution: .fill)
        stack.isBaselineRelativeArrangement = true
        stack.layoutMargins = .init(top: 8, left: 8, bottom: 8, right: 8)
        addSubview(stack)
        stack.makeEdgeConstraints(toView: self)
        imageViewButton.sizeConstraints(width: 30, height: 30)
        stack.isUserInteractionEnabled = false
        label.font = .customFont(style: .regular, size: 14)
        
        imageViewButton.image = UIImage(named: type.iconName)
        label.isHidden = type == .more
    }
    
    enum CustomContentType{
        case like
        case comment
        case share
        case more
        
        case flipcamera
        
        var iconName: String{
            switch self {
            case .like: return "heart"
            case .comment: return "chat"
            case .share: return "favourite"
            case .more: return "more"
            case .flipcamera: return "flip_camera_icon"
            }
        }
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


extension UIView{
    
    func borderLayer(circle: Bool, radius corner: CGFloat = 8, borderColor color: UIColor, borderWidth width: CGFloat){
        layer.borderColor = color.cgColor
        layer.borderWidth = width
        layer.cornerRadius = circle ? (frame.height / 2) : corner
    }
}
