//
//  APIEndPoints.swift
//  iOS Journey
//
//  Created by MacBook on 25/09/24.
//

import Foundation

public enum APIEndPoints: String{
    case video_data = "v3/5ac59f55-dda4-4869-89aa-d4d10b96d1c1"
}

public enum APIURL: String{
    case baseMockURL = "https://run.mocky.io/"
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
    let endPoints: APIEndPoints = .video_data
    let method: HTTPMethod
    let parameters: Parameters?
    let encoding: Encoded = .JSONEncoding
    let headers: HTTPHeaders?
}
