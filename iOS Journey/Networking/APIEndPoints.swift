//
//  APIEndPoints.swift
//  iOS Journey
//
//  Created by MacBook on 25/09/24.
//

import Foundation

public enum APIEndPoints: String{
    case foryou_data = "65892642-e682-46a7-83a8-28f24cb007d7"
    case following_data = "0f9a7dd2-55ce-4222-b9bf-e2814c4bc23b"
    case discover_data = "98fcc75b-a3cf-4856-8847-37c953c3f876"
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
