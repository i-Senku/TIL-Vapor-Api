//
//  File.swift
//  
//
//  Created by Ercan Garip on 8.12.2021.
//

import Fluent
import Vapor

final class User: Model, Content {
    static var schema: String = "users"
    
    init() {}
    
    @ID
    var id: UUID?
     
    @Field(key: "name")
    var name: String
     
    @Field(key: "username")
    var username: String
    
    @Children(for: \.$user)
    var acronyms: [Acronym]
            
    init(id: UUID? = nil, name: String, username: String) {
        self.name = name
        self.username = username
    }
}
