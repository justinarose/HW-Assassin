//
//  Like.swift
//  HW Assassin
//
//  Created by Justin Rose on 4/3/17.
//  Copyright © 2017 James Kanoff. All rights reserved.
//

import UIKit
import CoreData

class Like: NSManagedObject {
    @discardableResult
    class func likeWithLikeInfo(_ likeInfo:[String:Any], inManageObjectContext context: NSManagedObjectContext) -> Like
    {
        let request: NSFetchRequest<Like> = Like.fetchRequest()
        request.predicate = NSPredicate(format: "id=%d", likeInfo["id"] as! Int64)
        if let l = (try? context.fetch(request))?.first{
            print("Object already exists")
            return l
        }
        else{
            let like = Like(context: context)
            like.id = likeInfo["id"] as! Int64!
            
            let userRequest: NSFetchRequest<User> = User.fetchRequest()
            userRequest.predicate = NSPredicate(format: "id=%d", likeInfo["liker"] as! Int64!)
            if let user = (try? context.fetch(userRequest))?.first{
                like.liker = user
            }
            
            let postRequest: NSFetchRequest<Post> = Post.fetchRequest()
            postRequest.predicate = NSPredicate(format: "id=%d", likeInfo["post"] as! Int64!)
            if let post = (try? context.fetch(postRequest))?.first{
                like.post = post
            }
            
            return like
        }
    }
}
