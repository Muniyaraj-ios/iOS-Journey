//
//  FeedResponse.swift
//  iOS Journey
//
//  Created by MAC on 19/03/25.
//

import Foundation

struct FeedResponse: BaseSwiftJSON{
    var page: Int
    var per_page: Int
    var total_results: String
    var next_page: String
    var url: String
    var videos: [FeedVideoResponse]
    
    init(json: JSON_Local) {
        self.page = json["page"].intValue
        self.per_page = json["per_page"].intValue
        self.total_results = json["total_results"].stringValue
        self.next_page = json["next_page"].stringValue
        self.url = json["url"].stringValue
        self.videos = json["videos"].arrayValue.map{ FeedVideoResponse(json: $0) }
    }
}

struct FeedVideoResponse: BaseSwiftJSON{
    var id: Int
    var width: Int
    var height: Int
    var duration: Int
    var url: String
    var image: String
    var user: FeedUserDetail
    var video_files: [FeedVideoFileDetail]
    var video_pictures: [FeedVideo_PictureDetail]
    
    init(json: JSON_Local) {
        self.id = json["id"].intValue
        self.width = json["width"].intValue
        self.height = json["height"].intValue
        self.duration = json["duration"].intValue
        self.url = json["url"].stringValue
        self.image = json["image"].stringValue
        self.user = FeedUserDetail(json: json["user"])
        self.video_files = json["video_files"].arrayValue.map{ FeedVideoFileDetail(json: $0) }
        self.video_pictures = json["video_pictures"].arrayValue.map{ FeedVideo_PictureDetail(json: $0) }
    }
}

struct FeedUserDetail: BaseSwiftJSON{
    var id: Int
    var name: String
    var url: String
    
    init(json: JSON_Local) {
        self.id = json["id"].intValue
        self.name = json["name"].stringValue
        self.url = json["url"].stringValue
    }
}

struct FeedVideoFileDetail: BaseSwiftJSON{
    var id: Int
    var width: Int
    var height: Int
    var fps: Int
    var quality: String
    var file_type: String
    var link: String
    var size: String
    
    init(json: JSON_Local) {
        self.id = json["id"].intValue
        self.width = json["width"].intValue
        self.height = json["height"].intValue
        self.fps = json["fps"].intValue
        self.quality = json["quality"].stringValue
        self.file_type = json["file_type"].stringValue
        self.link = json["link"].stringValue
        self.size = json["size"].stringValue
    }
}

struct FeedVideo_PictureDetail: BaseSwiftJSON{
    var id: Int
    var nr: Int
    var picture: String
    
    init(json: JSON_Local) {
        self.id = json["id"].intValue
        self.nr = json["nr"].intValue
        self.picture = json["picture"].stringValue
    }
}
