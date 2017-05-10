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
import AVFoundation
import AVKit


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
    var isDeviceUser: Bool = false
    var heightAtIndexPath = NSMutableDictionary()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if userAccount == nil {
            let dict = UserDefaults.standard.value(forKey: "user") as! [String: Any]
            userAccount = User.userWithUserInfo(dict, inManageObjectContext: AppDelegate.viewContext)
            self.isDeviceUser = true
        }
        
        self.status = (userAccount?.statuses?.anyObject() as! UserGameStatus)
        
        let request: NSFetchRequest<Post> = Post.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        request.predicate = NSPredicate(format: "poster=%@", userAccount!)
        fetchedResultsController = NSFetchedResultsController<Post>(fetchRequest: request, managedObjectContext: AppDelegate.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
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
        self.tableView.setNeedsLayout()
        self.tableView.layoutIfNeeded()
        
        self.title = (userAccount?.username)!
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        for c in tableView.visibleCells{
            if let pc = c as? PostTableViewCell{
                pc.player?.pause()
                print("View will disappear pausing")
            }
        }
        
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        let count = fetchedResultsController?.sections?.count ?? 1
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
                postCell.vc = self
                postCell.post = obj
                
                postCell.postUsernameTitleLabel.text = (obj.poster?.firstName)! + " " + (obj.poster?.lastName)!
                postCell.usernameCaptionLabel.text = postCell.postUsernameTitleLabel.text! + "  " + obj.caption!
                postCell.rankLabel.text = "Rank " + String(describing: obj.poster!.rank)
                
                //NOTE location label is actually to display who was killed; should change, but not enough time
                postCell.locationLabel.text = "Killed " + (obj.killed?.firstName)! + " " + (obj.killed?.lastName)!
                
                let likeCount = String(describing: obj.likes!.count)
                if obj.likes!.count != 1 {
                    postCell.likesLabel.text = likeCount + " " + "Likes"
                }
                else{
                    postCell.likesLabel.text = "1 Like"
                }
                
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
                
                if let tc = obj.timeConfirmed{
                    postCell.timeLabel.text = timeAgoSinceDate(date: tc, numericDates: false)
                }
                
                if let data = AppDelegate.cache.object(forKey: (obj.postThumbnailURL)! as NSString){
                    //print("Using Cache")
                    let image = UIImage(data: data as Data)
                    postCell.placeholderImage.image = image
                }
                else{
                    Alamofire.request((obj.postThumbnailURL)!).responseData{[unowned postCell] response in
                        debugPrint(response)
                        
                        if let data = response.result.value, let image = UIImage(data: data) {
                            AppDelegate.cache.setObject(data as NSData, forKey: (obj.postThumbnailURL)! as NSString)
                            postCell.placeholderImage.image = image
                        }
                    }
                }
                if let data = AppDelegate.cache.object(forKey: (obj.poster?.profilePictureURL)! as NSString){
                    //print("Using Cache")
                    let image = UIImage(data: data as Data)
                    postCell.profileImageView.image = image
                }
                else{
                    Alamofire.request((obj.poster?.profilePictureURL)!).responseData{[unowned postCell] response in
                        debugPrint(response)
                        
                        if let data = response.result.value, let image = UIImage(data: data) {
                            AppDelegate.cache.setObject(data as NSData, forKey: (obj.poster?.profilePictureURL)! as NSString)
                            postCell.profileImageView.image = image
                        }
                    }
                }
                
                DispatchQueue.global().async {[unowned postCell] in
                    postCell.playerItem = AVPlayerItem(url: URL(string: obj.postVideoURL!)!)
                    DispatchQueue.main.async {
                        
                        if let l = postCell.playerLayer{
                            l.removeFromSuperlayer()
                        }
                        if let p = postCell.player{
                            p.pause()
                        }
                        
                        postCell.player = AVPlayer(playerItem: postCell.playerItem)
                        postCell.playerLayer = AVPlayerLayer(player: postCell.player)
                        postCell.playerLayer?.videoGravity = AVLayerVideoGravityResize
                        postCell.playerLayer?.frame = postCell.videoView.bounds
                        
                        
                        postCell.bringSubview(toFront: postCell.videoView)
                        postCell.placeholderImage.isHidden = true
                        postCell.videoView.layer.addSublayer(postCell.playerLayer!)
                        
                        //causes to crash for some reason; initial video will only play when scroll
                        /*if(self.cellIsVisible(cell)){
                         cell.player?.play()
                         }*/
                        
                        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: postCell.player?.currentItem, queue: nil, using: { (_) in
                            DispatchQueue.main.async {
                                postCell.player?.seek(to: kCMTimeZero)
                                postCell.player?.play()
                            }
                        })
                        
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
        var updatedIndexPath : IndexPath = IndexPath()
        var updatedNewIndexPath : IndexPath = IndexPath()
        
        if let p = indexPath{
            updatedIndexPath = IndexPath(row: p.row, section: p.section+1)
        }
        if let ip = newIndexPath{
            updatedNewIndexPath = IndexPath(row: ip.row, section: ip.section+1)
        }
        
        switch type{
        case .insert:
            tableView.insertRows(at: [updatedNewIndexPath], with: .fade)
        case .delete:
            tableView.deleteRows(at: [updatedIndexPath], with: .fade)
        case .update:
            print("Update")
            //tableView.reloadRows(at: [updatedIndexPath], with: .fade)
        case .move:
            tableView.deleteRows(at: [updatedIndexPath], with: .fade)
            tableView.insertRows(at: [updatedNewIndexPath], with: .fade)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.section == 0){
            return 138.0
        }
        else{
            if let height = heightAtIndexPath.object(forKey: indexPath) as? NSNumber {
                print(height.floatValue)
                return CGFloat(height.floatValue)
            } else {
                return 750.0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let height = NSNumber(value: Float(cell.frame.size.height))
        heightAtIndexPath.setObject(height, forKey: indexPath as NSCopying)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        for c in self.tableView.visibleCells{
            if let pc = c as? PostTableViewCell{
                let visible = self.cellIsVisible(pc)
                let vcVisible = self.navigationController?.visibleViewController == self
            
                if(visible && vcVisible){
                    pc.player?.play()
                }
                else{
                    pc.player?.pause()
                }
            }
            
        }
    }
    
    func cellIsVisible(_ cell: UITableViewCell) -> Bool {
        let indexPath = self.tableView.indexPath(for: cell)
        let cellRect = self.tableView.rectForRow(at: indexPath!)
        let superView = self.tableView.superview!
        
        let convertedRect = self.tableView.convert(cellRect, to: superView)
        let intersect = convertedRect.intersection(self.tableView.frame)
        let height = intersect.height
        
        if(height > 0.6 * cell.frame.height){
            return true
        }
        else{
            return false
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
