//
//  HomeFeedViewModel.swift
//  iOS Journey
//
//  Created by MacBook on 28/09/24.
//

import Foundation
import Combine

enum PageType: String{
    case foryou
    case following
    case discover
    case other
}

class HomeFeedViewModel: ObservableObject{
    
    var cancelable = Set<AnyCancellable>()
    
    @Published var fetchVideos: NewVideoBaseData?
    
    let networkService: MakeNetworkService
    
    let pageType: PageType
    
    
    let semaphoreQueue = DispatchSemaphore(value: 1)
    
    init(pageType: PageType,networkService: MakeNetworkService = NetworkManager()) {
        self.networkService = networkService
        self.pageType = pageType
    }
    
    public func fetchNewVideos(){
        semaphoreQueue.wait()
        var endPointType: APIEndPoints
        switch pageType {
        case .foryou:
            endPointType = .foryou_data
        case .following:
            endPointType = .following_data
        case .discover:
            endPointType = .discover_data
        case .other:
            endPointType = .following_data
        }
        let newVideosParam = NetworkParameters(baseURL: .baseMockURL, endPoints: endPointType, method: .get, parameters: nil, encoding: .JSONEncoding, headers: nil)
        networkService.makeRequest(networkParam: newVideosParam)
            .sink { [weak self] completion in
                switch completion{
                case .finished:
                    debugPrint("fetchNewVideos call finished...")
                case .failure(let error):
                    self?.fetchVideos = nil
                    debugPrint("fetchNewVideos got error : \(error.localizedDescription)")
                }
                self?.semaphoreQueue.signal()
            } receiveValue: { [weak self] (result: NewVideoBaseData) in
                debugPrint("fetchNewVideos result : \(result.result?.count ?? 0)")
                self?.fetchVideos = result
            }
            .store(in: &cancelable)

    }
}

struct NewVideoBaseData: Codable{
    let status: String?
    let result: [NewVideoModel]?
}
struct NewVideoModel: Codable{
    let video_description: String?
    let playback_url: String?
    let playback_duration: String?
    let posted_by: String?
    let publisher_image: String?
    let stream_thumbnail: String?
}
    
