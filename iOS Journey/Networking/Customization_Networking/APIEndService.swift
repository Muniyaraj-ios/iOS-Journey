//
//  APIEndService.swift
//  iOS Journey
//
//  Created by MacBook on 02/01/25.
//

import UIKit
import SwiftyJSON

public typealias JSON_Local = JSON

protocol BaseSwiftJSON{
    init(json: JSON_Local)
}

public enum APIURL_: String{
    case baseMockURL = "https://run.mocky.io/"
}

public struct PrivateKeys{
    static let privacyCredential = ["api_username": "", "api_password": ""]
    static let privacyLanguage = ["lang_type": "en"]
}

public enum APIEndService: String{
    
    case dashboard = "dashboard"
}


public struct NetworkParams{
    var baseURL: APIURL_
    var endPoint: APIEndPoints
    var method: HTTPMethod
    var parameters: Parameters?
    var mimeType: MimeType? = nil
    //var headers: HTTPHeaders?
    var encodingType: EncodingType = .URLEncoding
    
}

public enum EncodingType{
    case URLEncoding
    case JSONEncoding
    case MultiPart
}

public enum APIRequestSendType{
    case normal
    case image
    case video
}
