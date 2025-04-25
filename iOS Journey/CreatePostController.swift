//
//  CreatePostController.swift
//  iOS Journey
//
//  Created by Munish on  01/10/24.
//

import UIKit
import AVFoundation

final class CreatePostController: BaseController {
    
    private var bgView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    private var dismissBtn: UIButton = {
        let button = UIButton()
        button.setTitle("", for: .normal)
        button.setImage(UIImage(named: "dismiss_icon"), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    private lazy var flipCameraView: CustomButton = {
        let button = CustomButton(type: .flipcamera)
        button.label.text = "Flip"
        return button
    }()
    
    
    private lazy var captureButton: UIButton = {
        let button = UIButton()
        return button
    }()
    
    private lazy var captureButtonRingView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var captureButtonBgRingView: UIView = {
        let view = UIView()
        return view
    }()
    
    var segmentedProgressView: SegmentedProgressView = SegmentedProgressView()
    
    lazy var stackList = VerticalStack(arrangedSubViews: [flipCameraView], spacing: 20, alignment: .fill, distribution: .fillEqually)
    
    let cameraVM = CameraAudioViewModel()
    
    private var isRecording: Bool = false
    
    private var recordingTimer: Timer?
    var elapsedTime: CGFloat = 0
    var totalDuration: PostDuration = .minSec
    
    var captureSession = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initalizeUI()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupListeners()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        navigationController?.isNavigationBarHidden = true
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        captureButtonRingView.makeBorderWithRadius(color: .white)
        captureButtonBgRingView.makeBorderWithRadius(color: .clear, radius: true)
        
        captureButton.makeBorderWithRadius(width: 0)
    }
    private func initalizeUI(){
        setupView()
        setupAction()
        setupObservers()
    }
    private func setupView(){
        view.backgroundColor = .clear
        
        view.addSubview(bgView)
        bgView.makeEdgeConstraints(toView: view)
        
        bgView.addSubview(dismissBtn)
        dismissBtn.makeEdgeConstraints(top: bgView.topAnchor, leading: nil, trailing: bgView.trailingAnchor, bottom: nil, edge: .init(top: 30, left: 0, bottom: 0, right: 12))
        dismissBtn.sizeConstraints(width: 40, height: 40)
        
        
        view.addSubview(stackList)
        stackList.makeEdgeConstraints(top: dismissBtn.bottomAnchor, leading: nil, trailing: bgView.trailingAnchor, bottom: nil, edge: .init(top: 20, left: 0, bottom: 0, right: 0))
        
        flipCameraView.widthConstraints(width: 55)
        
        captureButtonViews()
        
        [bgView, dismissBtn, stackList, captureButtonRingView, captureButton, captureButtonBgRingView, segmentedProgressView].forEach{
            $0.layer.zPosition = 1
        }
        
    }
    
    private func captureButtonViews(){
        
//        view.addSubview(captureButtonRingView)
//        captureButtonRingView.makeEdgeConstraints(top: nil, leading: nil, trailing: nil, bottom: view.safeAreaLayoutGuide.bottomAnchor, edge: .init(top: 0, left: 0, bottom: 12, right: 0))
//        captureButtonRingView.sizeConstraints(width: 85, height: 85)
//        captureButtonRingView.makeCenterConstraints(toView: view, centerX_axis: true, centerY_axis: false)
//        captureButtonRingView.backgroundColor = .clear
        
        view.addSubview(segmentedProgressView)
        segmentedProgressView.makeEdgeConstraints(top: nil, leading: nil, trailing: nil, bottom: view.safeAreaLayoutGuide.bottomAnchor, edge: .init(top: 0, left: 0, bottom: 12, right: 0))
        segmentedProgressView.sizeConstraints(width: 85, height: 85)
        segmentedProgressView.makeCenterConstraints(toView: view, centerX_axis: true, centerY_axis: false)
        
        segmentedProgressView.addSubview(captureButtonBgRingView)
        captureButtonBgRingView.sizeConstraints(width: 68, height: 68)
        captureButtonBgRingView.makeCenterConstraints(toView: segmentedProgressView)
        captureButtonBgRingView.backgroundColor = .systemGray3
        
        captureButtonBgRingView.isHidden = true
//        
        segmentedProgressView.addSubview(captureButton)
        captureButton.sizeConstraints(width: 68, height: 68)
        captureButton.makeCenterConstraints(toView: segmentedProgressView)
        captureButton.backgroundColor = .purple
//
        
//        captureButtonRingView.setNeedsLayout()
//        captureButtonRingView.layoutIfNeeded()
//        captureButton.setNeedsLayout()
//        captureButton.layoutIfNeeded()
        
//        segmentedProgressView.setProgress(90)
    }
}

extension CreatePostController{
    
    private func startRecording(){
        handleAnimationRecordButton()
        startRecordTimer()
    }
    
    private func stopRecording(){
        handleAnimationRecordButton()
        stopRecordTimer()
        segmentedProgressView.pauseProgress()
    }
    
    func startRecordTimer(){
        //totalDuration = duration
        //elapsedTime = 0
        stopRecordTimer()
        recordingTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(timerUpdate), userInfo: nil, repeats: true)
    }
    
    @objc private func timerUpdate(_ sender: Any){
        
        self.elapsedTime += 0.1
        self.updateProgress(elapsedTime: self.elapsedTime, totalDuration: self.totalDuration.timeLimit)
        
        if self.elapsedTime >= self.totalDuration.timeLimit {
            handleAnimationRecordButton()
            stopRecordTimer()
            segmentedProgressView.pauseProgress()
        }
        
    }
    
