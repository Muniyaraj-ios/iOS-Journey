//
//  NotificationViewModel.swift
//  iOS Journey
//
//  Created by MacBook on 28/09/24.
//

import Foundation
import UserNotifications
import Combine

final class NotificationViewModel: NSObject, ObservableObject, UNUserNotificationCenterDelegate{
    
    @Published var isNotificationAuthorized: PermissionState = .none
    
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        checkNotificationAuthorization()
    }
    
    // CHECK NOTIFICATION AUTHORIZATION
    
    func checkNotificationAuthorization(){
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async { [weak self] in
                switch settings.authorizationStatus {
                case .notDetermined:
                    self?.requestNotificationAuthorization()
                case .denied:
                    self?.isNotificationAuthorized = .not_granted
                case .authorized:
                    self?.isNotificationAuthorized = .granted
                case .provisional, .ephemeral:
                    break
                @unknown default:
                    self?.isNotificationAuthorized = .none
                    break
                }
            }
        }
    }
    
    // REQUEST NOTIFICATION AUTHORIZATION
    
    func requestNotificationAuthorization(){
        let option: UNAuthorizationOptions = [.alert, .badge, .sound]
        
        UNUserNotificationCenter.current().requestAuthorization(options: option) { granted, error in
            DispatchQueue.main.async { [weak self] in
                self?.isNotificationAuthorized = granted ? .granted : .not_granted
                if let error{
                    debugPrint("Error requesting notification permission : \(error.localizedDescription)")
                }
            }
        }
    }
}

extension NotificationViewModel{
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Handle the notification response
        debugPrint("User interacted with notification: \(response.notification.request.content.userInfo)")
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Handle how to present the notification
        completionHandler([.banner, .list, .sound, .badge])
    }
    
}
