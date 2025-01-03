//
//  APIEndPoints.swift
//  iOS Journey
//
//  Created by MacBook on 25/09/24.
//

import Foundation

public enum APIEndPoints: String{
    case foryou_data = "d1643cfc-d18c-4f3e-9af3-b2c63f89871d"
    case following_data = "e6d2c3af-3f4a-4427-a0fc-ab537432908e"
    case discover_data = "e58b734d-c80a-4bc7-9fce-b12e973a27ac"
    
    case chatDetails = "chatDetails"
    case uploadMedia = "uploadMedia"
}

public enum APIURL: String{
    case baseMockURL = "https://run.mocky.io/v3/"
}

public typealias HTTPHeaders = [String: String]
public typealias Parameters = [String: Any]

public struct HTTPMethod{
    static let get = HTTPMethod(rawValue: "GET")
    static let post = HTTPMethod(rawValue: "POST")
    let rawValue: String
    private init(rawValue: String) {
        self.rawValue = rawValue
    }
}

enum Encoded{
    case URLEncoding
    case JSONEncoding
}

public struct NetworkParameters{
    var baseURL: APIURL = .baseMockURL
    var endPoints: APIEndPoints
    let method: HTTPMethod
    let parameters: Parameters?
    var encoding: Encoded = .JSONEncoding
    let headers: HTTPHeaders?
}
