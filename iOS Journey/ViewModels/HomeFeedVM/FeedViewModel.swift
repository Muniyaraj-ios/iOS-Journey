//
//  FeedViewModel.swift
//  iOS Journey
//
//  Created by Munish on  19/03/25.
//

import Foundation
import UIKit
import Combine

actor FeedViewModel{
    
    private let service: AdvancedService
    
    @MainActor private(set) var currentPage: Int
    private(set) var perPageLimit: Int = 5
    let pageType: PageType
    
    @MainActor private(set) var videoFeeds: [FeedVideoResponse] = []
    @MainActor @Published private(set) var pageRefreshCalled: Bool = false
    @MainActor public var currentIndexPath: IndexPath?
    
    var cancellable = Set<AnyCancellable>()
    
    @MainActor weak var refresh: RefreshFeedWithData?
    
    init(pageType: PageType, service: AdvancedService = .primary) {
        self.pageType = pageType
        self.service = service
        self.currentPage = 1
        Task{
            await fetchSearchVideos()
        }
    }
    
    func fetchSearchVideos() async{
        Task{
            let networkParam = await NetworkParams(baseURL: .basePexelURL, endPoint: .popular(page: currentPage, perPage: perPageLimit), method: .get)
            print("networkParam : \(networkParam.baseURL.rawValue)\(networkParam.endPoint.endPath) , \(networkParam.method.rawValue), \(String(describing: networkParam.parameters)) ")
            do{
                let feedResponse: FeedResponse = try await service.performNetworkService(networkParam: networkParam)
                
                let newVideos = feedResponse.videos
                
                if await currentPage == 0 {
                    await MainActor.run {
                        videoFeeds.removeAll()
                    }
                }
                
                if !newVideos.isEmpty {
                    await MainActor.run {
                        DispatchQueue.main.async { [weak self] in
                            print("new video fetched....")
                            self?.videoFeeds.append(contentsOf: newVideos)
                            self?.pageRefreshCalled = false
                            self?.refresh?.batchUpdate()
                        }
                    }
                }
                
            }catch let error{
                await MainActor.run {
                    pageRefreshCalled = false
                }
                print("got an error : \(error.localizedDescription)")
            }
        }
    }
    
    func fetchNextPageVideos() async{
        
        await MainActor.run {
            currentPage += 1
            pageRefreshCalled = true
        }
        
        await fetchSearchVideos()
    }
}

protocol RefreshFeedWithData: AnyObject{
    
    func batchUpdate()
    func reloadFresh()
}
