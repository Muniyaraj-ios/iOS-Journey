//
//  APIEndService.swift
//  iOS Journey
//
//  Created by Munish on  02/01/25.
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
    static let pexels_private_key = "oitTgCKJvn4pVgzyhC5zMTCUGyYJBw0dQ5WZxojOn8eW5bO0wwYZuhy9"
}

public enum APIEndService: String{
    
    case dashboard = "dashboard"
}


