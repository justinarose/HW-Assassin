//
//  PostTableViewCell.swift
//  HW Assassin
//
//  Created by Justin Rose on 4/16/17.
//  Copyright © 2017 James Kanoff. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import Alamofire

class PostTableViewCell: UITableViewCell {
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var postUsernameTitleLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var usernameCaptionLabel: UILabel!
    @IBOutlet weak var viewAllButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var placeholderImage: UIImageView!
    var playerItem: AVPlayerItem?
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var post: Post?
    var vc: UIViewController?
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func viewComments(_ sender: Any) {
        print("View comments selected")
        self.vc?.performSegue(withIdentifier: "displayComments", sender: post)
    }
    @IBAction func like(_ sender: Any) {
        print("Like selected")
        likeButton.isEnabled = false
        
        let token = UserDefaults.standard.value(forKey: "token")!
        
        let headers: HTTPHeaders = [
            "Authorization": "Token \(token)",
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let user = delegate.user
        
        var text = "like"
        
        for l in self.post!.likes!{
            if let li = l as? Like{
                if li.liker!.isEqual(user){
                    text = "unlike"
                }
            }
        }
        
        Alamofire.request("http://hwassassin.hwtechcouncil.com/api/posts/\(post!.id)/\(text)/", method: .post, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{ [unowned self] response in
            debugPrint(response)
            
            if let status = response.response?.statusCode {
                switch(status){
                case 200..<299 :
                    print("Successfully liked post")
                    
                    //to get JSON return value
                    if let result = response.result.value {
                        let JSON = result as! NSDictionary
                        
                        let l = Like.likeWithLikeInfo(JSON as! [String : Any], inManageObjectContext: AppDelegate.viewContext)
                        
                        if(text == "unlike"){
                            AppDelegate.viewContext.delete(l)
                            AppDelegate.saveViewContext()
                        }
                        
                        let likeCount = String(describing: self.post!.likes!.count)
                        if self.post!.likes!.count != 1 {
                            self.likesLabel.text = likeCount + " " + "Likes"
                        }
                        else{
                            self.likesLabel.text = "1 Like"
                        }
                    }
                default:
                    print("Error with response status: \(status)")
                }
            }
            
            self.likeButton.isEnabled = true
            
        }
    }
    
    @IBAction func comment(_ sender: Any) {
        print("Comment selected")
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
