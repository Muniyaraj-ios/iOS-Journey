//
//  BaseTabbarController.swift
//  iOS Journey
//
//  Created by Munish on  25/09/24.
//

import UIKit

class BaseTabbarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    deinit {
        debugPrint("deinited \(String(describing: Self.self))")
    }
}
