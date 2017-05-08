//
//  Comment.swift
//  HW Assassin
//
//  Created by Justin Rose on 4/3/17.
//  Copyright © 2017 James Kanoff. All rights reserved.
//

import UIKit
import CoreData

class Comment: NSManagedObject {
    @discardableResult
    class func commentWithCommentInfo(_ commentInfo:[String:Any], inManageObjectContext context: NSManagedObjectContext) -> Comment
    {
        let request: NSFetchRequest<Comment> = Comment.fetchRequest()
        request.predicate = NSPredicate(format: "id=%d", commentInfo["id"] as! Int64)
        if let comment = (try? context.fetch(request))?.first{
            print("Object already exists")
            return comment
        }
        else{
            let comment = Comment(context: context)
            comment.id = commentInfo["id"] as! Int64!
            comment.text = commentInfo["text"] as? String
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            let localDate = formatter.date(from: commentInfo["time"] as! String)
            
            comment.time = localDate as NSDate?//need to fix, but not right now
            
            let commenterRequest: NSFetchRequest<User> = User.fetchRequest()
            commenterRequest.predicate = NSPredicate(format: "id=%d", commentInfo["commenter"] as! Int64!)
            if let commenter = (try? context.fetch(commenterRequest))?.first{
                comment.commenter = commenter
            }
            
            let postRequest: NSFetchRequest<Post> = Post.fetchRequest()
            postRequest.predicate = NSPredicate(format: "id=%d", commentInfo["post"] as! Int64!)
            if let post = (try? context.fetch(postRequest))?.first{
                comment.post = post
            }
            
            return comment
        }
    }
}
