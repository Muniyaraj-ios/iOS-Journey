//
//  ChatMessageModel.swift
//  iOS Journey
//
//  Created by MacBook on 02/01/25.
//

import Foundation

struct BaseCommonModel: Codable, BaseSwiftJSON{
    let status, message: String?
    
    init(status: String?, message: String?) {
        self.status = status
        self.message = message
    }
    
    init(json: JSON_Local) {
        self.status = json["status"].stringValue
        self.message = json["message"].stringValue
    }
}
struct MediaUploadModel: Codable, BaseSwiftJSON{
    
    let status: String?
    let name, view_url, message: String?
    let thumbnail_url: String?
    let thumbnail_name: String?
    
    init(status: String?, name: String?, view_url: String?, message: String?, thumbnail_url: String?, thumbnail_name: String?) {
        self.status = status
        self.name = name
        self.view_url = view_url
        self.message = message
        self.thumbnail_url = thumbnail_url
        self.thumbnail_name = thumbnail_name
    }
    
    init(json: JSON_Local) {
        self.status = json["status"].stringValue
        self.name = json["name"].stringValue
        self.view_url = json["view_url"].stringValue
        self.message = json["message"].stringValue
        self.thumbnail_url = json["thumbnail_url"].stringValue
        self.thumbnail_name = json["thumbnail_name"].stringValue
    }
}
