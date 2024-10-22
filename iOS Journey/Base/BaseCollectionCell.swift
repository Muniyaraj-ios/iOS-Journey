//
//  BaseCollectionCell.swift
//  iOS Journey
//
//  Created by MacBook on 25/09/24.
//

import UIKit

class BaseCollectionCell: UICollectionViewCell, StoryboardCell{
    override init(frame: CGRect) {
        super.init(frame: frame)
        initalizeUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initalizeUI()
    }
    func initalizeUI(){
        isUserInteractionEnabled = true
    }
}

protocol StoryboardCell{
    static var resuseIdentifier: String { get }
    static var nib: UINib { get }
}
extension StoryboardCell{
    static var resuseIdentifier: String { String(describing: self) }
    static var nib: UINib { UINib(nibName: resuseIdentifier, bundle: nil) }
}
