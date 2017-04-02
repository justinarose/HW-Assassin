//
//  LoginViewController.swift
//  HW Assassin
//
//  Created by Justin Rose on 3/27/17.
//  Copyright © 2017 James Kanoff. All rights reserved.
//

import UIKit
import Alamofire

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func loginButtonPressed(_ sender: Any) {
        let parameters = ["username":usernameTextField.text,
                          "password":passwordTextField.text]
        
        let headers = ["Content-Type": "application/json"]
        
        Alamofire.request("http://hwassassin.hwtechcouncil.com/api-token-auth/", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON{ [unowned self] response in
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
                let JSON = result as! NSDictionary
                
                print("Response JSON: \(JSON)")
                print("Token:  \(JSON["token"])")
                self.performSegue(withIdentifier: "goToGameSelection", sender: sender)
                
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