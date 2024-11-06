//
//  TextView+UIKit.swift
//  iOS Journey
//
//  Created by MacBook on 06/11/24.
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
        label.textColor = .systemPink
        label.font = .customFont(fontFamily: .poppins, style: .medium, size: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func awakeFromNib() {
        super.awakeFromNib()

        addSubview(placeholderLabel)

        NSLayoutConstraint.activate([
            placeholderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            placeholderLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            placeholderLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5)
        ])

        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange), name: UITextView.textDidChangeNotification, object: nil)
    }

    @objc func textDidChange() {
        placeholderLabel.isHidden = !text.isEmpty
    }

}
