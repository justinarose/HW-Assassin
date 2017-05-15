//
//  FeedViewController.swift
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

class FeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
    @IBOutlet weak var tableView: UITableView!
    var fetchedResultsController: NSFetchedResultsController<Post>?
    var heightAtIndexPath = NSMutableDictionary()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let dict = UserDefaults.standard.value(forKey: "status") as! [String: Any]
        let game = dict["game"] as! Int64
        let headers = ["Content-Type": "application/json"]
        
        
        Alamofire.request("https://hwassassin.hwtechcouncil.com/api/users/", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{ response in
            debugPrint(response)
            
            //to get JSON return value
            if let result = response.result.value {
                let JSON = result as! NSArray
                
                for u in JSON as! [[String: AnyObject]]{
                    User.userWithUserInfo(u, inManageObjectContext: AppDelegate.viewContext)
                }
                
                print("Created users")
                
                Alamofire.request("https://hwassassin.hwtechcouncil.com/api/posts/?game=\(game)&status=v", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{ response in
                    debugPrint(response)
                    
                    //to get JSON return value
                    if let result = response.result.value {
                        let JSON = result as! NSArray
                        
                        for p in JSON as! [[String: AnyObject]]{
                            Post.postWithPostInfo(p, inManageObjectContext: AppDelegate.viewContext)
                        }
                        
                        print("Created posts")
                        
                        User.calculateRankInContext(AppDelegate.viewContext)
                        
                        Alamofire.request("https://hwassassin.hwtechcouncil.com/api/likes/", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{ response in
                            debugPrint(response)
                            if let result = response.result.value {
                                let JSON = result as! NSArray
                                
                                for l in JSON as! [[String: AnyObject]]{
                                    Like.likeWithLikeInfo(l, inManageObjectContext: AppDelegate.viewContext)
                                }
                                
                                print("Created likes")
                            }
                        }
                        Alamofire.request("https://hwassassin.hwtechcouncil.com/api/comments/", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{ response in
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
                    }
                }
            }
        }
        
        let request: NSFetchRequest<Post> = Post.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        fetchedResultsController = NSFetchedResultsController<Post>(fetchRequest: request, managedObjectContext: AppDelegate.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController?.delegate = self
        AppDelegate.saveViewContext()
        
        do{
            try fetchedResultsController?.performFetch()
        }
        catch let error{
            print("Caught error \(error)")
        }
        
        tableView.register(UINib(nibName:"PostTableViewCell", bundle:nil), forCellReuseIdentifier: "post_cell")
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.allowsSelection = false
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
        tableView.reloadData()
        self.tableView.setNeedsLayout()
        self.tableView.layoutIfNeeded()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let dict = UserDefaults.standard.value(forKey: "status") as! [String: Any]
        let game = dict["game"] as! Int64
        let headers = ["Content-Type": "application/json"]
        
        Alamofire.request("https://hwassassin.hwtechcouncil.com/api/posts/?game=\(game)&status=v", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{ [unowned self] response in
            debugPrint(response)
            
            //to get JSON return value
            if let result = response.result.value {
                let JSON = result as! NSArray
                
                for p in JSON as! [[String: AnyObject]]{
                    Post.postWithPostInfo(p, inManageObjectContext: AppDelegate.viewContext)
                }
                
                print("Created posts")
                let user = (UIApplication.shared.delegate as! AppDelegate).user
                
                if user != nil{
                    Alamofire.request("https://hwassassin.hwtechcouncil.com/api/posts/?killed=\(user!.id)&game=\(game)&status=p").responseJSON{ response in
                        debugPrint(response)
                        
                        if let result = response.result.value{
                            let JSON = result as! NSArray
                            print("Response JSON: \(JSON)")
                            
                            if JSON.count > 0 {
                                let postDict = JSON.firstObject!
                                let post = Post.postWithPostInfo(postDict as! [String : Any], inManageObjectContext: AppDelegate.viewContext)
                                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                let vc : VerifyKillViewController = mainStoryboard.instantiateViewController(withIdentifier: "verify_kill_vc") as! VerifyKillViewController
                                vc.post = post
                                self.present(vc, animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    func refresh(sender: UIRefreshControl) {
        let dict = UserDefaults.standard.value(forKey: "status") as! [String: Any]
        let game = dict["game"] as! Int64
        let headers = ["Content-Type": "application/json"]
        
        Alamofire.request("https://hwassassin.hwtechcouncil.com/api/posts/?game=\(game)&status=v", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{ response in
            debugPrint(response)
            sender.endRefreshing()
            //to get JSON return value
            if let result = response.result.value {
                let JSON = result as! NSArray
                
                for p in JSON as! [[String: AnyObject]]{
                    Post.postWithPostInfo(p, inManageObjectContext: AppDelegate.viewContext)
                }
                
                print("Created posts")
                
                User.calculateRankInContext(AppDelegate.viewContext)
                
                Alamofire.request("https://hwassassin.hwtechcouncil.com/api/likes/", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{ response in
                    debugPrint(response)
                    if let result = response.result.value {
                        let JSON = result as! NSArray
                        
                        for l in JSON as! [[String: AnyObject]]{
                            Like.likeWithLikeInfo(l, inManageObjectContext: AppDelegate.viewContext)
                        }
                        
                        print("Created likes")
                    }
                }
                Alamofire.request("https://hwassassin.hwtechcouncil.com/api/comments/", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{ response in
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
            }
        }
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "post_cell", for: indexPath) as! PostTableViewCell
        
        if let obj = fetchedResultsController?.object(at: indexPath){
            cell.vc = self
            cell.post = obj
            
            let postUsernameText = (obj.poster?.firstName)! + " " + (obj.poster?.lastName)!
            cell.postUsernameButton.setTitle(postUsernameText, for: .normal)
            cell.usernameCaptionLabel.text = postUsernameText + "  " + obj.caption!
            cell.rankLabel.text = "Rank " + String(describing: obj.poster!.rank)
            
            let killedUsernameText = "Killed " + (obj.killed?.firstName)! + " " + (obj.killed?.lastName)!
            cell.killedUserButton.setTitle(killedUsernameText, for: .normal)
            
            let likeCount = String(describing: obj.likes!.count)
            if obj.likes!.count != 1 {
                cell.likesLabel.text = likeCount + " " + "Likes"
            }
            else{
                cell.likesLabel.text = "1 Like"
            }
           
            let commentCount = obj.comments!.count
            
            //width of button might be weird
            if commentCount == 0{
                cell.viewAllButton.setTitle("Add Comment", for: .normal)
            }
            else if commentCount > 1{
                let commentCountString = String(describing: obj.comments!.count)
                cell.viewAllButton.setTitle("View All " + commentCountString + " Comments", for: .normal)
            }
            else{
                cell.viewAllButton.setTitle("View Comment", for: .normal)
            }
            
            if let tc = obj.timeConfirmed{
                cell.timeLabel.text = timeAgoSinceDate(date: tc, numericDates: false)
            }
            
            if let data = AppDelegate.cache.object(forKey: (obj.postThumbnailURL)! as NSString){
                //print("Using Cache")
                let image = UIImage(data: data as Data)
                cell.placeholderImage.image = image
            }
            else{
                Alamofire.request((obj.postThumbnailURL)!).responseData{[unowned cell] response in
                    debugPrint(response)
                    
                    if let data = response.result.value, let image = UIImage(data: data) {
                        AppDelegate.cache.setObject(data as NSData, forKey: (obj.postThumbnailURL)! as NSString)
                        cell.placeholderImage.image = image
                    }
                }
            }
            if let data = AppDelegate.cache.object(forKey: (obj.poster?.profilePictureURL)! as NSString){
                //print("Using Cache")
                let image = UIImage(data: data as Data)
                cell.profileImageView.image = image
            }
            else{
                Alamofire.request((obj.poster?.profilePictureURL)!).responseData{[unowned cell] response in
                    debugPrint(response)
                    
                    if let data = response.result.value, let image = UIImage(data: data) {
                        AppDelegate.cache.setObject(data as NSData, forKey: (obj.poster?.profilePictureURL)! as NSString)
                        cell.profileImageView.image = image
                    }
                }
            }
            
            DispatchQueue.global().async {[unowned cell] in
                cell.playerItem = AVPlayerItem(url: URL(string: obj.postVideoURL!)!)
                DispatchQueue.main.async {
                    
                    if let l = cell.playerLayer{
                        l.removeFromSuperlayer()
                    }
                    if let p = cell.player{
                        p.pause()
                    }
                    
                    cell.player = AVPlayer(playerItem: cell.playerItem)
                    cell.playerLayer = AVPlayerLayer(player: cell.player)
                    cell.playerLayer?.videoGravity = AVLayerVideoGravityResize
                    cell.playerLayer?.frame = cell.videoView.bounds
                    
                    
                    cell.bringSubview(toFront: cell.videoView)
                    cell.placeholderImage.isHidden = true
                    cell.videoView.layer.addSublayer(cell.playerLayer!)
                    
                    //causes to crash for some reason; initial video will only play when scroll
                    /*if(self.cellIsVisible(cell)){
                        cell.player?.play()
                    }*/
                    
                    NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: cell.player?.currentItem, queue: nil, using: { (_) in
                        DispatchQueue.main.async {
                            cell.player?.seek(to: kCMTimeZero)
                            cell.player?.play()
                        }
                    })
                    
                }
            }
            
            
        }
        
        cell.layoutIfNeeded()
        
        return cell
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
        print("Table view doing updates")
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert: tableView.insertSections([sectionIndex], with: .fade)
        case .delete: tableView.deleteSections([sectionIndex], with: .fade)
        default:break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        print("Updating cells")
        switch type{
        case .insert:
            print("Insert cell")
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            print("Deleted cell")
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            print("Update cell")
            //tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            print("Move cell")
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("Ended updates")
        tableView.endUpdates()
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if let height = heightAtIndexPath.object(forKey: indexPath) as? NSNumber {
            print(height.floatValue)
            return CGFloat(height.floatValue)
        } else {
            return 750.0
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let height = NSNumber(value: Float(cell.frame.size.height))
        heightAtIndexPath.setObject(height, forKey: indexPath as NSCopying)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        for c in self.tableView.visibleCells{
            let pc = c as! PostTableViewCell
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
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        for c in tableView.visibleCells{
            if let pc = c as? PostTableViewCell{
                pc.player?.pause()
                print("Pausing")
            }
        }
        
        let vc = segue.destination as! CommentViewController
        vc.post = sender as? Post
    }
    

}
