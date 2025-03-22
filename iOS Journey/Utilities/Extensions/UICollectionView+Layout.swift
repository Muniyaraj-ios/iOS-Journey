//
//  UICollectionView+Layout.swift
//  iOS Journey
//
//  Created by Munish on  25/09/24.
//

import UIKit

struct CompositionalLayout{
    
    static func createItem(width: NSCollectionLayoutDimension, height: NSCollectionLayoutDimension, space: UIEdgeInsets = .zero)-> NSCollectionLayoutItem{
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: width, heightDimension: height))
        item.contentInsets = NSDirectionalEdgeInsets(top: space.top, leading: space.left, bottom: space.bottom, trailing: space.right)
        return item
    }
    static func createGroup(alignment: CompositionalGroupAlignment, width: NSCollectionLayoutDimension, height: NSCollectionLayoutDimension, items: [NSCollectionLayoutItem])-> NSCollectionLayoutGroup{
        let layoutSize = NSCollectionLayoutSize(widthDimension: width, heightDimension: height)
        switch alignment {
        case .vertical:
            return NSCollectionLayoutGroup.vertical(layoutSize: layoutSize, subitems: items)
        case .horizontal:
            return NSCollectionLayoutGroup.horizontal(layoutSize: layoutSize, subitems: items)
        }
    }
    static func createGroup(alignment: CompositionalGroupAlignment, width: NSCollectionLayoutDimension, height: NSCollectionLayoutDimension, item: NSCollectionLayoutItem, count: Int)-> NSCollectionLayoutGroup{
        let layoutSize = NSCollectionLayoutSize(widthDimension: width, heightDimension: height)
        switch alignment {
        case .vertical:
            if #available(iOS 16.0, *) {
                return NSCollectionLayoutGroup.vertical(layoutSize: layoutSize, repeatingSubitem: item, count: count)
            } else {
                return NSCollectionLayoutGroup.vertical(layoutSize: layoutSize, subitem: item, count: count)
            }
        case .horizontal:
            if #available(iOS 16.0, *) {
                return NSCollectionLayoutGroup.horizontal(layoutSize: layoutSize, repeatingSubitem: item, count: count)
            } else {
                return NSCollectionLayoutGroup.horizontal(layoutSize: layoutSize, subitem: item, count: count)
            }
        }
    }
}

extension CompositionalLayout{
    
    static func FeedLayout()-> UICollectionViewCompositionalLayout{
        let item = CompositionalLayout.createItem(width: .fractionalWidth(1), height: .fractionalHeight(1))
        let group = CompositionalLayout.createGroup(alignment: .vertical, width: .fractionalWidth(1), height: .fractionalHeight(1), items: [item])
        let section = NSCollectionLayoutSection(group: group)
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    static func instagramLayout()-> UICollectionViewCompositionalLayout{
        let edge = UIEdgeInsets(top: 0.5, left: 0.5, bottom: 0.5, right: 0.5)
        
        let item = CompositionalLayout.createItem(width: .fractionalWidth(1/3), height: .fractionalHeight(1), space: edge)
        
        let fullItem = CompositionalLayout.createItem(width: .fractionalWidth(1), height: .fractionalHeight(1), space: edge)
                
        var height: NSCollectionLayoutDimension
        
        if #available(iOS 16.0, *){
            height = .fractionalHeight(0.5)
        }else{
            height = .fractionalHeight(1)
        }
        let verticalGroup = CompositionalLayout.createGroup(alignment: .vertical, width: .fractionalWidth(1/3), height: height/*.fractionalHeight(1/2)*/, item: fullItem, count: 2)
                
        let horizontalGroup = CompositionalLayout.createGroup(alignment: .horizontal, width: .fractionalWidth(1), height: .fractionalHeight(0.5), items: [item, verticalGroup, verticalGroup])
        
        let horizontalGroup_sub = CompositionalLayout.createGroup(alignment: .horizontal, width: .fractionalWidth(1), height: .fractionalHeight(0.5), items: [verticalGroup, verticalGroup, item])
        
        let mainGroup = CompositionalLayout.createGroup(alignment: .vertical, width: .fractionalWidth(1), height: .fractionalHeight(0.7), items: [horizontalGroup, horizontalGroup_sub])
        
        let section = NSCollectionLayoutSection(group: mainGroup)
        return UICollectionViewCompositionalLayout(section: section)
    }
}

enum CompositionalGroupAlignment{
    case vertical
    case horizontal
}
