//
//  Post.swift
//  HW Assassin
//
//  Created by Justin Rose on 4/3/17.
//  Copyright © 2017 James Kanoff. All rights reserved.
//

import UIKit
import CoreData

class Post: NSManagedObject {
    
    @discardableResult
    class func postWithPostInfo(_ postInfo:[String:Any], inManageObjectContext context: NSManagedObjectContext) -> Post
    {
        let request: NSFetchRequest<Post> = Post.fetchRequest()
        request.predicate = NSPredicate(format: "id=%d", postInfo["id"] as! Int64)
        if let post = (try? context.fetch(request))?.first{
            print("Object already exists")
            return post
        }
        else{
            let post = Post(context: context)
            post.id = postInfo["id"] as! Int64!
            post.caption = postInfo["caption"] as? String
            post.postVideoURL = postInfo["post_video"] as? String
            post.postThumbnailURL = postInfo["post_thumbnail_image"] as? String
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            let localDate = formatter.date(from: postInfo["time_confirmed"] as! String)
            
            post.timeConfirmed = localDate as NSDate?//need to fix, but not right now
            
            let posterRequest: NSFetchRequest<User> = User.fetchRequest()
            posterRequest.predicate = NSPredicate(format: "id=%d", postInfo["poster"] as! Int64!)
            if let poster = (try? context.fetch(posterRequest))?.first{
                post.poster = poster
            }
            
            let killedRequest: NSFetchRequest<User> = User.fetchRequest()
            killedRequest.predicate = NSPredicate(format: "id=%d", postInfo["killed"] as! Int64!)
            if let killed = (try? context.fetch(killedRequest))?.first{
                post.killed = killed
            }
            
            return post
        }
    }
}
