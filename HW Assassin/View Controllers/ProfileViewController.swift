//
//  ProfileViewController.swift
//  HW Assassin
//
//  Created by Justin Rose on 4/16/17.
//  Copyright © 2017 James Kanoff. All rights reserved.
//

import UIKit
import CoreData
import Alamofire


class ProfileTableViewCell: UITableViewCell{
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var killCountLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var rankCountLabel: UILabel!
    @IBOutlet weak var targetButton: UIButton!
}


class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    var fetchedResultsController: NSFetchedResultsController<Post>?
    var userAccount: User?
    var status: UserGameStatus?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if userAccount == nil {
            let dict = UserDefaults.standard.value(forKey: "user") as! [String: Any]
            userAccount = User.userWithUserInfo(dict, inManageObjectContext: AppDelegate.viewContext)
        }
        
        self.status = (userAccount?.statuses?.anyObject() as! UserGameStatus)
        
        let request: NSFetchRequest<Post> = Post.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        request.predicate = NSPredicate(format: "poster=%@", userAccount!)
        fetchedResultsController = NSFetchedResultsController<Post>(fetchRequest: request, managedObjectContext: AppDelegate.viewContext, sectionNameKeyPath: nil, cacheName: "UserPostQueryCache")
        
        fetchedResultsController?.delegate = self
        
        do{
            try fetchedResultsController?.performFetch()
        }
        catch let error{
            print("Caught error \(error)")
        }
        
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.register(UINib(nibName:"PostTableViewCell", bundle:nil), forCellReuseIdentifier: "post_cell")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.reloadData()
        
        self.title = (userAccount?.username)!
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        let count = fetchedResultsController?.sections?.count ?? 1
        print("SECTION COUNT---------- \(count+1)")
        return count+1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 1
        }
        else if let sections = fetchedResultsController?.sections, sections.count>0 {
            return sections[section-1].numberOfObjects
        }
        else{
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        
        if indexPath.section == 0 {
            let c = tableView.dequeueReusableCell(withIdentifier: "profile_cell", for: indexPath) as! ProfileTableViewCell
            c.nameLabel.text = (userAccount?.firstName)! + " " + (userAccount?.lastName)!
            c.killCountLabel.text = "0"
            c.yearLabel.text = (userAccount?.year)!
            c.rankCountLabel.text = "0"
            
            
            let targetName = (self.status?.target?.firstName)! + " " + (self.status?.target?.lastName)!
            c.targetButton.setTitle(targetName, for: .normal)
            
            Alamofire.request((userAccount?.profilePictureURL)!).responseData{ response in
                debugPrint(response)
                
                if let data = response.result.value, let image = UIImage(data: data) {
                    c.profileImageView.image = image
                }
            }
            cell = c
        }
        else{
            let newerIndexPath = IndexPath(row: indexPath.row, section: indexPath.section-1)
            let postCell = tableView.dequeueReusableCell(withIdentifier: "post_cell", for: indexPath) as! PostTableViewCell
            if let obj = fetchedResultsController?.object(at: newerIndexPath){
                print(obj)
                postCell.postUsernameTitleLabel.text = (obj.poster?.firstName)! + " " + (obj.poster?.lastName)!
                
                postCell.usernameCaptionLabel.text = postCell.postUsernameTitleLabel.text! + "  " + obj.caption!
                
                let likeCount = String(describing: obj.likes!.count)
                postCell.likesLabel.text = likeCount + " " + "Likes"
                
                let commentCount = obj.comments!.count
                
                //width of button might be weird
                if commentCount == 0{
                    postCell.viewAllButton.setTitle("Add Comment", for: .normal)
                }
                else if commentCount > 1{
                    let commentCountString = String(describing: obj.comments!.count)
                    postCell.viewAllButton.setTitle("View All " + commentCountString + " Comments", for: .normal)
                }
                else{
                    postCell.viewAllButton.setTitle("View Comment", for: .normal)
                }
                
                postCell.timeLabel.text = timeAgoSinceDate(date: obj.timeConfirmed!, numericDates: false)
                
                if let data = AppDelegate.cache.object(forKey: (obj.postThumbnailURL)! as NSString){
                    print("Using Cache")
                    let image = UIImage(data: data as Data)
                    postCell.placeholderImage.image = image
                }
                else{
                    Alamofire.request((obj.postThumbnailURL)!).responseData{ response in
                        debugPrint(response)
                        
                        if let data = response.result.value, let image = UIImage(data: data) {
                            AppDelegate.cache.setObject(data as NSData, forKey: (obj.postThumbnailURL)! as NSString)
                            postCell.placeholderImage.image = image
                        }
                    }
                }
                if let data = AppDelegate.cache.object(forKey: (obj.poster?.profilePictureURL)! as NSString){
                    print("Using Cache")
                    let image = UIImage(data: data as Data)
                    postCell.profileImageView.image = image
                }
                else{
                    Alamofire.request((obj.poster?.profilePictureURL)!).responseData{ response in
                        debugPrint(response)
                        
                        if let data = response.result.value, let image = UIImage(data: data) {
                            AppDelegate.cache.setObject(data as NSData, forKey: (obj.poster?.profilePictureURL)! as NSString)
                            postCell.profileImageView.image = image
                        }
                    }
                }
            }
            cell = postCell
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
        let updatedIndexPath = IndexPath(row: (indexPath?.row)!, section: (indexPath?.section)!+1)
        var updatedNewIndexPath : IndexPath = IndexPath()
        if let ip = newIndexPath{
            updatedNewIndexPath = IndexPath(row: ip.row, section: ip.section+1)
        }
        switch type{
        case .insert:
            tableView.insertRows(at: [updatedNewIndexPath], with: .fade)
        case .delete:
            tableView.deleteRows(at: [updatedIndexPath], with: .fade)
        case .update:
            tableView.reloadRows(at: [updatedIndexPath], with: .fade)
        case .move:
            tableView.deleteRows(at: [updatedIndexPath], with: .fade)
            tableView.insertRows(at: [updatedNewIndexPath], with: .fade)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.section == 0){
            return 150.0
        }
        else{
            return 660.0
        }
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
