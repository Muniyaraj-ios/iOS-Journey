//
//  HomeAdvanceController.swift
//  iOS Journey
//
//  Created by MAC on 19/03/25.
//

import UIKit

final class HomeAdvanceController: BaseController {
    
    lazy var collectionView: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: CompositionalLayout.FeedLayout())
        collection.register(ContentFeedCollectionCell.self, forCellWithReuseIdentifier: ContentFeedCollectionCell.resuseIdentifier)
        collection.showsVerticalScrollIndicator = false
        collection.isPagingEnabled = true
        collection.backgroundColor = .clear
        collection.isUserInteractionEnabled = true
        return collection
    }()
    
    lazy var indicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.hidesWhenStopped = true
        indicator.tintColor = .gray
        return indicator
    }()
    
    private let feedViewModel: FeedViewModel
    
    init(pageType: PageType){
        feedViewModel = FeedViewModel(pageType: pageType)
        super.init(nibName: nil, bundle: nil)
        view.addSubview(collectionView)
        view.addSubview(indicator)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupDelegate()
        feedViewModel.refresh = self
        listeners()
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.makeEdgeConstraints(top: view.topAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor)
        indicator.makeEdgeConstraints(top: nil, leading: nil, trailing: nil, bottom: view.safeAreaLayoutGuide.bottomAnchor, edge: .init(top: 0, left: 0, bottom: 12, right: 0))
        indicator.makeCenterConstraints(toView: view, centerX_axis: true, centerY_axis: false)
        indicator.sizeConstraints(width: 30, height: 30)
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
        //collectionView.reloadData()
    }
    
    private func listeners(){
        feedViewModel.$pageRefreshCalled
            .sink { [self] hide in
                indicator.isHidden = !hide
                if hide{
                    indicator.startAnimating()
                }
            }
            .store(in: &feedViewModel.cancellable)
    }
}

extension HomeAdvanceController: RefreshFeedWithData{
    
    func batchUpdate() {
        let oldCount = collectionView.numberOfItems(inSection: 0)
        let newCount = feedViewModel.videoFeeds.count
        
        print("current Videos count : \(newCount)")
        
        guard newCount > oldCount else {
            if newCount < oldCount { collectionView.reloadData() }
            return
        }
        
        let indexPaths = (oldCount..<newCount).map { IndexPath(item: $0, section: 0) }
        
        collectionView.performBatchUpdates({
            collectionView.insertItems(at: indexPaths)
        }, completion: { finished in
            if !finished {
                debugPrint("Batch updates failed, reloading data to ensure consistency.")
            }
        })
    }
    
    func reloadFresh() {
        collectionView.reloadData()
    }
}

extension HomeAdvanceController: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return feedViewModel.videoFeeds.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ContentFeedCollectionCell.resuseIdentifier, for: indexPath) as? ContentFeedCollectionCell else{ return UICollectionViewCell() }
        let video_data = feedViewModel.videoFeeds[indexPath.item]
        cell.setupConfigure(video_data)
        cell.videoData_pexeles = video_data
        return cell
    }
}

extension HomeAdvanceController: UIScrollViewDelegate{
    
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == collectionView,
              !feedViewModel.pageRefreshCalled else { return }
        
        let visibleCells = collectionView.visibleCells
        
        // Ensure we have visible cells and get the first one
        guard let firstVisibleCell = visibleCells.first,
              let indexPath = collectionView.indexPath(for: firstVisibleCell) else { return }
        
        // Check if the last cell is visible
        let lastIndexPath =  IndexPath(item: (collectionView.numberOfItems(inSection: 0) - 1), section: 0)
        if indexPath == lastIndexPath || visibleCells.contains(where: { collectionView.indexPath(for: $0) == lastIndexPath }) {
            print("Last cell is visible. Trigger pagination or additional loading.")
            Task{
                await feedViewModel.fetchNextPageVideos()
            }
        }
    }

}

extension HomeAdvanceController{
    
    private func playStream(for indexPath: IndexPath) {
        guard indexPath != feedViewModel.currentIndexPath else { return } // Avoid duplicate calls
        feedViewModel.currentIndexPath = indexPath
        
        let stream = feedViewModel.videoFeeds[indexPath.item]
        print("playStream called : \(stream.user.name)")
        
        // Get the cell and update its UI
        if let cell = collectionView.cellForItem(at: indexPath) as? ContentFeedCollectionCell {
            cell.play()
        }
    }
    
    private func stopStream(for indexPath: IndexPath) {
        guard indexPath == feedViewModel.currentIndexPath else { return } // Leave only if it's the active cell
        feedViewModel.currentIndexPath = nil
        
        let stream = feedViewModel.videoFeeds[indexPath.item]
        print("stopStream called : \(stream.user.name)")
        
        // Get the cell and stop streaming
        if let cell = collectionView.cellForItem(at: indexPath) as? ContentFeedCollectionCell {
            cell.stop()
        }
    }
    
    private func replayStream(for indexPath: IndexPath) {
        guard indexPath == feedViewModel.currentIndexPath else { return } // Leave only if it's the active cell
        feedViewModel.currentIndexPath = nil
        
        let stream = feedViewModel.videoFeeds[indexPath.item]
        print("replayStream called : \(stream.user.name)")
        
        // Get the cell and reply streaming
        if let cell = collectionView.cellForItem(at: indexPath) as? ContentFeedCollectionCell {
            cell.replay()
        }
    }
}

