//
//  HomeController.swift
//  iOS Journey
//
//  Created by MacBook on 25/09/24.
//

import UIKit

final class HomeController: BaseController {
    
    lazy var collectionView: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collection.showsVerticalScrollIndicator = false
        collection.isPagingEnabled = true
        return collection
    }()
    
    init(){
        super.init(nibName: nil, bundle: nil)
        view.addSubview(collectionView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDelegate()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.makeEdgeConstraints(toView: view, isSafeArea: true)
    }
    private func setupDelegate(){
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.reloadData()
    }
    private func createLayout()-> UICollectionViewCompositionalLayout{
        let item = CompositionalLayout.createItem(width: .fractionalWidth(1), height: .fractionalHeight(1))
        let group = CompositionalLayout.createGroup(alignment: .vertical, width: .fractionalWidth(1), height: .fractionalHeight(1), items: [item])
        let section = NSCollectionLayoutSection(group: group)
        return UICollectionViewCompositionalLayout(section: section)
    }
}

extension HomeController: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .random
        return cell
    }
}
