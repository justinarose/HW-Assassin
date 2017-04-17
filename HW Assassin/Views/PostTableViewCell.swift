//
//  PostTableViewCell.swift
//  HW Assassin
//
//  Created by Justin Rose on 4/16/17.
//  Copyright © 2017 James Kanoff. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var postUsernameTitleLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var usernameCaptionLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var viewAllLabel: UIButton!
    @IBOutlet weak var usernameCommentLabel: UIButton!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
