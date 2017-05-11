//
//  SignUpViewController.swift
//  HW Assassin
//
//  Created by Justin Rose on 3/15/17.
//  Copyright © 2017 James Kanoff. All rights reserved.
//

import UIKit
import Alamofire
import CoreData

class SignUpViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordConformationTextField: UITextField!
    @IBOutlet weak var yearTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(SignUpViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard(){
        view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func createAccountPressed(_ sender: Any) {
        if(imageView.image == nil){
            // create the alert
            let alert = UIAlertController(title: "Error", message: "You must choose a profile photo", preferredStyle: UIAlertControllerStyle.alert)
            
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
        }
        else if(usernameTextField.text == nil || usernameTextField.text! == ""){
            let alert = UIAlertController(title: "Error", message: "Username can't be empty", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else if(emailTextField.text == nil || emailTextField.text! == ""){
            let alert = UIAlertController(title: "Error", message: "Email can't be empty", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else if(firstNameTextField.text == nil || firstNameTextField.text! == ""){
            let alert = UIAlertController(title: "Error", message: "First name can't be empty", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else if(lastNameTextField.text == nil || lastNameTextField.text! == ""){
            let alert = UIAlertController(title: "Error", message: "Last name can't be empty", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else if(passwordTextField.text == nil || passwordTextField.text! == ""){
            let alert = UIAlertController(title: "Error", message: "Password can't be empty", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else if(passwordConformationTextField.text == nil || passwordConformationTextField.text! == ""){
            let alert = UIAlertController(title: "Error", message: "Password confirmation can't be empty", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else if(yearTextField.text == nil || yearTextField.text! == ""){
            let alert = UIAlertController(title: "Error", message: "Year can't be empty", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else if(passwordTextField.text! != passwordConformationTextField.text!){
            // create the alert
            let alert = UIAlertController(title: "Error", message: "Passwords must match.", preferredStyle: UIAlertControllerStyle.alert)
            
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
        }
        else{
            let parameters = ["username":usernameTextField.text,
                              "email":emailTextField.text,
                              "first_name":firstNameTextField.text,
                              "last_name":lastNameTextField.text,
                              "password":passwordTextField.text,
                              "player.year":yearTextField.text];
            
            let headers: HTTPHeaders = [
                "Accept": "application/json"
            ]
            
            
            Alamofire.upload(multipartFormData: { multipartFormData in
                for (key, value) in parameters {
                    multipartFormData.append((value?.data(using: .utf8))!, withName: key)
                }
                
                let imageData = UIImagePNGRepresentation(self.imageView.image!)
                multipartFormData.append(imageData!, withName: "player.profile_picture", fileName: "player.profile_picture", mimeType: "image/png")
            },
                             usingThreshold: UInt64.init(),
                             to: "https://hwassassin.hwtechcouncil.com/api/users/",
                             method: .post,
                             headers: headers,
                             encodingCompletion: { [unowned self] encodingResult in
                
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        debugPrint(response)
                        if let status = response.response?.statusCode {
                            switch(status){
                            case 200..<299:
                                print("Successfully signed up in")
                                
                                //to get JSON return value
                                if let result = response.result.value {
                                    let JSON = result as! NSDictionary
                                    
                                    UserDefaults.standard.set(JSON, forKey: "user")
                                    let delegate = UIApplication.shared.delegate as! AppDelegate
                                    delegate.user = User.userWithUserInfo(JSON as! [String : Any], inManageObjectContext: AppDelegate.viewContext)
                                    
                                    print("Response JSON: \(JSON)")
                                    
                                    let loginParameters: Parameters = ["username":self.usernameTextField.text!,
                                                      "password":self.passwordTextField.text!];
                                    
                                
                                    Alamofire.request("https://hwassassin.hwtechcouncil.com/api-token-auth/", method: .post, parameters: loginParameters, encoding: JSONEncoding.default, headers: headers).responseJSON{ [unowned self] response in
                                        debugPrint(response)
                                    
                                        if let status = response.response?.statusCode {
                                            switch(status){
                                            case 200..<299:
                                                print("Successfully logged in")
                                            default:
                                                print("Error with response status: \(status)")
                                            }
                                        }
                                        //to get JSON return value
                                        if let result = response.result.value {
                                            let tokenResponse = result as! NSDictionary
                                        
                                            print("Response JSON: \(tokenResponse)")
                                            print("Token:  \(String(describing: tokenResponse["token"]))")
                                            let defaults = UserDefaults.standard
                                            defaults.set(tokenResponse["token"], forKey: "token")
                                            self.performSegue(withIdentifier: "goToGameSelection", sender: sender)
                                        
                                        }
                                    }
                                    
                                }
                            default:
                                print("Error with response status: \(status)")
                                // create the alert
                                let alert = UIAlertController(title: "Error", message: "There was a server error.", preferredStyle: UIAlertControllerStyle.alert)
                                
                                // add an action (button)
                                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                                
                                // show the alert
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                    }
                case .failure(let encodingError):
                    print(encodingError)
                }
            })
        }
    }
    
    @IBAction func selectProfileImage() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self;
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary;
            imagePicker.allowsEditing = true;
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String :
        Any]) {
        
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            imageView.image = image
        } else if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = image
        } else {
            imageView.image = nil
        }
        
        
        picker.dismiss(animated: true, completion: nil)
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
