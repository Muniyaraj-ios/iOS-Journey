//
//  UIViewController+Extension.swift
//  iOS Journey
//
//  Created by MacBook on 25/09/24.
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
