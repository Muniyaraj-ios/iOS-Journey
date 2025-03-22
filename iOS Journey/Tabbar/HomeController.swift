//
//  HomeController.swift
//  iOS Journey
//
//  Created by Munish on  25/09/24.
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
        collection.isUserInteractionEnabled = true
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
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        if let cell = collectionView.visibleCells.first as? ContentFeedCollectionCell{
            debugPrint("\(Self.self) \(feedViewModel.pageType.rawValue) playing...")
            cell.play()
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let cell = collectionView.visibleCells.first as? ContentFeedCollectionCell{
            debugPrint("\(Self.self) \(feedViewModel.pageType.rawValue) paused...")
            cell.pause()
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//        if let cell = collectionView.visibleCells.first as? ContentFeedCollectionCell{
//            cell.pause()
//        }
//    }
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
//    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        if let cell = cell as? ContentFeedCollectionCell{
//            currentIndex = indexPath.item
//            cell.pause()
//        }
//    }
}

extension HomeController: UIScrollViewDelegate{
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard scrollView == collectionView else{ return }
        let visibleCells = collectionView.visibleCells
        guard let firstVisibleCell = visibleCells.first,
              let indexPath = collectionView.indexPath(for: firstVisibleCell) else { return }
        
        // Leave the previous stream before joining the new one
        if let previousIndexPath = feedViewModel.currentIndexPath {
            stopStream(for: previousIndexPath)
        }
        
        // reply the new stream
        replayStream(for: indexPath)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView == collectionView else{ return }
        let visibleCells = collectionView.visibleCells
        guard let firstVisibleCell = visibleCells.first,
              let indexPath = collectionView.indexPath(for: firstVisibleCell) else { return }
        
        // Leave the previous stream before joining the new one
        if let previousIndexPath = feedViewModel.currentIndexPath {
            stopStream(for: previousIndexPath)
        }
        
        // Play the new stream
        playStream(for: indexPath)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard scrollView == collectionView else{ return }
        // Ensure that when dragging starts, we prepare to leave the current stream
        if let previousIndexPath = feedViewModel.currentIndexPath {
            stopStream(for: previousIndexPath)
        }
    }
}

extension HomeController{
    
    private func playStream(for indexPath: IndexPath) {
        guard indexPath != feedViewModel.currentIndexPath else { return } // Avoid duplicate calls
        feedViewModel.currentIndexPath = indexPath
        
        let stream = feedViewModel.fetchVideos?.result?[indexPath.item]
        print("playStream called : \(stream?.video_description ?? "")")
        
        // Get the cell and update its UI
        if let cell = collectionView.cellForItem(at: indexPath) as? ContentFeedCollectionCell {
            cell.play()
        }
    }
    
    private func stopStream(for indexPath: IndexPath) {
        guard indexPath == feedViewModel.currentIndexPath else { return } // Leave only if it's the active cell
        feedViewModel.currentIndexPath = nil
        
        let stream = feedViewModel.fetchVideos?.result?[indexPath.item]
        print("stopStream called : \(stream?.video_description ?? "")")
        
        // Get the cell and stop streaming
        if let cell = collectionView.cellForItem(at: indexPath) as? ContentFeedCollectionCell {
            cell.stop()
        }
    }
    
    private func replayStream(for indexPath: IndexPath) {
        guard indexPath == feedViewModel.currentIndexPath else { return } // Leave only if it's the active cell
        feedViewModel.currentIndexPath = nil
        
        let stream = feedViewModel.fetchVideos?.result?[indexPath.item]
        print("replayStream called : \(stream?.video_description ?? "")")
        
        // Get the cell and reply streaming
        if let cell = collectionView.cellForItem(at: indexPath) as? ContentFeedCollectionCell {
            cell.replay()
        }
    }
}

