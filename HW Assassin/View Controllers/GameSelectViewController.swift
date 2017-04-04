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

class GameSelectViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let headers = ["Content-Type": "application/json"]
        
        Alamofire.request("http://hwassassin.hwtechcouncil.com/api/games/", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{ [unowned self] response in
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
            }
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    
    // MARK: - UITableViewDelegate
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
