//
//  APIEndPoints.swift
//  iOS Journey
//
//  Created by Munish on  25/09/24.
//

import Foundation

public enum APIEndPoints{
    case foryou_data
    case following_data
    case discover_data
    
    case chatDetails
    case uploadMedia
    case popular(page: Int, perPage: Int)
    case search(page: Int, query: String, perPage: Int)
    
//    https://api.pexels.com/videos/popular?page=1&per_page=15
//    https://api.pexels.com/videos/search?page=8&query=mixed&per_page=15

    var endPath: String{
        switch self {
        case .foryou_data: return "foryou.json"
        case .following_data: return "following.json"
        case .discover_data: return "discover.json"
        case .chatDetails: return "chatDetails"
        case .uploadMedia: return "uploadMedia"
        case .popular(page: let page, perPage: let perPage):
            return "popular?page=\(page)&per_page=\(perPage)"
        case .search(page: let page, query: let query, perPage: let perPage):
            return "search?page=\(page)&query=\(query)&per_page=\(perPage)"
        }
    }
}

// "https://raw.githubusercontent.com/Muniyaraj-ios/assets/main/Photos/products.json"

public enum APIURL: String{
    case baseMockURL = "https://raw.githubusercontent.com/Muniyaraj-ios/assets/main/Feeds/"
    case basePexelURL = "https://api.pexels.com/videos/"
}

public typealias HTTPHeaders = [String: String]
public typealias Parameters = [String: Any]

@MainActor 
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
