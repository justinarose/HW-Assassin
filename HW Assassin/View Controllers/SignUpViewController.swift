//
//  SignUpViewController.swift
//  HW Assassin
//
//  Created by Justin Rose on 3/15/17.
//  Copyright © 2017 James Kanoff. All rights reserved.
//

import UIKit
import Alamofire

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

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func createAccountPressed() {
        if(passwordTextField.text! != passwordConformationTextField.text!){
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
            
            Alamofire.upload(
                multipartFormData: { multipartFormData in
                    for (key, value) in parameters {
                        multipartFormData.append((value?.data(using: .utf8))!, withName: key)
                    }
                    
                    
                    let imageData = UIImagePNGRepresentation(self.imageView.image!)
                    
                    multipartFormData.append(imageData!, withName: "player.profile_picture", fileName: "player.profile_picture", mimeType: "image/png")
            },
                to: "http://hwassassin.hwtechcouncil.com/api/users/",
                encodingCompletion: { encodingResult in
                    switch encodingResult {
                    case .success(let upload, _, _):
                        upload.responseJSON { response in
                            debugPrint(response)
                        }
                        upload.responseString{ response in
                            print("Response String: \(response.result.value)")
                            
                        }
                    case .failure(let encodingError):
                        print(encodingError)
                    }
            }
            )
            /*
            Alamofire.upload(multipartFormData: { multipartFormData in
                if let imageData = UIImageJPEGRepresentation(self.imageView.image!, 1) {
                    multipartFormData.append(imageData, withName: "player.profile_picture", fileName: "profile.png", mimeType: "image/png")
                }
                
                for (key, value) in parameters {
                    multipartFormData.append((value?.data(using: .utf8))!, withName: key)
                }}, to: "http://hwassassin.hwtechcouncil.com/api/users/", method: .post, headers: ["Accept":"application/json"],
                    encodingCompletion: { encodingResult in
                        switch encodingResult {
                        case .success(let upload, _, _):
                            print("The upload was successful");
                            
                            upload.responseJSON{
                                response in
                                print(response.request!) // original URL request
                                print(response.response!) // URL response
                                print(response.data!) // server data
                                print(response.result) // result of response serialization
                                if let JSON = response.result.value
                                {
                                    print("JSON: (JSON)")
                                }
                            
                            }
                            
                            print(upload.response.debugDescription)
                        case .failure(let encodingError):
                            print("There was a failure");
                            print("error:\(encodingError)")
                        }
            });*/
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
