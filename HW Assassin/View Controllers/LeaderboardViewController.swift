//
//  LeaderboardViewController.swift
//  HW Assassin
//
//  Created by Justin Rose on 5/9/17.
//  Copyright © 2017 James Kanoff. All rights reserved.
//

import UIKit
import CoreData
import Alamofire

class GameStatusTableViewCell: UITableViewCell{
    @IBOutlet weak var gameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var fractionAliveLabel: UILabel!
    var greenSubview: UIView?
    var redSubview: UIView?
    
}

class UserLeaderboardTableViewCell: UITableViewCell{
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userButton: UIButton!
    var vc: UIViewController?
    
    @IBAction func userButtonPressed(_ sender: Any) {
    }
}

class LeaderboardViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    var fetchedResultsController: NSFetchedResultsController<User>?
    var g: Game?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let dict = UserDefaults.standard.value(forKey: "status") as! [String: Any]
        let gameId = dict["game"] as! Int64
        
        let gameRequest: NSFetchRequest<Game> = Game.fetchRequest()
        gameRequest.predicate = NSPredicate(format: "id=%d", gameId)
        if let game = (try? AppDelegate.viewContext.fetch(gameRequest))?.first{
            self.g = game
        }
        
        User.calculateRankInContext(AppDelegate.viewContext)
        
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "rank", ascending: true)]
        //request.fetchLimit = 20
        
        fetchedResultsController = NSFetchedResultsController<User>(fetchRequest: request, managedObjectContext: AppDelegate.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController?.delegate = self
        
        do{
            try fetchedResultsController?.performFetch()
        }
        catch let error{
            print("Caught error \(error)")
        }
        
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

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
        
        print(String(describing:indexPath))
        
        if indexPath.section == 0 {
            let c = tableView.dequeueReusableCell(withIdentifier: "game_status_cell", for: indexPath) as! GameStatusTableViewCell
            
            if let game = self.g{
                c.gameLabel.text = game.name
                
                switch(game.status!){
                case "r":
                    c.statusLabel.text = "Registration"
                case "p":
                    c.statusLabel.text = "In Progress"
                case "c":
                    c.statusLabel.text = "Complete"
                default:
                    c.statusLabel.text = "Error"
                }
                
                var count = 0
                var alive = 0
                
                for s in game.statuses!{
                    count += 1
                    if let stat = s as? UserGameStatus{
                        if stat.status == "a"{
                            alive += 1
                        }
                    }
                }
                
                c.fractionAliveLabel.text = "\(alive)/\(count) Alive"
                
                if c.greenSubview == nil{
                    c.greenSubview = UIView()
                    c.greenSubview?.backgroundColor = UIColor.green
                    c.progressView.addSubview(c.greenSubview!)
                }
                
                if c.redSubview == nil{
                    c.redSubview = UIView()
                    c.redSubview?.backgroundColor = UIColor.red
                    c.progressView.addSubview(c.redSubview!)
                }
                
                let totalWidth = c.progressView.frame.width
                let greenWidth = totalWidth*CGFloat(alive)/CGFloat(count)
                let redWidth = totalWidth-greenWidth
                let height = c.progressView.frame.height
                
                if count != 0{
                    c.greenSubview?.frame = CGRect(x: 0, y: 0, width: greenWidth, height: height)
                    c.redSubview?.frame = CGRect(x: greenWidth, y: 0, width: redWidth, height: height)
                }
                
            }
            cell = c
        }
        else{
            let newerIndexPath = IndexPath(row: indexPath.row, section: indexPath.section-1)
            let c = tableView.dequeueReusableCell(withIdentifier: "user_leaderboard_cell", for: indexPath) as! UserLeaderboardTableViewCell
            
            if let obj = fetchedResultsController?.object(at: newerIndexPath){
                
                c.rankLabel.text = String(obj.rank)
                
                let name = obj.firstName! + " " + obj.lastName!
                let year = "Class " + obj.year!
                let text = name + " - " + year
                
                c.userButton.setTitle(text, for: .normal)
                
                if let data = AppDelegate.cache.object(forKey: obj.profilePictureURL! as NSString){
                    //print("Using Cache")
                    let image = UIImage(data: data as Data)
                    c.profileImageView.image = image
                }
                else{
                    Alamofire.request(obj.profilePictureURL!).responseData{[unowned c] response in
                        debugPrint(response)
                        
                        if let data = response.result.value, let image = UIImage(data: data) {
                            AppDelegate.cache.setObject(data as NSData, forKey: obj.profilePictureURL! as NSString)
                            c.profileImageView.image = image
                        }
                    }
                }
                
            }
            
            cell = c
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
            tableView.reloadRows(at: [updatedIndexPath], with: .fade)
        case .move:
            tableView.deleteRows(at: [updatedIndexPath], with: .fade)
            tableView.insertRows(at: [updatedNewIndexPath], with: .fade)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
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