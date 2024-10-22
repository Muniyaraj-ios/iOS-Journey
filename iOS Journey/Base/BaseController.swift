//
//  BaseController.swift
//  iOS Journey
//
//  Created by MacBook on 25/09/24.
//

import UIKit

class BaseController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        //hideKeyboardWhenTapppedAround()
    }
    deinit {
        debugPrint("deinited \(String(describing: Self.self))")
    }
}
