//
//  ChatViewModel.swift
//  iOS Journey
//
//  Created by Munish on  02/01/25.
//

import Foundation
import Combine

final class ChatViewModel{
    
    public var cancellable = Set<AnyCancellable>()
    
    let userId: String = ""
    let receiverId: String
    let networkService: NetworkingService
    
    init(receiverId: String, networkService: NetworkingService) {
        self.receiverId = receiverId
        self.networkService = networkService
    }
    
    @MainActor func getChatDetails(){
        let networkParam = NetworkParams(baseURL: .baseMockURL, endPoint: .chatDetails, method: .get, parameters: nil, mimeType: .none, encodingType: .JSONEncoding)
        networkService.makeRequest(networkParam: networkParam)
            .sink { completion in
                switch completion{
                case .finished:
                    debugPrint("getChatDetails result did finish")
                case .failure(let failureError):
                    debugPrint("getChatDetails result did fail with error : \(failureError.localizedDescription)")
                }
            } receiveValue: { (result: BaseCommonModel) in
                debugPrint("result : \(result.message ?? "no message")")
            }
            .store(in: &cancellable)
    }
    
    @MainActor func sendChatMessageWithMedia(mediaType: MimeType){
        
        var parameters: [String: Any] = [:]
        
        switch mediaType {
        case .image( _):
            parameters = ["user_id": userId, "type": "chatimage"]
            break
        case .video( _):
            parameters = ["user_id": userId, "type": "chatvideo",  "file_uploaded_time": ""]
            break
        }
        
        let networkParam = NetworkParams(baseURL: .baseMockURL, endPoint: .uploadMedia, method: .post, parameters: parameters, mimeType: mediaType, encodingType: .MultiPart)
        networkService.makeRequest(networkParam: networkParam)
            .sink { completion in
                switch completion{
                case .finished:
                    debugPrint("media upload did finish")
                case .failure(let failureError):
                    debugPrint("media upload did fail with error : \(failureError.localizedDescription)")
                }
            } receiveValue: { (result: MediaUploadModel) in
                debugPrint("result status : \(result.status ?? "unknown")")
                debugPrint("result message : \(result.message ?? "no message")")
                debugPrint("result view_url : \(result.view_url ?? "no url")")
            }
            .store(in: &cancellable)
    }
}
