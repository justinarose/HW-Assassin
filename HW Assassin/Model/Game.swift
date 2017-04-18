//
//  Game.swift
//  HW Assassin
//
//  Created by Justin Rose on 4/3/17.
//  Copyright © 2017 James Kanoff. All rights reserved.
//

import UIKit
import CoreData

class Game: NSManagedObject {
    
    @discardableResult
    class func gameWithGameInfo(_ gameInfo:[String:Any], inManageObjectContext context: NSManagedObjectContext) -> Game
    {
        let request: NSFetchRequest<Game> = Game.fetchRequest()
        request.predicate = NSPredicate(format: "id=%d", gameInfo["id"] as! Int64)
        if let game = (try? context.fetch(request))?.first{
            print("Object already exists")
            game.name = gameInfo["name"] as? String
            game.status = gameInfo["status"] as? String
            game.pictureURL = gameInfo["game_picture"] as? String
            return game
        }
        else{
            let game = Game(context: context)
            game.id = gameInfo["id"] as! Int64!
            game.name = gameInfo["name"] as? String
            game.status = gameInfo["status"] as? String
            game.pictureURL = gameInfo["game_picture"] as? String
            return game
        }
    }
}
