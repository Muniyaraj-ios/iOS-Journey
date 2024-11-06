//
//  ContentFeedCollectionCell.swift
//  iOS Journey
//
//  Created by MacBook on 01/10/24.
//

import UIKit
import AVKit
import PINRemoteImage

final class ContentFeedCollectionCell: BaseCollectionCell{
    
    private var userNamelabel: UILabel!
    private var descriptionLabel: UILabel!
    private var imageView: UIImageView!
    
    private var queuePlayer: AVQueuePlayer?
    private var playerLayer: AVPlayerLayer?
    private var playbackLooper: AVPlayerLooper?
    
    private var likeButtonView: CustomButton!
    private var commentButtonView: CustomButton!
    private var shareButtonView: CustomButton!
    private var moreButtonView: CustomButton!
    
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
        
        likeButtonView = CustomButton(type: .like)
        commentButtonView = CustomButton(type: .comment)
        shareButtonView = CustomButton(type: .share)
        moreButtonView = CustomButton(type: .more)
                
        addSubview(imageView)
        imageView.makeEdgeConstraints(toView: self)
        
        let customFeedstack = VerticalStack(arrangedSubViews: [likeButtonView, commentButtonView, shareButtonView, moreButtonView], spacing: 25, alignment: .center, distribution: .fill)
        
        addSubview(customFeedstack)
        customFeedstack.makeEdgeConstraints(top: nil, leading: nil, trailing: trailingAnchor, bottom: bottomAnchor, edge: .init(top: 0, left: 0, bottom: 40, right: 15))
        
        let verticalStack = VerticalStack(arrangedSubViews: [userNamelabel, descriptionLabel], spacing: 10, alignment: .leading, distribution: .fillProportionally)
        verticalStack.isLayoutMarginsRelativeArrangement = true
        verticalStack.layoutMargins = .init(top: 0, left: 12, bottom: 8, right: 8)
        
        addSubview(verticalStack)
        verticalStack.makeEdgeConstraints(top: nil, leading: leadingAnchor, trailing: nil, bottom: nil, edge: .init(top: 0, left: 0, bottom: 0, right: 0))
        verticalStack.trailingAnchor.constraint(lessThanOrEqualTo: customFeedstack.leadingAnchor, constant: -20).isActive = true
        
        addSubview(progressView)
        progressView.makeEdgeConstraints(top: verticalStack.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, bottom: bottomAnchor, edge: .init(top: 6, left: 0, bottom: 0, right: 0))
        
        [likeButtonView, commentButtonView, shareButtonView, moreButtonView].forEach{
            $0?.widthConstraints(width: 55)
            $0?.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
        }
        
        imageView.addTap { [weak self] in
            guard let self = self, let videoPlayer = queuePlayer else { return }
            if videoPlayer.timeControlStatus == .playing {
                videoPlayer.pause()
            } else {
                videoPlayer.play()
            }
        }
        
    }
    @objc func buttonAction(_ sender: UIButton){
        switch sender{
        case likeButtonView:
            debugPrint("like clicked")
            break
        case commentButtonView:
            debugPrint("comment clicked....")
            break
        case shareButtonView:
            debugPrint("share clicked....")
            break
        case moreButtonView:
            debugPrint("more clicked....")
            break
        default: break
        }
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
        userNamelabel.text = nil
        descriptionLabel.text = nil
        imageView.image = nil
        progressView.progress = 0.0
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
        let timeInterval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        
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
            let roundValue = Float(currentTime / totalDuration)
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.progressView.progress = roundValue
            }
        }
    }
}

extension ContentFeedCollectionCell{
    
    func replay(){
        /*guard !isPlaying else{ return }
        queuePlayer?.seek(to: .zero)
        play()*/
        
        guard let player = queuePlayer else{ return }
        guard player.timeControlStatus != .playing else{ return }
        play()
    }
    
    func play(){
        /*guard !isPlaying else{ return }
        queuePlayer?.play()
        isPlaying = true
        //debugPrint("video : \(videoData?.posted_by ?? "") is playing")*/
        
        guard let player = queuePlayer else{ return }
        guard player.timeControlStatus != .playing else{ return }
        player.play()
    }
    
    func pause(){
        /*guard isPlaying else{ return }
        queuePlayer?.pause()
        isPlaying = false
        debugPrint("video : \(videoData?.posted_by ?? "") is pause")*/
        
        guard let player = queuePlayer else{ return }
        guard player.timeControlStatus == .playing else{ return }
        player.pause()
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
