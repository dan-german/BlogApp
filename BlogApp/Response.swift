//
//  Response.swift
//  BlogApp
//
//  Created by Dan German on 24/06/2017.
//  Copyright © 2017 Dan German. All rights reserved.
//

import ObjectMapper

struct Response: Mappable {
    
    
    var response = [Post]()
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        
        
        response <- map["response"]
    }
}
