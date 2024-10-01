//
//  HomeController.swift
//  iOS Journey
//
//  Created by MacBook on 25/09/24.
//

import UIKit
import Combine


final class HomeController: BaseController {
    
    lazy var collectionView: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collection.register(ContentFeedCollectionCell.self, forCellWithReuseIdentifier: ContentFeedCollectionCell.resuseIdentifier)
        collection.showsVerticalScrollIndicator = false
        collection.isPagingEnabled = true
        collection.backgroundColor = .clear
        return collection
    }()
    
    private let feedViewModel: HomeFeedViewModel
    @objc dynamic var currentIndex: Int = 0
    
    init(pageType: PageType){
        self.feedViewModel = HomeFeedViewModel(pageType: pageType)
        super.init(nibName: nil, bundle: nil)
        view.addSubview(collectionView)
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        if let cell = collectionView.visibleCells.first as? ContentFeedCollectionCell{
            cell.play()
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let cell = collectionView.visibleCells.first as? ContentFeedCollectionCell{
            cell.pause()
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.makeEdgeConstraints(top: view.topAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor)
    }
    private func setupView(){
        view.backgroundColor = .clear
        
        // Disable content inset adjustment
        collectionView.contentInsetAdjustmentBehavior = .never
        
        // Ensure insets are zero
        collectionView.contentInset = .zero
        collectionView.scrollIndicatorInsets = .zero
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
    private func setupNetworkCall(){
        feedViewModel.fetchNewVideos()
        
        feedViewModel.$fetchVideos
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

extension HomeController: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return feedViewModel.fetchVideos?.result?.count ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ContentFeedCollectionCell.resuseIdentifier, for: indexPath) as? ContentFeedCollectionCell else{ return UICollectionViewCell() }
        let video_data = feedViewModel.fetchVideos?.result?[indexPath.item]
        cell.setupConfigure(video_data)
        cell.videoData = video_data
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? ContentFeedCollectionCell{
            currentIndex = indexPath.item
            cell.pause()
        }
    }
}

extension HomeController: UIScrollViewDelegate{
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let cell = collectionView.cellForItem(at: IndexPath(row: currentIndex, section: 0)) as? ContentFeedCollectionCell
        cell?.replay()
    }
}

