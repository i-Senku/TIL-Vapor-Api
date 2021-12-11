//
//  File.swift
//  
//
//  Created by Ercan Garip on 8.12.2021.
//

import Fluent
import Vapor

struct UserController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        let usersRoute = routes.grouped("api","users")
        usersRoute.get(use: getUsers)
        usersRoute.get(":userId", use: getUsers)
        usersRoute.post(use: createUser)
        usersRoute.delete(use: deleteUser)
        usersRoute.get(
          ":userId",
          "acronyms",
          use: getAcronymsHandler)
    }
    
    func createUser (_ req: Request) throws -> EventLoopFuture<User> {
        let user = try req.content.decode(User.self)
        return user.save(on: req.db).transform(to: user)
    }
    
    func getUsers (_ req: Request) throws -> EventLoopFuture<[User]> {
        return User.query(on: req.db).all()
    }
    
    func getUserById (_ req: Request) throws -> EventLoopFuture<User> {
        let user = User.find(req.parameters.get("userId"), on: req.db)
            .unwrap(or: Abort(.notFound))
        return user
    }
    
    func deleteUser (_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let user = User.find(req.parameters.get("userId"), on: req.db).unwrap(or: Abort(.notFound))
        return user.flatMap { foundedUser in
            return foundedUser.delete(on: req.db).transform(to: HTTPStatus.ok)
        }
    }
    
    func getAcronymsHandler(_ req: Request) -> EventLoopFuture<[Acronym]> {
      User.find(req.parameters.get("userId"), on: req.db)
        .unwrap(or: Abort(.notFound))
        .flatMap { user in
            user.$acronyms.get(on: req.db)
        }
    }
    
}
