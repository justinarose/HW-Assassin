//
//  VerifyKillViewController.swift
//  HW Assassin
//
//  Created by Justin Rose on 4/25/17.
//  Copyright © 2017 James Kanoff. All rights reserved.
//

import UIKit
import Alamofire
import AVFoundation
import AVKit


class VerifyKillViewController: UIViewController {

    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var captionView: UILabel!
    var post: Post?
    var player : AVPlayer?
    var playerLayer : AVPlayerLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let p = post{
            
            let videoUrl = p.postVideoURL
            //let imageUrl = p.postThumbnailURL
            let profileUrl = p.poster?.profilePictureURL
            
            Alamofire.request(profileUrl!).responseData{ [unowned self] response in
                debugPrint(response)
                
                if let data = response.result.value, let image = UIImage(data: data) {
                    self.profileImageView.image = image
                }
            }
            self.player = AVPlayer(url: URL(string: videoUrl!)!)
            self.playerLayer = AVPlayerLayer(player: self.player)
            self.playerLayer?.videoGravity = AVLayerVideoGravityResize
            self.playerLayer?.frame = self.videoView.bounds
            
            self.videoView.layer.addSublayer(self.playerLayer!)
            self.player?.play()

            
            let first = self.post?.poster?.firstName
            let last = self.post?.poster?.lastName
            let caption = self.post?.caption
            
            self.captionView.text = first! + " " + last! + " " + caption!
            
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.playerLayer?.frame = self.videoView.bounds
    }
    
    @IBAction func verifyKill(_ sender: Any) {
        let token = UserDefaults.standard.value(forKey: "token")!
        
        let headers: HTTPHeaders = [
            "Authorization": "Token \(token)",
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        
        Alamofire.request("http://hwassassin.hwtechcouncil.com/api/posts/\(String(describing: (self.post?.id)!))/verify/", method: .post, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{ [unowned self] response in
            if let status = response.response?.statusCode {
                switch(status){
                case 200..<299:
                    print("Successfully verified kill")
                    self.dismiss(animated: true, completion: nil)
                    
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
    }

    @IBAction func contestKill(_ sender: Any) {
        let token = UserDefaults.standard.value(forKey: "token")!
        
        let headers: HTTPHeaders = [
            "Authorization": "Token \(token)",
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        
        Alamofire.request("http://hwassassin.hwtechcouncil.com/api/posts/\(String(describing: (self.post?.id)!))/deny/", method: .post, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{ [unowned self] response in
            debugPrint(response)
            
            if let status = response.response?.statusCode {
                switch(status){
                case 200..<299:
                    print("Successfully denied kill")
                    self.dismiss(animated: true, completion: nil)
                    
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
