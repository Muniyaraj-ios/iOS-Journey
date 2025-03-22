//
//  TextView+UIKit.swift
//  iOS Journey
//
//  Created by Munish on  06/11/24.
//

import UIKit

class PlaceholderTextView: UITextView {

    @IBInspectable var placeholder: String? {
        didSet {
            placeholderLabel.text = placeholder
        }
    }

    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.font = .customFont(fontFamily: .poppins, style: .regular, size: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        addSubview(placeholderLabel)

        NSLayoutConstraint.activate([
            placeholderLabel.topAnchor.constraint(equalTo: topAnchor, constant: 7),
            placeholderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            placeholderLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5)
        ])
        placeholderLabel.text = placeholder

        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange), name: UITextView.textDidChangeNotification, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UITextView.textDidChangeNotification, object: nil)
    }

    @objc func textDidChange() {
        placeholderLabel.isHidden = !text.isEmpty
    }

}