    func stopRecordTimer(){
        recordingTimer?.invalidate()
        recordingTimer = nil
    }
    
    func updateProgress(elapsedTime: CGFloat, totalDuration: CGFloat) {
        let progress = min(elapsedTime / totalDuration, 1.0)
        print("progress : \(progress)")
        segmentedProgressView.setProgress(progress)
    }

}

extension CreatePostController{
    
    func handleAnimationRecordButton(){
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn) { [weak self] in
            guard let self = self else{return}
            
            if !self.isRecording{
                self.captureButton.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                self.captureButton.layer.cornerRadius = 5
                self.captureButtonRingView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                self.captureButtonBgRingView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                
                self.captureButtonBgRingView.isHidden = false
                
            }else{
                self.captureButton.transform = .identity
                self.captureButtonRingView.transform = .identity
                self.captureButton.layer.cornerRadius = self.captureButton.frame.height / 2
                
                captureButtonBgRingView.isHidden = true
                
                //self.handleResetAllVisibilityToIdentity()
            }
        } completion: { [weak self] _ in
            guard let self = self else{return}
            self.isRecording = !self.isRecording
        }
        
    }
    private func setupAction(){
        [dismissBtn, flipCameraView].forEach{
            $0?.addTarget(self, action: #selector(dismissAction), for: .touchUpInside)
        }
        
//        captureButton.addTap{ [self] in
//            startRecording()
//            //handleAnimationRecordButton()
//        }
        
        captureButton.addLongPress { [self] in
            startRecording()
            //handleAnimationRecordButton()
        } endLongPress: { [self] in
            stopRecording()
            //handleAnimationRecordButton()
        }
    }
    private func setupListeners(){
        cameraVM.checkCameraAuthorization()
        cameraVM.checkAudioAuthorization()
    }
    @objc func dismissAction(_ sender: UIButton){
        switch sender{
        case dismissBtn:
            stopPreviewCamera()
            tabBarController?.selectedIndex = 1
            break
        case flipCameraView:
            switchCameraOption()
            break
        default: break
        }
    }
    private func setupObservers(){
        cameraVM.$isCameraAuthorized
            .combineLatest(cameraVM.$isAudioAuthorized)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] camera_granted, audio_granted in
                switch (camera_granted, audio_granted){
                case (.granted, .granted):
                    self?.showPreviewCamera()
                    break
                case (.granted, .not_granted), (.granted, .none), (.not_granted, .granted), (.not_granted, .none), (.none, .granted), (.none, .not_granted), (.none, .none), (.not_granted,.not_granted):
                    break
                }
            })
            .store(in: &cameraVM.cancellable)
    }
}

extension CreatePostController{
    
    func switchCameraOption(){
        
        captureSession.beginConfiguration()
        let currentInput = captureSession.inputs.first as? AVCaptureDeviceInput
        
        guard let newCameraDevice = currentInput?.device.position == .back ? getDeviceFront(position: .front) : getDeviceBack(position: .back) else{
            self.captureSession.commitConfiguration()
            return
        }
        
        let newVideoInput = try? AVCaptureDeviceInput(device: newCameraDevice)
        
        if let inputs = captureSession.inputs as? [AVCaptureDeviceInput]{
            for input in inputs {
                captureSession.removeInput(input)
            }
        }
        
        if captureSession.inputs.isEmpty{
            captureSession.addInput(newVideoInput!)
        }
        
        if let microphone = AVCaptureDevice.default(for: .audio){
            do{
                let micInput = try AVCaptureDeviceInput(device: microphone)
                if captureSession.canAddInput(micInput){
                    captureSession.addInput(micInput)
                }
            }catch let micError{
                print("Error setting device audio input : \(micError)")
            }
        }
        
        self.captureSession.commitConfiguration()
    }
}

extension CreatePostController{
    
    private func showPreviewCamera(){
        if !captureSession.isRunning && setupCaptureSession(){
            DispatchQueue.global(qos: .background).async { [weak self] in
                self?.captureSession.startRunning()
            }
        }
    }
    
    private func stopPreviewCamera(){
        DispatchQueue.global(qos: .background).async { [weak self] in
            if (self?.captureSession.isRunning ?? false){
                self?.captureSession.stopRunning()
            }
            DispatchQueue.main.async { [weak self] in
                guard let self = self else{ return }
                if previewLayer != nil{
                    previewLayer.removeFromSuperlayer()
                }
            }
        }
    }
    
    private func setupCaptureSession()-> Bool{
        captureSession.sessionPreset = .high
        
        if let captureDevice = getDeviceFront(position: .front){
            do{
                let inputVideo = try AVCaptureDeviceInput(device: captureDevice)
                
                if captureSession.canAddInput(inputVideo){
                    captureSession.addInput(inputVideo)
                }
            }catch{
                debugPrint("coundn't get camera input : \(error.localizedDescription)")
                return false
            }
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        return true
    }
    
    private func getDeviceFront(position: AVCaptureDevice.Position)-> AVCaptureDevice?{
        AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position)
    }
    private func getDeviceBack(position: AVCaptureDevice.Position)-> AVCaptureDevice?{
        AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position)
    }
}


enum PostDuration{
    case minSec
    case mediumSec
    case largeSec
    
    var timeLimit: CGFloat{
        switch self {
        case .minSec: return 15
        case .mediumSec: return 30
        case .largeSec: return 60
        }
    }
}
