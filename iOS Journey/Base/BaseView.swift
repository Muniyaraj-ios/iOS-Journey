//
//  BaseView.swift
//  iOS Journey
//
//  Created by Munish on  25/09/24.
//

import UIKit

class BaseView: UIView{
    override init(frame: CGRect) {
        super.init(frame: frame)
        initalizeUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initalizeUI()
    }
    func initalizeUI(){}
}

class BaseButton: UIButton{
    override init(frame: CGRect) {
        super.init(frame: frame)
        initalizeUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initalizeUI()
    }
    func initalizeUI(){}
}

class BaseLabel: UILabel{
    override init(frame: CGRect) {
        super.init(frame: frame)
        initalizeUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initalizeUI()
    }
    func initalizeUI(){}
}

class BaseImageView: UIImageView{
    override init(frame: CGRect) {
        super.init(frame: frame)
        initalizeUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initalizeUI()
    }
    func initalizeUI(){}
}
