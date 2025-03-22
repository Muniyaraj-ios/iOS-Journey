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
        button.backgroundColor = UIColor(red: 254/255, green: 44/255, blue: 85/255, alpha: 1.0)
        button.layer.cornerRadius = captureButton.frame.height / 2
        return button
    }()
    
    private lazy var captureButtonRingView: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor(red: 254/255, green: 44/255, blue: 85/255, alpha: 1.0).cgColor
        view.layer.borderWidth = 6
        return view
    }()
    
    lazy var stackList = VerticalStack(arrangedSubViews: [flipCameraView], spacing: 20, alignment: .fill, distribution: .fillEqually)
    
    let cameraVM = CameraAudioViewModel()
    
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
    private func initalizeUI(){
        setupView()
        setupTheme()
        setupLang()
        setupFont()
        setupDelegate()
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
        
        [bgView, dismissBtn, stackList].forEach{
            $0.layer.zPosition = 1
        }
    }
    private func setupConstrainats(){
        
    }
    private func setupTheme(){
        
    }
    private func setupLang(){
        
    }
    private func setupFont(){
        
    }
    private func setupDelegate(){
        
    }
    private func setupAction(){
        [dismissBtn, flipCameraView].forEach{
            $0?.addTarget(self, action: #selector(dismissAction), for: .touchUpInside)
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
        let newCameraDevice = currentInput?.device.position == .back ? getDeviceFront(position: .front) : getDeviceBack(position: .back)
        
        let newVideoInput = try? AVCaptureDeviceInput(device: newCameraDevice!)
        
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
            self?.captureSession.stopRunning()
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
