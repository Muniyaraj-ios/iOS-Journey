//
//  HomeController.swift
//  iOS Journey
//
//  Created by MacBook on 25/09/24.
//

import UIKit
import AVFoundation
import Combine
import PINRemoteImage

final class HomeController: BaseController {
    
    lazy var collectionView: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collection.register(ContentFeedCollectionCell.self, forCellWithReuseIdentifier: ContentFeedCollectionCell.resuseIdentifier)
        collection.showsVerticalScrollIndicator = false
        collection.isPagingEnabled = true
        collection.backgroundColor = .clear
        return collection
    }()
    
    private let feedViewModel = HomeFeedViewModel()
    @objc dynamic var currentIndex: Int = 0
    
    init(){
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

final class ContentFeedCollectionCell: BaseCollectionCell{
    
    private var userNamelabel: UILabel!
    private var descriptionLabel: UILabel!
    private var imageView: UIImageView!
    
    private var queuePlayer: AVQueuePlayer?
    private var playerLayer: AVPlayerLayer?
    private var playbackLooper: AVPlayerLooper?
    
    private var likeButtonView: CustomButton!
    
    private var progressView: CustomProgressView!
    private var timeObserverToken: Any?
    
    private var isPlaying: Bool = false
    
    var videoData: NewVideoModel?{
        didSet{
            updatePlayerView()
        }
    }
    
    override func initalizeUI() {
        super.initalizeUI()
        setupUI()
    }
    private func setupUI(){
        backgroundColor = .clear
        imageView = UIImageView(cornerRadius: 0, mode: .scaleAspectFill)
        userNamelabel = UILabel(text: "", textColor: .white, font: .customFont(style: .semiBold, size: 16))
        descriptionLabel = UILabel(text: "", textColor: .white, font: .customFont(style: .regular, size: 14), line: 4)
        
        progressView = CustomProgressView(progressViewStyle: .default)
        progressView.progress = 0.0
        progressView.trackTintColor = .tertiaryLabel
        progressView.progressTintColor = .white
        
        likeButtonView = CustomButton()
                
        addSubview(imageView)
        imageView.makeEdgeConstraints(toView: self)
        
        
        let customFeedstack = VerticalStack(arrangedSubViews: [likeButtonView], spacing: 8, alignment: .center, distribution: .fillEqually)
        addSubview(customFeedstack)
        customFeedstack.makeEdgeConstraints(top: nil, leading: nil, trailing: trailingAnchor, bottom: bottomAnchor, edge: .init(top: 0, left: 0, bottom: 40, right: 15))
        
        let verticalStack = VerticalStack(arrangedSubViews: [userNamelabel, descriptionLabel], spacing: 10, alignment: .leading, distribution: .fillProportionally)
        verticalStack.isLayoutMarginsRelativeArrangement = true
        verticalStack.layoutMargins = .init(top: 0, left: 12, bottom: 8, right: 8)
        
        addSubview(verticalStack)
        verticalStack.makeEdgeConstraints(top: nil, leading: leadingAnchor, trailing: nil, bottom: nil, edge: .init(top: 0, left: 0, bottom: 0, right: 0))
        verticalStack.trailingAnchor.constraint(lessThanOrEqualTo: customFeedstack.leadingAnchor, constant: -20).isActive = true
        
        addSubview(progressView)
        
        progressView.makeEdgeConstraints(top: verticalStack.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, bottom: bottomAnchor, edge: .init(top: 6, left: 0, bottom: 6, right: 0))
        
        
    }
    func setupConfigure(_ data: NewVideoModel?){
        let _ = "My Autumn Collection 🍁 #foryou #trending #fashion #getreadywithme #fashion #style #love #instagood #like #photography #beautiful #photooftheday #follow #instagram #picoftheday #model #bhfyp #art #beauty #instadaily #me #likeforlikes #smile #ootd #followme #moda #fashionblogger #happy #cute #instalike #myself #fashionstyle #photo"

        userNamelabel.text = data?.posted_by
        descriptionLabel.text = data?.video_description
        
        if let stream_thumbnail = data?.stream_thumbnail,let thumURL = URL(string: stream_thumbnail){
            imageView.pin_updateWithProgress = true
            imageView.pin_setImage(from: thumURL, placeholderImage: nil, completion: nil)
        }
    }
    
    private func updatePlayerView(){
        guard let playback_url = videoData?.playback_url,let videoURL = URL(string: playback_url) else{ return }
        let playerItem = AVPlayerItem(url: videoURL)
        queuePlayer = AVQueuePlayer(playerItem: playerItem)
        playerLayer = AVPlayerLayer(player: queuePlayer)
        
        guard let player_Layer = playerLayer else{ return }
        guard let queue_player = queuePlayer else{ return }
        
        playbackLooper = AVPlayerLooper.init(player: queue_player, templateItem: playerItem)
        player_Layer.videoGravity = .resizeAspectFill
        player_Layer.frame = imageView.bounds
        
        // Create a container view
        let playerContainerView = UIView(frame: imageView.bounds)
        playerContainerView.layer.addSublayer(player_Layer)
        imageView.addSubview(playerContainerView)
        
        
        addPeriodicTimeObserver()

        //imageView.layer.insertSublayer(player_Layer, at: 3)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let playerLayer else{ return }
        playerLayer.frame = imageView.bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        playerLayer?.removeFromSuperlayer()
        queuePlayer?.pause()
        if let token = timeObserverToken {
            queuePlayer?.removeTimeObserver(token)
            timeObserverToken = nil
        }
    }
    
    deinit {
        // Remove the time observer when the view controller is deallocated
        if let token = timeObserverToken {
            queuePlayer?.removeTimeObserver(token)
            timeObserverToken = nil
        }
    }
    
    func addPeriodicTimeObserver() {
        // Define the time interval for updating the progress view
        let timeInterval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        
        // Add the time observer to update the progress view
        timeObserverToken = queuePlayer?.addPeriodicTimeObserver(forInterval: timeInterval, queue: .main) { [weak self] time in
            self?.updateProgress()
        }
    }
    
    func updateProgress() {
        guard let queuePlayer = queuePlayer, let currentItem = queuePlayer.currentItem else { return }
        
        // Get the current time and total duration of the video
        let currentTime = CMTimeGetSeconds(queuePlayer.currentTime())
        let totalDuration = CMTimeGetSeconds(currentItem.duration)
        
        // Update the progress view based on the playback percentage
        if totalDuration > 0 {
            UIView.animate(withDuration: 0.5) { [weak self] in
                self?.progressView.progress = Float(currentTime / totalDuration)
            }
        }
    }
}

extension ContentFeedCollectionCell{
    
    func replay(){
        guard !isPlaying else{ return }
        queuePlayer?.seek(to: .zero)
        play()
    }
    
    func play(){
        guard !isPlaying else{ return }
        queuePlayer?.play()
        isPlaying = true
    }
    
    func pause(){
        guard isPlaying else{ return }
        queuePlayer?.pause()
        isPlaying = false
    }
    
    func stop(){
        queuePlayer?.pause()
        queuePlayer?.seek(to: CMTime(value: 0, timescale: 1))
        isPlaying = false
    }
}

class CustomProgressView: UIProgressView {
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: 3)
    }
}
