//
//  UserGameStatus.swift
//  HW Assassin
//
//  Created by Justin Rose on 4/3/17.
//  Copyright © 2017 James Kanoff. All rights reserved.
//

import UIKit
import CoreData

class UserGameStatus: NSManagedObject {
    @discardableResult
    class func statusWithStatusInfo(_ statusInfo:[String:Any], inManageObjectContext context: NSManagedObjectContext) -> UserGameStatus
    {
        let request: NSFetchRequest<UserGameStatus> = UserGameStatus.fetchRequest()
        request.predicate = NSPredicate(format: "id=%d", statusInfo["id"] as! Int64)
        if let s = (try? context.fetch(request))?.first{
            print("Object already exists")
            s.status = statusInfo["status"] as? String
            
            let userRequest: NSFetchRequest<User> = User.fetchRequest()
            userRequest.predicate = NSPredicate(format: "id=%d", statusInfo["user"] as! Int64!)
            if let user = (try? context.fetch(userRequest))?.first{
                s.user = user
            }
            
            let gameRequest: NSFetchRequest<Game> = Game.fetchRequest()
            gameRequest.predicate = NSPredicate(format: "id=%d", statusInfo["game"] as! Int64!)
            if let game = (try? context.fetch(gameRequest))?.first{
                s.game = game
            }
            
            let targetRequest: NSFetchRequest<User> = User.fetchRequest()
            targetRequest.predicate = NSPredicate(format: "id=%d", statusInfo["target"] as! Int64!)
            if let target = (try? context.fetch(targetRequest))?.first{
                s.target = target
            }
            
            return s
        }
        else{
            let status = UserGameStatus(context: context)
            status.id = statusInfo["id"] as! Int64!
            status.status = statusInfo["status"] as? String
            
            let userRequest: NSFetchRequest<User> = User.fetchRequest()
            userRequest.predicate = NSPredicate(format: "id=%d", statusInfo["user"] as! Int64!)
            if let user = (try? context.fetch(userRequest))?.first{
                status.user = user
            }
            
            let gameRequest: NSFetchRequest<Game> = Game.fetchRequest()
            gameRequest.predicate = NSPredicate(format: "id=%d", statusInfo["game"] as! Int64!)
            if let game = (try? context.fetch(gameRequest))?.first{
                status.game = game
            }
            
            let targetRequest: NSFetchRequest<User> = User.fetchRequest()
            targetRequest.predicate = NSPredicate(format: "id=%d", statusInfo["target"] as! Int64!)
            if let target = (try? context.fetch(targetRequest))?.first{
                status.target = target
            }
            
            return status
        }
    }
}
