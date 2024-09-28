//
//  APIEndPoints.swift
//  iOS Journey
//
//  Created by MacBook on 25/09/24.
//

import Foundation

public enum APIEndPoints: String{
    case video_data = "/v3/dbfc68d2-0c27-4885-883d-5f47d20f81e4"
}
// DEL : https://designer.mocky.io/manage/delete/8a3cf3c7-0755-404e-a0c5-b9e0c63e8053/vOeIcErVFkFs2UHTAd6ofiyuxOg4spfQsVlv
public enum APIURL: String{
    case baseMockURL = "https://run.mocky.io"
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
    var endPoints: APIEndPoints = .video_data
    let method: HTTPMethod
    let parameters: Parameters?
    var encoding: Encoded = .JSONEncoding
    let headers: HTTPHeaders?
}
