//
//  CameraAudioViewModel.swift
//  iOS Journey
//
//  Created by MacBook on 28/09/24.
//

import Foundation
import Combine
import AVFoundation

final class CameraAudioViewModel: NSObject{
    
    @Published var isCameraAuthorized: PermissionState = .none
    @Published var isAudioAuthorized: PermissionState = .none
    
    deinit {
        debugPrint(" \(String(describing: Self.self)) deinited")
    }
}

// MARK:: CAMERA PERMISSION

extension CameraAudioViewModel{
    func checkCameraAuthorization(){
        switch AVCaptureDevice.authorizationStatus(for: .video){
        case .notDetermined:
            requestCameraAccess()
            break
        case .restricted, .denied:
            isCameraAuthorized = .not_granted
            break
        case .authorized:
            isCameraAuthorized = .granted
            break
        @unknown default:
            isCameraAuthorized = .none
            break
        }
    }
    
    private func requestCameraAccess(){
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async { [weak self] in
                self?.isCameraAuthorized = granted ? .granted : .not_granted
            }
        }
    }
}

// MARK:: Audio PERMISSION

extension CameraAudioViewModel{
    func checkAudioAuthorization(){
        switch AVCaptureDevice.authorizationStatus(for: .audio){
        case .notDetermined:
            requestAudioAccess()
            break
        case .restricted, .denied:
            isAudioAuthorized = .not_granted
            break
        case .authorized:
            isAudioAuthorized = .granted
            break
        @unknown default:
            isAudioAuthorized = .none
            break
        }
    }
    
    private func requestAudioAccess(){
        AVCaptureDevice.requestAccess(for: .audio) { [weak self] granted in
            self?.isAudioAuthorized = granted ? .granted : .not_granted
        }
    }
}

enum PermissionState{
    case granted
    case not_granted
    case none
}
