//
//  CommentViewController.swift
//  HW Assassin
//
//  Created by Justin Rose on 5/7/17.
//  Copyright © 2017 James Kanoff. All rights reserved.
//

import UIKit
import CoreData
import Alamofire

class CommentTableViewCell: UITableViewCell{
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var commentField: UILabel!
    @IBOutlet weak var timeAgoField: UILabel!
}

class CommentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var keyboardHeightLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var containerView: UIView!
    var fetchedResultsController: NSFetchedResultsController<Comment>?
    var post: Post?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let p = self.post{
            let headers = ["Content-Type": "application/json"]
            
            Alamofire.request("http://hwassassin.hwtechcouncil.com/api/comments/?post=\(p.id)", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{ response in
                debugPrint(response)
                
                //to get JSON return value
                if let result = response.result.value {
                    let JSON = result as! NSArray
                    print("Response JSON: \(JSON)")
                    
                    for c in JSON as! [[String: AnyObject]]{
                        Comment.commentWithCommentInfo(c, inManageObjectContext: AppDelegate.viewContext)
                    }
                    
                    print("Created comments")
                }
            }
            let request: NSFetchRequest<Comment> = Comment.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
            request.predicate = NSPredicate(format: "post=%@", p)
            fetchedResultsController = NSFetchedResultsController<Comment>(fetchRequest: request, managedObjectContext: AppDelegate.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            
            fetchedResultsController?.delegate = self
            
            do{
                try fetchedResultsController?.performFetch()
            }
            catch let error{
                print("Caught error \(error)")
            }
        }

        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 70.0
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        tableView.reloadData()
    }
    
    @IBAction func postButtonPressed(_ sender: Any) {
        let token = UserDefaults.standard.value(forKey: "token")!
        
        let headers: HTTPHeaders = [
            "Authorization": "Token \(token)",
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        let parameters: Parameters = [
            "post": post!.id,
            "text": self.textField.text!
        ]
        
        
        Alamofire.request("http://hwassassin.hwtechcouncil.com/api/comments/", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON{ [unowned self] response in
            debugPrint(response)
            
            if let status = response.response?.statusCode {
                switch(status){
                case 200..<299 :
                    print("Successfully liked post")
                    
                    //to get JSON return value
                    if let result = response.result.value {
                        let JSON = result as! NSDictionary
                        
                        Comment.commentWithCommentInfo(JSON as! [String : Any], inManageObjectContext: AppDelegate.viewContext)
                        
                        self.textField.text = ""
                        
                    }
                default:
                    print("Error with response status: \(status)")
                }
            }
            self.view.endEditing(true)
        }
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
                self.keyboardHeightLayoutConstraint?.constant = 0.0
            } else {
                if let endFrameHeight = endFrame?.size.height, let tabHeight = self.tabBarController?.tabBar.frame.size.height{
                    self.keyboardHeightLayoutConstraint?.constant = endFrameHeight-tabHeight
                }
                else{
                    self.keyboardHeightLayoutConstraint?.constant = 0.0
                }
            }
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController?.sections, sections.count>0 {
            return sections[section].numberOfObjects
        }
        else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "comment_cell", for: indexPath) as! CommentTableViewCell
        
        if let obj = fetchedResultsController?.object(at: indexPath){
            cell.commentField.text = obj.commenter!.firstName! + " " + obj.commenter!.lastName! + "  " + obj.text!
            
            if let tc = obj.time{
                cell.timeAgoField.text = timeAgoSinceDate(date: tc, numericDates: false)
            }
            
            if let data = AppDelegate.cache.object(forKey: (obj.commenter?.profilePictureURL)! as NSString){
                print("Using Cache")
                let image = UIImage(data: data as Data)
                cell.profileImage.image = image
            }
            else{
                Alamofire.request((obj.commenter?.profilePictureURL)!).responseData{ response in
                    debugPrint(response)
                    
                    if let data = response.result.value, let image = UIImage(data: data) {
                        AppDelegate.cache.setObject(data as NSData, forKey: (obj.commenter?.profilePictureURL)! as NSString)
                        cell.profileImage.image = image
                    }
                }
            }
        }
        
        return cell
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert: tableView.insertSections([sectionIndex], with: .fade)
        case .delete: tableView.deleteSections([sectionIndex], with: .fade)
        default:break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type{
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    // MARK: - Helper functions
    func timeAgoSinceDate(date:NSDate, numericDates:Bool) -> String {
        let calendar = NSCalendar.current
        let unitFlags: Set<Calendar.Component> = [.minute, .hour, .day, .weekOfYear, .month, .year, .second]
        let now = NSDate()
        let earliest = now.earlierDate(date as Date)
        let latest = (earliest == now as Date) ? date : now
        let components = calendar.dateComponents(unitFlags, from: earliest as Date,  to: latest as Date)
        
        if (components.year! >= 2) {
            return "\(components.year!) years ago"
        } else if (components.year! >= 1){
            if (numericDates){
                return "1 year ago"
            } else {
                return "Last year"
            }
        } else if (components.month! >= 2) {
            return "\(components.month!) months ago"
        } else if (components.month! >= 1){
            if (numericDates){
                return "1 month ago"
            } else {
                return "Last month"
            }
        } else if (components.weekOfYear! >= 2) {
            return "\(components.weekOfYear!) weeks ago"
        } else if (components.weekOfYear! >= 1){
            if (numericDates){
                return "1 week ago"
            } else {
                return "Last week"
            }
        } else if (components.day! >= 2) {
            return "\(components.day!) days ago"
        } else if (components.day! >= 1){
            if (numericDates){
                return "1 day ago"
            } else {
                return "Yesterday"
            }
        } else if (components.hour! >= 2) {
            return "\(components.hour!) hours ago"
        } else if (components.hour! >= 1){
            if (numericDates){
                return "1 hour ago"
            } else {
                return "An hour ago"
            }
        } else if (components.minute! >= 2) {
            return "\(components.minute!) minutes ago"
        } else if (components.minute! >= 1){
            if (numericDates){
                return "1 minute ago"
            } else {
                return "A minute ago"
            }
        } else if (components.second! >= 3) {
            return "\(components.second!) seconds ago"
        } else {
            return "Just now"
        }
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
