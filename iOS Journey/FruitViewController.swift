//
//  FruitViewController.swift
//  iOS Journey
//
//  Created by MAC on 26/03/25.
//

import UIKit

class FruitViewController: UIViewController {
    
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Int, Fruit>!
    var fruits = [
        Fruit(name: "Apple"), Fruit(name: "Banana"), Fruit(name: "Cherry"),
        Fruit(name: "Apple"), Fruit(name: "Banana"), Fruit(name: "Cherry"),
        Fruit(name: "Apple"), Fruit(name: "Banana"), Fruit(name: "Cherry"),
        Fruit(name: "Apple"), Fruit(name: "Banana"), Fruit(name: "Cherry"),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        createHighScore()
        setupCollectionView()
        configureDataSource()
        applyInitialSnapshot()
    }
    
    func createHighScore(){
        var highScore = HighScore()
        highScore.value = 20
        highScore.finalize()
    }
    
    struct HighScore: ~Copyable{
        var value = 0
        
        consuming func finalize(){
            print("saving score to disk...")
            discard self
        }
        
        deinit {
            print("Deinit is saving score to disk")
        }
    }
    
    // Setup collection view layout
    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.frame.width - 40, height: 50)
        layout.minimumLineSpacing = 10
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        view.addSubview(collectionView)
    }
    
    func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, Fruit> { cell, indexPath, fruit in
            var content = UIListContentConfiguration.cell()
            content.text = fruit.name
            cell.contentConfiguration = content
            cell.backgroundColor = .systemGray5
            cell.layer.cornerRadius = 10
        }
        
        dataSource = UICollectionViewDiffableDataSource<Int, Fruit>(collectionView: collectionView) {
            (collectionView, indexPath, fruit) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: fruit)
        }
    }
    
    func applyInitialSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, Fruit>()
        snapshot.appendSections([0]) // Section 0
        snapshot.appendItems(fruits) // Add fruit data
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func addFruit() {
        let newFruit = Fruit(name: "Orange")
        fruits.append(newFruit)
        
        var snapshot = dataSource.snapshot()
        snapshot.appendItems([newFruit])
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    func removeFruit(at index: Int) {
        guard index < fruits.count else { return }
        let removedFruit = fruits.remove(at: index)
        
        var snapshot = dataSource.snapshot()
        snapshot.deleteItems([removedFruit])
        dataSource.apply(snapshot, animatingDifferences: true)
    }

}

struct Fruit: Hashable {
    let id = UUID()
    let name: String
}
