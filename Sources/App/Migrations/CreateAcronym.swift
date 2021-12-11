//
//  CreateAcronym.swift
//  
//
//  Created by Ercan Garip on 7.12.2021.
//

import Fluent

struct CreateAcronym: Migration {
  func prepare(on database: Database) -> EventLoopFuture<Void> {
    database.schema("acronyms")
      .id()
      .field("short", .string, .required)
      .field("long", .string, .required)
      .field("userID", .uuid, .required, .references("users", "id"))
      .create()
  }
  
  func revert(on database: Database) -> EventLoopFuture<Void> {
    database.schema("acronyms").delete()
  }
}
