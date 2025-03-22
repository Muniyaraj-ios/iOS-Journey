//
//  BaseTableViewCell.swift
//  iOS Journey
//
//  Created by Munish on  25/09/24.
//

import UIKit

class BaseTableViewCell: UITableViewCell, StoryboardCell{
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initalizeUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initalizeUI()
    }
    func initalizeUI(){}
}
