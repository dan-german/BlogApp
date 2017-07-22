//
//  Comment.swift
//  BlogApp
//
//  Created by Dan German on 22/07/2017.
//  Copyright © 2017 Dan German. All rights reserved.
//

import ObjectMapper

struct Comment: Mappable {
    
    
    private(set) var text: String?
    private(set) var userId: String?
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        
        
        text <- map["text"]
        userId <- map["user_id"]
    }
}
