//
//  APIEndPoints.swift
//  iOS Journey
//
//  Created by MacBook on 25/09/24.
//

import Foundation

public enum APIEndPoints: String{
    case foryou_data = "foryou.json"
    case following_data = "following.json"
    case discover_data = "discover.json"
    
    case chatDetails = "chatDetails"
    case uploadMedia = "uploadMedia"
}

// "https://raw.githubusercontent.com/Muniyaraj-ios/assets/main/Photos/products.json"

public enum APIURL: String{
    case baseMockURL = "https://raw.githubusercontent.com/Muniyaraj-ios/assets/main/Feeds/"
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
