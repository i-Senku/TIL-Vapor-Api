//
//  File.swift
//  
//
//  Created by Ercan Garip on 10.12.2021.
//

import Fluent

struct CreateCategory: Migration {
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Category.schema)
            .id()
            .field("name", .string, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Category.schema).delete()
    }
}
