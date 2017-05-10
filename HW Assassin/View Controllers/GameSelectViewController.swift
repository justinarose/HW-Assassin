//
//  GameSelectViewController.swift
//  HW Assassin
//
//  Created by Justin Rose on 3/27/17.
//  Copyright © 2017 James Kanoff. All rights reserved.
//

import UIKit
import CoreData
import Alamofire

class GameSelectTableViewCell: UITableViewCell{
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var numPlayersLabel: UILabel!
    @IBOutlet weak var gameImageView: UIImageView!
}

class GameSelectViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    var fetchedResultsController: NSFetchedResultsController<Game>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let headers = ["Content-Type": "application/json"]
        
        Alamofire.request("http://hwassassin.hwtechcouncil.com/api/games/", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{ response in
            debugPrint(response)
            
            if let status = response.response?.statusCode {
                switch(status){
                case 200:
                    print("Successfully logged in")
                default:
                    print("Error with response status: \(status)")
                }
            }
            //to get JSON return value
            if let result = response.result.value {
                let JSON = result as! NSArray
                print("Response JSON: \(JSON)")
                
                for g in JSON as! [[String: AnyObject]]{
                    Game.gameWithGameInfo(g, inManageObjectContext: AppDelegate.viewContext)
                }
                
                print("Created games")
            }
        }
        let request: NSFetchRequest<Game> = Game.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        fetchedResultsController = NSFetchedResultsController<Game>(fetchRequest: request, managedObjectContext: AppDelegate.viewContext, sectionNameKeyPath: nil, cacheName: "GameQueryCache")
        
        fetchedResultsController?.delegate = self
        
        do{
            try fetchedResultsController?.performFetch()
        }
        catch let error{
            print("Caught error \(error)")
        }
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationItem.setHidesBackButton(true, animated: false)
        super.viewDidAppear(animated)
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
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let sections = fetchedResultsController?.sections, sections.count>0 {
            return sections[section].name
        }
        else{
            return nil
        }
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return fetchedResultsController?.sectionIndexTitles
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return fetchedResultsController?.section(forSectionIndexTitle: title, at: index) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "game_select_cell", for: indexPath) as! GameSelectTableViewCell
        
        if let obj = fetchedResultsController?.object(at: indexPath){
            print(obj)
            cell.nameLabel.text = obj.name
            
            switch(obj.status!){
            case "r":
            cell.statusLabel.text = "Registration"
            case "p":
            cell.statusLabel.text = "In Progress"
            case "c":
            cell.statusLabel.text = "Complete"
            default:
            cell.statusLabel.text = "Error"
            }
            
            //temporary
            let count = obj.statuses?.count
            cell.numPlayersLabel.text = "\(String(describing: count!)) players"
            
            Alamofire.request(obj.pictureURL!).responseData{ response in
                debugPrint(response)
                
                if let data = response.result.value, let image = UIImage(data: data) {
                    cell.gameImageView.image = image
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
    
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let obj = fetchedResultsController?.object(at: indexPath){
            switch(obj.status!){
            case "r":
                let alert = UIAlertController(title: "Join game", message: "Would you like to join this game?", preferredStyle: UIAlertControllerStyle.alert)
                
                // add an action (button)
                alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default){ action in
                    print("Selected yes")
                    
                    let token = UserDefaults.standard.value(forKey: "token")!
                    
                    let headers: HTTPHeaders = [
                        "Authorization": "Token \(token)",
                        "Content-Type": "application/json",
                        "Accept": "application/json"
                    ]
                    
                    print(headers)
                    
                    Alamofire.request("http://hwassassin.hwtechcouncil.com/api/games/\(obj.id)/join/", method: .post, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{ [unowned self] response in
                        debugPrint(response)
                        
                        if let status = response.response?.statusCode {
                            switch(status){
                            case 200..<299 :
                                print("Successfully joined game")
                                
                                //to get JSON return value
                                if let result = response.result.value {
                                    let JSON = result as! NSDictionary
                                    
                                    print("Response JSON: \(JSON)")
                                    UserDefaults.standard.set(JSON, forKey:"status")
                                }
                                
                                
                                self.performSegue(withIdentifier: "joinGameSegue", sender: nil)
                            
                            case 409:
                                print("User already joined game")
                                
                                //to get JSON return value
                                if let result = response.result.value {
                                    let JSON = result as! NSDictionary
                                    
                                    print("Response JSON: \(JSON)")
                                    UserDefaults.standard.set(JSON, forKey:"status")
                                }
                                
                                
                                self.performSegue(withIdentifier: "joinGameSegue", sender: nil)
                                
                                
                            default:
                                print("Error with response status: \(status)")
                            }
                        }
                        
                    }
                })
                
                alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: nil))
                
                // show the alert
                self.present(alert, animated: true, completion: nil)
            case "p":
                let alert = UIAlertController(title: "View game", message: "Would you like to view this game in progress?", preferredStyle: UIAlertControllerStyle.alert)
                
                // add an action (button)
                alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default){ action in
                    
                    let headers: HTTPHeaders = [
                        "Content-Type": "application/json",
                        "Accept": "application/json"
                    ]
                    
                    let userId = (UIApplication.shared.delegate as! AppDelegate).user!.id
                    let gameId = obj.id
                    
                    Alamofire.request("http://hwassassin.hwtechcouncil.com/api/statuses/?user=\(userId)&game=\(gameId)", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{ [unowned self] response in
                        debugPrint(response)
                        if let status = response.response?.statusCode {
                            switch(status){
                            case 200..<299 :
                                print("Successfully joined game")
                                
                                //to get JSON return value
                                if let result = response.result.value {
                                    let JSON = result as! NSArray
                                    if(JSON.count > 0){
                                        let dict = JSON[0]
                                        print("Response JSON: \(JSON)")
                                        UserDefaults.standard.set(dict, forKey:"status")
                                    }
                                }
                                
                                self.performSegue(withIdentifier: "joinGameSegue", sender: nil)
                                
                            case 409:
                                print("User already joined game")
                                
                                //to get JSON return value
                                if let result = response.result.value {
                                    let JSON = result as! NSDictionary
                                    
                                    print("Response JSON: \(JSON)")
                                    UserDefaults.standard.set(JSON, forKey:"status")
                                }
                                
                                
                                self.performSegue(withIdentifier: "joinGameSegue", sender: nil)
                                
                                
                            default:
                                print("Error with response status: \(status)")
                            }
                        }
                    }
                    
                    print("Selected yes")
                })
                
                alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: nil))
                
                // show the alert
                self.present(alert, animated: true, completion: nil)
            case "c":
                let alert = UIAlertController(title: "View game", message: "Would you like to view this past game?", preferredStyle: UIAlertControllerStyle.alert)
                
                // add an action (button)
                alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default){ action in
                    print("Selected yes")
                })
                
                alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: nil))
                
                // show the alert
                self.present(alert, animated: true, completion: nil)
            default:
                print("An error occured")
            }
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
