//
//  HomeFeedViewModel.swift
//  iOS Journey
//
//  Created by MacBook on 28/09/24.
//

import Foundation
import Combine

final class HomeFeedViewModel: ObservableObject{
    
    var cancelable = Set<AnyCancellable>()
    
    @Published var fetchVideos: NewVideoBaseData?
    
    let networkService: MakeNetworkService
    
    init(networkService: MakeNetworkService = NetworkManager()) {
        self.networkService = networkService
    }
    
    public func fetchNewVideos(){
        let newVideosParam = NetworkParameters(baseURL: .baseMockURL, endPoints: .video_data, method: .get, parameters: nil, encoding: .JSONEncoding, headers: nil)
        networkService.makeRequest(networkParam: newVideosParam)
            .sink { completion in
                switch completion{
                case .finished:
                    debugPrint("fetchNewVideos call finished...")
                case .failure(let error):
                    debugPrint("fetchNewVideos got error : \(error.localizedDescription)")
                }
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
    
