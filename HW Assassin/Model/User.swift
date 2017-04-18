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
}
