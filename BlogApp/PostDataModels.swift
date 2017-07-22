//
//  BlogDataModel.swift
//  BlogApp
//
//  Created by Dan German on 24/06/2017.
//  Copyright © 2017 Dan German. All rights reserved.
//

import ObjectMapper
import UIKit

struct Response: Mappable {
    
    
    var response = [Post]()
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        
        
        response <- map["response"]
    }
}

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

struct Comment: Mappable {
    
    
    private(set) var text: String?
    private(set) var userId: String?
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        
        
        text <- map["text"]
        userId <- map["user_id"]
    }
}
