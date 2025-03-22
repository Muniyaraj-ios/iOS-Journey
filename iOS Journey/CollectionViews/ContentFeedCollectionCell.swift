//
//  ContentFeedCollectionCell.swift
//  iOS Journey
//
//  Created by Munish on  01/10/24.
//

import UIKit
import AVKit
import PINRemoteImage

final class ContentFeedCollectionCell: BaseCollectionCell{
    
    private var userNamelabel: UILabel!
    private var descriptionLabel: UILabel!
    private var imageView: UIImageView!
    private var playIcon: UIImageView!
    
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
    
    var videoData_pexeles: FeedVideoResponse?{
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
        
        playIcon = UIImageView(image: UIImage(named: "play_icon"))
        addSubview(playIcon)
        playIcon.makeCenterConstraints(toView: self)
        playIcon.sizeConstraints(width: 50, height: 50)
        
        playIcon.isHidden = true
        
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
                showPlay()
            } else {
                videoPlayer.play()
                hidePlayImage()
            }
        }
        
        func showPlay() {
            playIcon.alpha = 0.2
            playIcon.transform = CGAffineTransform(scaleX: 1.8, y: 1.8)
            playIcon.isHidden = false
            
            UIView.animate(withDuration: 0.2) { [unowned self] in
                playIcon.transform = CGAffineTransform(scaleX: 1, y: 1)
                playIcon.alpha = 1
            }
        }
        
        func hidePlayImage() {
            playIcon.isHidden = true
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(pause), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    @objc func buttonAction(_ sender: UIButton){
        switch sender{
        case likeButtonView:
            debugPrint("like clicked")
            self.likeButtonView.imageViewButton.transform = CGAffineTransform.identity.scaledBy(x: 0.001, y: 0.001)
            UIView.animate(withDuration: 0.3 / 1, animations: {
                self.likeButtonView.transform =
                CGAffineTransform.identity.scaledBy(x: 1.1, y: 1.1)
            }) { finished in
                UIView.animate(withDuration: 0.3 / 2, animations: {
                    self.likeButtonView.imageViewButton.transform = CGAffineTransform.identity.scaledBy(x: 0.9, y: 0.9)
                }) { finished in
                    UIView.animate(withDuration: 0.3 / 2, animations: {
                        self.likeButtonView.imageViewButton.transform = CGAffineTransform.identity
                    })
                }
            }
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
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else{ return }
            if let stream_thumbnail = data?.stream_thumbnail,let thumURL = URL(string: stream_thumbnail){
                imageView.pin_updateWithProgress = true
                imageView.pin_setImage(from: thumURL, placeholderImage: nil){ result in
                    DispatchQueue.main.async { [ weak self] in
                        guard let self = self else{ return }
                        imageView.image = result.image
                    }
                }
            }
        }
    }
    
    func setupConfigure(_ data: FeedVideoResponse?){
        let _ = "My Autumn Collection 🍁 #foryou #trending #fashion #getreadywithme #fashion #style #love #instagood #like #photography #beautiful #photooftheday #follow #instagram #picoftheday #model #bhfyp #art #beauty #instadaily #me #likeforlikes #smile #ootd #followme #moda #fashionblogger #happy #cute #instalike #myself #fashionstyle #photo"

        userNamelabel.text = data?.user.name
        descriptionLabel.text = data?.user.url
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else{ return }
            if let stream_thumbnail = data?.image,let thumURL = URL(string: stream_thumbnail){
                imageView.pin_updateWithProgress = true
                imageView.pin_setImage(from: thumURL, placeholderImage: nil){ result in
                    DispatchQueue.main.async { [ weak self] in
                        guard let self = self else{ return }
                        imageView.image = result.image
                    }
                }
            }
        }
    }
    
    private func updatePlayerView(){
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else{ return }
            
            guard let playback_url = videoData?.playback_url,let videoURL = URL(string: playback_url) else{
                
                let videoFile_ = videoData_pexeles?.video_files.filter({ $0.quality == "hd" })
                guard let videoFile = videoFile_?.last, !videoFile.link.isEmpty,let videoURL = URL(string: videoFile.link) else{ return }
                loadVideo(playbackurl: videoURL)
                
                return
            }
            loadVideo(playbackurl: videoURL)
        }
    }
    
    fileprivate func loadVideo(playbackurl videoURL: URL){
        let playerItem = AVPlayerItem(url: videoURL)
        queuePlayer = AVQueuePlayer(playerItem: playerItem)
        playerLayer = AVPlayerLayer(player: queuePlayer)
        
        guard let player_Layer = playerLayer else{ return }
        guard let queue_player = queuePlayer else{ return }
        
        playbackLooper = AVPlayerLooper.init(player: queue_player, templateItem: playerItem)
        player_Layer.videoGravity = .resizeAspectFill
        DispatchQueue.main.async { [ weak self] in
            guard let self = self else{ return }
            player_Layer.frame = imageView.bounds
            
            // Create a container view
            let playerContainerView = UIView(frame: imageView.bounds)
            playerContainerView.layer.addSublayer(player_Layer)
            imageView.addSubview(playerContainerView)
        }
        
        
        addPeriodicTimeObserver()
    }
    
    func hideTopPriorities(){
        [userNamelabel, descriptionLabel, progressView, likeButtonView, commentButtonView, shareButtonView, moreButtonView, playIcon].forEach{
            $0?.isHidden = true
        }
        
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
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
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
                DispatchQueue.main.async { [ weak self] in
                    guard let self = self else{ return }
                    progressView.progress = roundValue
                }
            }
        }
    }
}

extension ContentFeedCollectionCell{
    
    func replay(){
        guard let player = queuePlayer else{ return }
        guard player.timeControlStatus != .playing else{ return }
        play()
    }
    
    func play(){
        guard let player = queuePlayer else{ return }
        guard player.timeControlStatus != .playing else{ return }
        player.play()
    }
    
    @objc func pause(){
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


func cacheVideo(from url: URL, completion: @escaping (URL?) -> Void) {
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        if let data = data, error == nil {
            let fileManager = FileManager.default
            let documentDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            let videoURL = documentDirectory.appendingPathComponent(url.lastPathComponent)

            do {
                try data.write(to: videoURL)
                completion(videoURL)  // Successfully cached
            } catch {
                print("Failed to save video: \(error)")
                completion(nil)
            }
        } else {
            print("Download error: \(error?.localizedDescription ?? "Unknown error")")
            completion(nil)
        }
    }
    task.resume()
}
