//
//  HomeFeedVM_Tests.swift
//  iOS JourneyTests
//
//  Created by Munish on  02/01/25.
//

@testable import iOS_Journey
import XCTest
import Combine

final class HomeFeedVM_Tests: XCTestCase {
    
    var cancellables = Set<AnyCancellable>()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func test_HomeFeedViewModel_FetchNewVideo_shouldReturnValues(){
        // Given
        let vm = HomeFeedViewModel(pageType: .discover, networkService: NetworkManager())
        
        // When
        let expectation = XCTestExpectation(description: "Should return values in 3 sec")
        
        vm.$fetchVideos
            .dropFirst()
            .sink { baseData in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        vm.fetchNewVideos()
        
        // Then
        wait(for: [expectation], timeout: 3)
        XCTAssertNotNil(vm.fetchVideos?.result, "result is nil")
        XCTAssertFalse(vm.fetchVideos?.result?.isEmpty ?? true)
    }
}
