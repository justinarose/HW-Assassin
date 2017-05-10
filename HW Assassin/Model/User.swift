//
//  User.swift
//  HW Assassin
//
//  Created by Justin Rose on 4/3/17.
//  Copyright © 2017 James Kanoff. All rights reserved.
//

import UIKit
import CoreData

class User: NSManagedObject {
    
    @discardableResult
    class func userWithUserInfo(_ userInfo:[String:Any], inManageObjectContext context: NSManagedObjectContext) -> User
    {
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "id=%d", userInfo["id"] as! Int64)
        if let user = (try? context.fetch(request))?.first{
            print("Object already exists")
            return user
        }
        else{
            let user = User(context: context)
            user.id = userInfo["id"] as! Int64
            user.firstName = userInfo["first_name"] as! String?
            user.lastName = userInfo["last_name"] as! String?
            user.email = userInfo["email"] as! String?
            user.username = userInfo["username"] as! String?
            user.profilePictureURL = (userInfo["player"] as! NSDictionary)["profile_picture"] as! String?
            user.year = (userInfo["player"] as! NSDictionary)["year"] as! String?
            return user
        }
    }
    
    class func calculateRankInContext(_ context:NSManagedObjectContext){
        let request: NSFetchRequest<User> = User.fetchRequest()
        
        var rank = 1
        var count = 1
        var prevKills = -1
        
        if let us = (try? context.fetch(request)){
            let users = us.sorted(by: { (u1, u2) -> Bool in
                var c1 = 0
                var c2 = 0
                if let p1 = u1.posts{
                    c1 = p1.count
                }
                if let p2 = u2.posts{
                    c2 = p2.count
                }
                
                return c1>c2
            })
            for u in users{
                var kills = 0
                
                if let p = u.posts{
                    kills = p.count
                }
                
                if prevKills == -1{
                    u.rank = Int64(rank)
                    prevKills = kills
                }
                else if kills == prevKills{
                    u.rank = Int64(rank)
                }
                else{
                    rank = count
                    prevKills = kills
                    u.rank = Int64(rank)
                }
                count += 1
            }
        }
    }
    
}
