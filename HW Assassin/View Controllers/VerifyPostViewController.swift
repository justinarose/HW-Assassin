//
//  VerifyPostViewController.swift
//  HW Assassin
//
//  Created by Justin Rose on 4/23/17.
//  Copyright © 2017 James Kanoff. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire

class VerifyPostViewController: UIViewController {
    
    var url : URL?
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var captionTextField: UITextView!
    var player : AVPlayer?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let videoUrl = self.url{
            captionTextField.layer.borderColor = UIColor.lightGray.cgColor
            captionTextField.layer.borderWidth = 1.0
            self.player = AVPlayer(url: videoUrl)
            let playerLayer = AVPlayerLayer(player: self.player)
            playerLayer.videoGravity = AVLayerVideoGravityResize
            playerLayer.frame = CGRect(x: 0, y: 0, width: self.view.frame.width/2, height: self.view.frame.width/2)
            self.videoView.layer.addSublayer(playerLayer)
            player?.play()
            
            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem, queue: nil, using: { [unowned self] (_) in
                DispatchQueue.main.async {
                    self.player?.seek(to: kCMTimeZero)
                    self.player?.play()
                }
            })
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func postKillPressed(_ sender: Any) {
        let dict = UserDefaults.standard.value(forKey: "status") as! [String: Any]
        let game = dict["game"] as! Int64
        
        let parameters: [String:String] = ["caption": self.captionTextField.text,
                          "game": String(game)]
        
        let token = UserDefaults.standard.value(forKey: "token")!
        
        let headers: HTTPHeaders = [
            "Authorization": "Token \(token)",
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            for (key, value) in parameters {
                multipartFormData.append(value.data(using: .utf8)!, withName: key)
            }
            
            do {
                let asset = AVURLAsset(url: self.url! , options: nil)
                let imgGenerator = AVAssetImageGenerator(asset: asset)
                imgGenerator.appliesPreferredTrackTransform = true
                let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil)
                let thumbnail = UIImage(cgImage: cgImage)
                
                // thumbnail here
                let imageData = UIImagePNGRepresentation(thumbnail)
                multipartFormData.append(imageData!, withName: "post_thumbnail_image", fileName: "post_thumbnail_image.png", mimeType: "image/png")
                
            } catch let error {
                print("*** Error generating thumbnail: \(error.localizedDescription)")
            }
            
            multipartFormData.append(self.url!, withName: "post_video", fileName: "post_video.mp4", mimeType: "video/mp4")
            
        },
                         usingThreshold: UInt64.init(),
                         to: "http://hwassassin.hwtechcouncil.com/api/posts/",
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
                                            print("Successfully submitted kill")
                                            // create the alert
                                            let alert = UIAlertController(title: "Success", message: "Successfully submitted kill", preferredStyle: UIAlertControllerStyle.alert)
                                            
                                            // add an action (button)
                                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default){ action in
                                                self.navigationController?.popViewController(animated: true)
                                            })
                                            
                                            // show the alert
                                            self.present(alert, animated: true, completion: nil)
                                            
                                        default:
                                            print("An error occured")
                                            // create the alert
                                            let alert = UIAlertController(title: "Error", message: "An error occured. Have you already submited a kill for this target?", preferredStyle: UIAlertControllerStyle.alert)
                                            
                                            // add an action (button)
                                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default){ action in
                                                self.navigationController?.popViewController(animated: true)
                                            })
                                            
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
    
    @IBAction func cancelPressed(_ sender: Any) {
        self.navigationController!.popViewController(animated: true)
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
