//
//  APIEndPoints.swift
//  iOS Journey
//
//  Created by MacBook on 25/09/24.
//

import Foundation

public enum APIEndPoints: String{
    case foryou_data = "v3/37620916-e625-4961-9679-e6bd38a1a290"
    case following_data = "v3/61c41c0d-8297-4b5e-98ae-51a4fe12d979"
    case discover_data = "v3/a86074a5-afe2-4d90-a7fd-cc9b39b14701"
}
// DEL : https://designer.mocky.io/manage/delete/8a3cf3c7-0755-404e-a0c5-b9e0c63e8053/vOeIcErVFkFs2UHTAd6ofiyuxOg4spfQsVlv
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
    var endPoints: APIEndPoints
    let method: HTTPMethod
    let parameters: Parameters?
    var encoding: Encoded = .JSONEncoding
    let headers: HTTPHeaders?
}
