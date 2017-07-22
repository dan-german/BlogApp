//
//  Post.swift
//  BlogApp
//
//  Created by Dan German on 22/07/2017.
//  Copyright © 2017 Dan German. All rights reserved.
//

import ObjectMapper

struct Post: Mappable {
    
    
    private(set) var postId: String?
    private(set) var title: String?
    private(set) var content: String?
    private(set) var userId: String?
    private(set) var username: String?
    private(set) var comments = [Comment]()
    private(set) var timestamp: Double?
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        
        
        postId <- map["_id"]
        title <- map["title"]
        content <- map["content"]
        userId <- map["user_id"]
        username <- map["username"]
        comments <- map["comments"]
        timestamp <- map["timestamp"]
    }
}
