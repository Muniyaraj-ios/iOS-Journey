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
        collection.register(ContentFeedCollectionCell.self, forCellWithReuseIdentifier: ContentFeedCollectionCell.resuseIdentifier)
        collection.showsVerticalScrollIndicator = false
        return collection
    }()
    
    private let feedViewModel: HomeFeedViewModel
    
    init(pageType: PageType) {
        self.feedViewModel = HomeFeedViewModel(pageType: .other)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupDelegate()
        setupNetworkCall()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        
//        guard let cell = collectionView.visibleCells as? [ContentFeedCollectionCell] else{ return }
//        cell.forEach{ $0.play() }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
//        guard let cell = collectionView.visibleCells as? [ContentFeedCollectionCell] else{ return }
//        cell.forEach{ $0.pause() }
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
    private func setupNetworkCall(){
        feedViewModel.fetchNewVideos()
        
        feedViewModel.$fetchVideos
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    debugPrint("Failed to fetch photos with error: \(error.localizedDescription)")
                case .finished:
                    debugPrint("Successfully fetched photos.")
                    break
                }
            } receiveValue: { [weak self] video_data in
                if let _ = video_data?.result{
                    debugPrint("Fetch new video reloaded")
                    self?.collectionView.reloadData()
                }else{
                    debugPrint("Fetch video with nil value")
                }
            }
            .store(in: &feedViewModel.cancelable)
    }
}

extension SearchFeedController: UICollectionViewDataSource, UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return feedViewModel.fetchVideos?.result?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ContentFeedCollectionCell.resuseIdentifier, for: indexPath) as? ContentFeedCollectionCell else{ return UICollectionViewCell() }
        let video_data = feedViewModel.fetchVideos?.result?[indexPath.item]
        //cell.setupConfigure(video_data)
        cell.hideTopPriorities()
        cell.videoData = video_data
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        
        guard let firstIndexPath = indexPaths.first else { return nil }
        let currentCellIndex = firstIndexPath.item
        
        return UIContextMenuConfiguration(identifier: nil) { [weak self] in
            self?.makePreview(index: currentCellIndex)
        } actionProvider: { _ in
            
            let likeAction = UIAction(title: "Like", image: UIImage(systemName: "heart")) { _ in
                
            }
            
            let shareProfileAction = UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up")) { _ in
                
            }
            
            let viewProfileAction = UIAction(title: "View Profile", image: UIImage(systemName: "person.circle")) { _ in
                
            }
            
            let reportAction = UIAction(title: "Report", image: UIImage(systemName: "person.fill.xmark"), attributes: .destructive) { _ in
                
            }
            
            let notInterestAction = UIAction(title: "Not interested", image: UIImage(systemName: "eye.slash")) { _ in
                
            }
            
            return UIMenu(children: [likeAction, shareProfileAction, viewProfileAction, reportAction, notInterestAction])
            
            /*let repositoriesAction = UIAction(title: "Respositories", image: UIImage(systemName: "filemenu.and.cursorarrow")) { _ in
                
            }
            
            let starAction = UIAction(title: "Starts", image: UIImage(systemName: "star")) { _ in
                
            }
            
            let achivementAction = UIAction(title: "Achievements", image: UIImage(systemName: "trophy")) { _ in
                
            }
                        
            let unfollowAction = UIAction(title: "Unfollow", image: UIImage(systemName: "xmark.bin.fill"), attributes: .destructive) { _ in
                
            }
            
            let shareAction = UIAction(title: "Share Profile", image: UIImage(systemName: "square.and.arrow.up")) { _ in
                
            }
            
            let copyAction = UIAction(title: "Copy URL", image: UIImage(systemName: "doc.on.doc")) { _ in
                
            }
            
            let moreMenu = UIMenu(title: "More...", children: [shareAction, copyAction])
            
            return UIMenu(title: "", image: nil, children: [repositoriesAction, starAction, achivementAction, unfollowAction, moreMenu])
             
            */
        }
    }
    private func makePreview(index: Int = 0)-> UIViewController{
        guard let selected_value = feedViewModel.fetchVideos?.result?[index] else{ return UIViewController() }
        
        
        let viewcontroller = FeedPreViewController(result: [selected_value])//UIViewController()
        //viewcontroller.view.backgroundColor = .random
        
        let prefferedWidth = view.frame.size.width * 0.8
        let prefferedHeight = view.frame.size.height * 0.6
        viewcontroller.preferredContentSize = CGSize(width: prefferedWidth, height: prefferedHeight)
        
        return viewcontroller
    }
}

extension SearchFeedController: UIScrollViewDelegate{
//    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        guard let cell = collectionView.visibleCells as? [ContentFeedCollectionCell] else{ return }
//        cell.forEach{ $0.replay() }
//    }
}
