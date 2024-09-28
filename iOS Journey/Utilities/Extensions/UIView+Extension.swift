//
//  UIView+Extension.swift
//  iOS Journey
//
//  Created by MacBook on 25/09/24.
//

import UIKit

extension UIView{
    func makeEdgeConstraints(toView parentView: UIView, edge const: UIEdgeInsets = .zero, isSafeArea: Bool = false){
        translatesAutoresizingMaskIntoConstraints = false
        topAnchor.constraint(equalTo: isSafeArea ? parentView.safeAreaLayoutGuide.topAnchor : parentView.topAnchor, constant: const.top).isActive = true
        leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: const.left).isActive = true
        trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: -const.right).isActive = true
        bottomAnchor.constraint(equalTo: isSafeArea ? parentView.safeAreaLayoutGuide.bottomAnchor : parentView.bottomAnchor, constant: -const.bottom).isActive = true
    }
    func makeEdgeConstraints(top: NSLayoutYAxisAnchor?, leading: NSLayoutXAxisAnchor?, trailing: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, width: CGFloat? = nil, height: CGFloat? = nil, edge const: UIEdgeInsets = .zero){
        translatesAutoresizingMaskIntoConstraints = false
        var anchor: AnchoredConstrints = AnchoredConstrints()
        if let top{
            anchor.top = topAnchor.constraint(equalTo: top, constant: const.top)
        }
        if let leading{
            anchor.leading = leadingAnchor.constraint(equalTo: leading, constant: const.left)
        }
        if let trailing{
            anchor.trailing = trailingAnchor.constraint(equalTo: trailing, constant: -const.right)
        }
        if let bottom{
            anchor.bottom = bottomAnchor.constraint(equalTo: bottom, constant: -const.bottom)
        }
        if let width{
            anchor.width = widthAnchor.constraint(equalToConstant: width)
        }
        if let height{
            anchor.height = heightAnchor.constraint(equalToConstant: height)
        }
        [anchor.top,anchor.leading,anchor.trailing,anchor.bottom,anchor.width,anchor.height].forEach{ $0?.isActive = true }
    }
    func sizeConstraints(width: CGFloat,height: CGFloat){
        widthAnchor.constraint(equalToConstant: width).isActive = true
        heightAnchor.constraint(equalToConstant: height).isActive = true
    }
    func widthConstraints(width: CGFloat){
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: width).isActive = true
    }
    func heightConstraints(height: CGFloat){
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: height).isActive = true
    }
    func makeCenterConstraints(toView: UIView,centerX: CGFloat = 0,centerY: CGFloat = 0,centerX_axis: Bool = true,centerY_axis: Bool = true){
        translatesAutoresizingMaskIntoConstraints = false
        if centerX_axis{
            centerXAnchor.constraint(equalTo: toView.centerXAnchor, constant: centerX).isActive = true
        }
        if centerY_axis{
            centerYAnchor.constraint(equalTo: toView.centerYAnchor, constant: centerY).isActive = true
        }
    }
    func cornerRadiusWithBorder(isRound: Bool = false,corner radius: CGFloat = 4,borderwidth const: CGFloat = 0.6,borderColor color: UIColor = .lightGray){
        layer.cornerRadius = isRound ? (frame.height / 2) : radius
        layer.borderWidth = const
        layer.borderColor = color.cgColor
        clipsToBounds = true
    }
    
    struct AnchoredConstrints{
        var top, leading, trailing, bottom, width, height: NSLayoutConstraint?
    }
}

extension UITabBar {
    func applyShadow(shadowColor: UIColor = .lightGray, shadowOffset: CGSize = CGSize(width: 0.0, height: 0.2), shadowRadius: CGFloat = 5, shadowOpacity: Float = 1, backgroundColor: UIColor = .white) {
        
        // Set background color and shadow image to make shadow visible
        clipsToBounds = true
        shadowImage = UIImage()
        backgroundImage = UIImage().withTintColor(backgroundColor)
        
        // Apply shadow properties
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOffset = shadowOffset
        layer.shadowRadius = shadowRadius
        layer.shadowOpacity = shadowOpacity
        layer.masksToBounds = false
    }
}


extension UIView{
    
    typealias tapActionClosure = (()-> Void)?
    
    func addTap(count: Int = 1,action: tapActionClosure){
        let tap = MyGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tap.numberOfTapsRequired = count
        addGestureRecognizer(tap)
        isUserInteractionEnabled = true
    }
    
    @objc func handleTap(_ sender: MyGestureRecognizer){
        sender.action?()
    }
    
    class MyGestureRecognizer: UITapGestureRecognizer{
        var action: tapActionClosure = nil
    }
}
