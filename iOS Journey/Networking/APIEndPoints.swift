//
//  APIEndPoints.swift
//  iOS Journey
//
//  Created by MacBook on 25/09/24.
//

import Foundation

public enum APIEndPoints: String{
    case foryou_data = "65b35e44-aafc-4e8c-b417-b478a36e159c"
    case following_data = "de982c7f-4551-4ca0-a4c8-ecb935722e45"
    case discover_data = "1935e34f-012b-464d-85b9-f5bceab5a08a"
}
// DEL : https://designer.mocky.io/manage/delete/8a3cf3c7-0755-404e-a0c5-b9e0c63e8053/vOeIcErVFkFs2UHTAd6ofiyuxOg4spfQsVlv
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
