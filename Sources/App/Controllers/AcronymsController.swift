//
//  File.swift
//  
//
//  Created by Ercan Garip on 8.12.2021.
//

import Vapor
import Fluent

struct AcronymsController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        let acronymsRoute = routes.grouped("api", "acronyms")
        acronymsRoute.get("",use: getAllHandler)
        acronymsRoute.get(":acronymID", use: getUserById)
        acronymsRoute.post(use: createAcronym)
        acronymsRoute.put(":acronymID", use: updateAcronym)
        acronymsRoute.delete(":acronymID", use: deleteAcronym)
        acronymsRoute.get(":acronymID", "user", use: getUserHandler)
        acronymsRoute.post(
          ":acronymID",
          "categories",
          ":categoryID",
          use: addCategoriesHandler)
        acronymsRoute.get(
          ":acronymID",
          "categories",
          use: getCategoriesHandler)
        acronymsRoute.delete(
          ":acronymID",
          "categories",
          ":categoryID",
          use: removeCategoriesHandler)
    }
    
    func getAllHandler(_ req: Request) -> EventLoopFuture<[Acronym]> {
        return Acronym.query(on: req.db).all()
    }
    
    func getUserById(_ req: Request) -> EventLoopFuture<Acronym> {
        return Acronym.find(req.parameters.get("acronymID"), on: req.db).unwrap(or: Abort(.notFound))
    }
    
    func createAcronym(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let data = try req.content.decode(CreateAcronymData.self)
        let acronym = Acronym(short: data.short, long: data.long, userID: data.userID)
        return acronym.save(on: req.db).transform(to: HTTPStatus.ok)
    }
    
    func updateAcronym (_ req: Request) throws -> EventLoopFuture<Acronym> {
        let updateData =
          try req.content.decode(CreateAcronymData.self)
        
        return Acronym.find(req.parameters.get("acronymID"), on: req.db)
            .unwrap(or: Abort(.notFound)).flatMap { acr in
                acr.long = updateData.long
                acr.short = updateData.short
                acr.$user.id = updateData.userID
                return acr.save(on: req.db).map {
                    acr
                }
            }
    }
    
    func deleteAcronym (_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        return Acronym.find(req.parameters.get("acronymID"), on: req.db).unwrap(or: Abort(.notFound)).flatMap { foundedAcronym in
            return foundedAcronym.delete(on: req.db).transform(to: HTTPStatus.ok)
        }
    }
    
    func getUserHandler(_ req: Request)
      -> EventLoopFuture<User> {
      // 2
      Acronym.find(req.parameters.get("acronymID"), on: req.db)
        .unwrap(or: Abort(.notFound))
        .flatMap { acronym in
          // 3
          acronym.$user.get(on: req.db)
        }
    }
    
    func addCategoriesHandler(_ req: Request)
      -> EventLoopFuture<HTTPStatus> {
      let acronymQuery =
        Acronym.find(req.parameters.get("acronymID"), on: req.db)
          .unwrap(or: Abort(.notFound))
      let categoryQuery =
        Category.find(req.parameters.get("categoryID"), on: req.db)
          .unwrap(or: Abort(.notFound))
      return acronymQuery.and(categoryQuery)
        .flatMap { acronym, category in
          acronym
            .$categories
            .attach(category, on: req.db)
            .transform(to: .created)
        }
    }
    
    func getCategoriesHandler(_ req: Request)
      -> EventLoopFuture<[Category]> {
      Acronym.find(req.parameters.get("acronymID"), on: req.db)
        .unwrap(or: Abort(.notFound))
        .flatMap { acronym in
          acronym.$categories.query(on: req.db).all()
        }
    }
    
    func removeCategoriesHandler(_ req: Request)
      -> EventLoopFuture<HTTPStatus> {
      let acronymQuery =
        Acronym.find(req.parameters.get("acronymID"), on: req.db)
          .unwrap(or: Abort(.notFound))
      let categoryQuery =
        Category.find(req.parameters.get("categoryID"), on: req.db)
          .unwrap(or: Abort(.notFound))
          
      return acronymQuery.and(categoryQuery)
        .flatMap { acronym, category in
          acronym
            .$categories
            .detach(category, on: req.db)
            .transform(to: .noContent)
        }
    }


}

struct CreateAcronymData: Content {
  let short: String
  let long: String
  let userID: UUID
}
