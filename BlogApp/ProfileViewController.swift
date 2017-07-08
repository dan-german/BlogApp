//
//  ProfileViewController.swift
//  BlogApp
//
//  Created by Dan German on 27/06/2017.
//  Copyright © 2017 Dan German. All rights reserved.
//

import Foundation
import UIKit
import ObjectMapper
import FBSDKCoreKit
import Alamofire

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, PostDataProtocol {
    
    
    //MARK: - IBOutlet
    
    @IBOutlet weak var userPostsTableView: UITableView!
    @IBOutlet weak var profilePictureView: UIImageView!
    @IBOutlet weak var postsLabel:         UILabel!
    @IBOutlet weak var postsTableView:     UITableView!
    
    //MARK: - Properties
    
    let USER_POSTS_URL = "http://localhost:3000/api/getpostsby"
    let dateFormatter = DateFormatter()
    
    var UserPosts = [Post]()
    var profileImage: UIImage?
    var imageData: Data?
    var labelTitle: String?
    var userId: String?
    var currentPost: Post?
    var delegate: PostDataProtocol?
    
    //MARK: UIViewController Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    //MARK: UITableViewDataSource Methods
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserPostCell", for: indexPath) as! UserPostCell
        
        let post = UserPosts[indexPath.row]
        
        cell.accessoryType = .disclosureIndicator
        
        cell.titleLabel.text = post.title
        
        var commentTitle = ""
        
        if post.comments.count == 1 {
            commentTitle = "1 comment"
        } else if post.comments.count > 1 {
            commentTitle = String(describing: post.comments.count) + " comments"
        } else {
            commentTitle = "No comments"
        }
        
        cell.commentsLabel.text = commentTitle
        let timestamp = post.timestamp
        cell.timeLabel.text = dateFormatter.timeSince(from: Date.init(timeIntervalSince1970: timestamp!) as NSDate, numericDates: true)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UserPosts.count
    }
    
    //MARK: - Navigation methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "UserPostDetail" {
            
            
            if let postVC = segue.destination as? PostDetailViewController {
                guard let selectedBlogCell = sender as? UserPostCell else {
                    fatalError("Unexpected sender: \(String(describing: sender))")
                }
                
                guard let indexPath = postsTableView.indexPath(for: selectedBlogCell) else {
                    fatalError("The selected cell is not being displayed by the table")
                }
                
                delegate = postVC
                delegate?.passPost(post: UserPosts[indexPath.row])
            }
        }
    }
    
    //MARK: - PostDataProtocol Methods
    
    func passPost(post: Post) {
        currentPost = post
    }
    
    //MARK: - UI
    
    func setupViews() {
        
        postsTableView.tableFooterView = UIView(frame: .zero)
        
        UIHelper.createBorderFor(views: postsTableView)
        UIHelper.makeViewCircular(view: profilePictureView)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.refreshTableView), for: UIControlEvents.valueChanged)
        userPostsTableView.addSubview(refreshControl)
        
        guard let post = currentPost else { return }
        
        postsLabel.text = post.username! + "'s posts:"
        title = post.username
        
        let userId = currentPost?.userId
        
        let facebookProfileUrl = URL(string:"http://graph.facebook.com/\(userId!)/picture?type=large")
        let data = try? Data(contentsOf: facebookProfileUrl!)
        
        if data != nil {
            profilePictureView.image = UIImage(data: data!)
        }
        
        populateUserPostsArray(userId: post.userId!)
    }
    
    func populateUserPostsArray(userId: String) {
        
        do
        {
            let url = URL(string: "http://localhost:3000/api/getpostsby?user_id=\(userId)")
            let jsonData = try Data.init(contentsOf: url!)
            let jsonString = NSString(data: jsonData, encoding: 1)
            
            guard let response = Mapper<Response>().map(JSONString: jsonString! as String) else { return }
            
            self.UserPosts.removeAll()
            
            for post in response.response {
                UserPosts.append(post)
            }
            
            self.refreshTableView(sender: nil)
            
        }
        catch
        {
            NSLog("Failed to retrieve user's posts. \(error)")
        }
    }
    
    func refreshTableView(sender: UIRefreshControl?) {
        
        
        DispatchQueue.global(qos: .userInitiated).async {
            guard let post = self.currentPost else { return }
            self.populateUserPostsArray(userId: post.userId!)
        }
        
        guard let s = sender else { return }
        s.endRefreshing()
    }
    
    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}
