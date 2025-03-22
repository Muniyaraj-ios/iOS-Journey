//
//  NetworkService.swift
//  iOS Journey
//
//  Created by Munish on  19/03/25.
//

import Foundation

actor NetworkService: AdvancedService{
    
    func performNetworkService<T: BaseSwiftJSON>(networkParam: NetworkParams) async throws -> T {
        
        guard let request = try networkParam.generateURLRequest() else{ throw URLError(.badURL) }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpsresponse = response as? HTTPURLResponse,
                200..<299 ~= httpsresponse.statusCode else{  throw URLError(.badServerResponse) }
        
        return T.init(json: JSON_Local(data))
    }
}

protocol AdvancedService: AnyObject{
    func performNetworkService<T: BaseSwiftJSON>(networkParam: NetworkParams) async throws -> T
}

extension AdvancedService where Self == NetworkService{
    static var `primary`: Self{ NetworkService() }
}
