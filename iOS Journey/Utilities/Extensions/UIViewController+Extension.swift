//
//  UIViewController+Extension.swift
//  iOS Journey
//
//  Created by Munish on  25/09/24.
//

import UIKit

extension UIViewController{
    func hideKeyboardWhenTapppedAround(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = true
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
}

extension UIViewController{
    var appdelegate: AppDelegate{
        return UIApplication.shared.delegate as! AppDelegate
    }
    var sceneDelegate: SceneDelegate?{
        guard let window = UIApplication.shared.connectedScenes.first as? UIWindowScene, let delegate = window.delegate as? SceneDelegate else{
            return nil
        }
        return delegate
    }
    func pushToController(_ viewcontroller: UIViewController, animated: Bool = true){
        var navigationController: UINavigationController?
        if let navVC = self as? UINavigationController{
            navigationController = navVC
        }else{
            navigationController = self.navigationController
        }
        navigationController?.pushViewController(viewcontroller, animated: animated)
    }
    func presentToController(_ viewcontroller: UIViewController, animated: Bool = true, completion: (()-> Void)? = nil){
        var navigationController: UINavigationController?
        if let newVC = self as? UINavigationController{
            navigationController = newVC
        }else{
            navigationController = self.navigationController
        }
        navigationController?.present(viewcontroller, animated: animated, completion: completion)
    }
}

extension UIViewController{
    func setNavigationBarTitleAttributes(_ attributes: [NSAttributedString.Key: Any]){
        navigationController?.navigationBar.titleTextAttributes = attributes
    }
    func setNavigationBarTitleAttributes(font: UIFont = .customFont(style: .semiBold, size: 16), color: UIColor = .TextPrimaryColor, lineSpacing: CGFloat = 0){
        navigationController?.navigationBar.titleTextAttributes = NSAttributedString.createAttributes(font: font, color: color, lineSpacing: lineSpacing)
    }
}

extension UINavigationBar {

    func setColor(backgroundColor: UIColor, color: UIColor = .TextPrimaryColor, font: UIFont = .customFont(style: .semiBold, size: 16), lineSpacing: CGFloat = 0, prefersLargeTitles: Bool = false) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground() // or use configureWithTransparentBackground() for transparent
        appearance.backgroundColor = backgroundColor
        appearance.titleTextAttributes = NSAttributedString.createAttributes(font: font, color: color, lineSpacing: lineSpacing)
        //[.foregroundColor: titleColor]
        appearance.largeTitleTextAttributes = NSAttributedString.createAttributes(font: font, color: color, lineSpacing: lineSpacing)
        //[.foregroundColor: titleColor]

        // Apply the appearance to the navigation bar
        standardAppearance = appearance
        scrollEdgeAppearance = appearance
        compactAppearance = appearance
        self.prefersLargeTitles = prefersLargeTitles
        setNeedsLayout()
    }
    func setTitleAttributes(font: UIFont = .customFont(style: .semiBold, size: 16), color: UIColor = .TextPrimaryColor, lineSpacing: CGFloat = 0){
        titleTextAttributes = NSAttributedString.createAttributes(font: font, color: color, lineSpacing: lineSpacing)
    }
}
