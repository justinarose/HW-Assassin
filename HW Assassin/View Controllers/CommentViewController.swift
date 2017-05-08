//
//  CommentViewController.swift
//  HW Assassin
//
//  Created by Justin Rose on 5/7/17.
//  Copyright © 2017 James Kanoff. All rights reserved.
//

import UIKit
import CoreData
import Alamofire

class CommentTableViewCell: UITableViewCell{
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var commentField: UILabel!
    @IBOutlet weak var timeAgoField: UILabel!
}

class CommentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var keyboardHeightLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var containerView: UIView!
    var fetchedResultsController: NSFetchedResultsController<Comment>?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 70.0
        tableView.allowsSelection = false
        tableView.reloadData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
                self.keyboardHeightLayoutConstraint?.constant = 0.0
            } else {
                if let endFrameHeight = endFrame?.size.height, let tabHeight = self.tabBarController?.tabBar.frame.size.height{
                    self.keyboardHeightLayoutConstraint?.constant = endFrameHeight-tabHeight
                }
                else{
                    self.keyboardHeightLayoutConstraint?.constant = 0.0
                }
            }
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            return 12
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "comment_cell", for: indexPath) as! CommentTableViewCell
        
        let r = indexPath.row
        
        if r % 3 == 0{
            cell.commentField.text = "Justin Rose This is a short comment :)"
        }
        else if r % 3 == 1{
            cell.commentField.text = "Justin Rose This is a medium sized comment. This comment might span to be a couple of lines."
        }
        else{
            cell.commentField.text = "Justin Rose This is a large comment. It has a lot of text because clearly this person had quite a lot to say about this post. Maybe they were the person who was killed. Maybe they were the person who killed them. Who knows. All that can be sure is that this is a very long comment"
        }
        
        return cell
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
