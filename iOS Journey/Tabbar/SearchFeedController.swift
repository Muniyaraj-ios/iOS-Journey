//
//  SearchFeedController.swift
//  iOS Journey
//
//  Created by MacBook on 25/09/24.
//

import UIKit

final class SearchFeedController: BaseController {
    
    lazy var collectionView: UICollectionView = {
        let collection = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collection.showsVerticalScrollIndicator = false
        return collection
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupDelegate()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    private func setupView(){
        view.addSubview(collectionView)
    }
    private func setupDelegate(){
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.reloadData()
    }
    private func createLayout()-> UICollectionViewCompositionalLayout{
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

extension SearchFeedController: UICollectionViewDataSource, UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .random
        return cell
    }
    
}
