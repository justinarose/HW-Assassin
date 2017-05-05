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

class PostTableViewCell: UITableViewCell {
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
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func viewComments(_ sender: Any) {
        print("View comments selected")
    }
    @IBAction func like(_ sender: Any) {
        print("Like selected")
    }
    
    @IBAction func comment(_ sender: Any) {
        print("Comment selected")
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
