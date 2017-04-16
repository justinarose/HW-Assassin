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
    @IBOutlet weak var badgesCountLabel: UILabel!
    @IBOutlet weak var rankCountLabel: UILabel!
}


class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    var fetchedResultsController: NSFetchedResultsController<Post>?
    var userAccount: User?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if userAccount == nil {
            let u = User(context: AppDelegate.viewContext)
            let dict = UserDefaults.standard.value(forKey: "user") as! [String: Any]
            u.id = dict["id"] as! Int64
            u.firstName = dict["first_name"] as! String?
            u.lastName = dict["last_name"] as! String?
            u.email = dict["email"] as! String?
            u.username = dict["username"] as! String?
            u.profilePictureURL = (dict["player"] as! NSDictionary)["profile_picture"] as! String?
            u.year = (dict["player"] as! NSDictionary)["year"] as! String?
            userAccount = u
        }
        
        tableView.separatorStyle = .none
        
        self.title = (userAccount?.username)!
        
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
        if section == 1{
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
        
        if indexPath.section == 1 {
            let c = tableView.dequeueReusableCell(withIdentifier: "profile_cell", for: indexPath) as! ProfileTableViewCell
            c.nameLabel.text = (userAccount?.firstName)! + " " + (userAccount?.lastName)!
            c.killCountLabel.text = "0"
            c.badgesCountLabel.text = "0"
            c.rankCountLabel.text = "0"
            Alamofire.request((userAccount?.profilePictureURL)!).responseData{ response in
                debugPrint(response)
                
                if let data = response.result.value, let image = UIImage(data: data) {
                    c.profileImageView.image = image
                }
            }
            cell = c
        }
        else{
            cell = UITableViewCell()
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
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
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
