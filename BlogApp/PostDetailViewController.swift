//
//  PostViewController.swift
//  BlogApp
//
//  Created by Dan German on 24/06/2017.
//  Copyright © 2017 Dan German. All rights reserved.
//

import Foundation
import UIKit
import FBSDKCoreKit
import Alamofire
import ObjectMapper

class PostDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, PostDataProtocol {
    
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var commentsTableView:   UITableView!
    
    @IBOutlet weak var postContentView:     UITextView!
    @IBOutlet weak var usernameButton:      UIButton!
    @IBOutlet weak var commentButton:       UIButton!
    @IBOutlet weak var visualEffectView:    UIVisualEffectView!
    
    @IBOutlet var      addCommentView:      UIView!
    @IBOutlet weak var commentTextView:     UITextView!
    @IBOutlet weak var saveCommentButton:   UIButton!
    @IBOutlet weak var cancelCommentButton: UIButton!
    
    //MARK: - Properties
    
    var effect: UIVisualEffect!
    
    let GET_POSTS_URL = URL(string: "http://localhost:3000/api/getposts")
    let NEW_COMMENT_URL = "http://localhost:3000/api/newcomment"
    
    var currentPost: Post?
    var delegate: PostDataProtocol?
    
    var commentsArray = [Comment]()
    
    //MARK: -  UIViewController Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        commentsTableView.reloadData()
    }
    
    //MARK: - UITableViewDataSource Methods
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
        cell.commentTextView.text = commentsArray[indexPath.row].text
        
        if !commentsArray.isEmpty {
            let facebookProfileUrl = URL(string:"http://graph.facebook.com/\(commentsArray[indexPath.row].userId!)/picture?type=large")
            let data = try? Data(contentsOf: facebookProfileUrl!)
            
            if data != nil {
                cell.profilePictureView.image = UIImage(data: data!)
            }
        }
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentsArray.count
    }
    
    //MARK: - UITextViewDelegate Methods
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.characters.count
        
        if textView == commentTextView {
            return numberOfChars < 90
        } else {
            return false
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if commentTextView.text.isEmpty {
            saveCommentButton.isEnabled = false
        } else {
            saveCommentButton.isEnabled = true
        }
    }
    
    //MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if segue.identifier == "ProfileDetail" {
            
            if let postVC = segue.destination as? ProfileViewController {
                
                delegate = postVC
                delegate?.passPost(post: currentPost!)
            }
        }
    }
    
    //MARK: - IBAction
    
    @IBAction func commentButtonTapped(_ sender: Any) {
        animateIn()
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        
        
        postNewComment()
        animateOut()
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        animateOut()
    }
    
    //MARK: - PostDataProtocol Methods
    
    func passPost(post: Post) {
        
        
        currentPost = post
        for comment in currentPost!.comments {
            commentsArray.append(comment)
        }
    }
    
    //MARK: - UI
    
    func setupViews() {
        
    
        commentsTableView.tableFooterView = UIView(frame: .zero)
        
        let refreshControl = UIRefreshControl()
        
        refreshControl.addTarget(self, action: #selector(self.refreshTableView), for: UIControlEvents.valueChanged)
        commentsTableView.addSubview(refreshControl)
        
        saveCommentButton.isEnabled = false
        automaticallyAdjustsScrollViewInsets = false
        
        UIHelper.createBorderFor(views: postContentView, usernameButton, commentButton, commentTextView, saveCommentButton, cancelCommentButton, addCommentView)
        
        commentTextView.textContainer.maximumNumberOfLines = 2
        
        addCommentView.layer.cornerRadius = 5
        
        effect = visualEffectView.effect
        visualEffectView.effect = nil
        visualEffectView.isUserInteractionEnabled = false
        
        guard let post = currentPost else { return }
        
        title = post.title
        postContentView.text = post.content
        usernameButton.setTitle(post.username!, for: .normal)
        commentsTableView.reloadData()
    }
    
    func animateIn() {
        
        
        visualEffectView.isUserInteractionEnabled = true
        
        self.view.addSubview(addCommentView)
        addCommentView.center = self.view.center
        
        addCommentView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        addCommentView.alpha = 0
        
        UIView.animate(withDuration: 0.4){
            self.visualEffectView.effect = self.effect
            self.addCommentView.alpha = 1
            self.addCommentView.transform = CGAffineTransform.identity
        }
    }
    
    func animateOut() {
        
        
        visualEffectView.isUserInteractionEnabled = false
        
        UIView.animate(withDuration: 0.3, animations: {
            self.addCommentView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.addCommentView.alpha = 0
            
            self.visualEffectView.effect = nil
        }) { (success:Bool) in
            self.addCommentView.removeFromSuperview()
        }
    }
    
    func postNewComment() {
        if commentTextView.text!.isEmpty { return }
        
        let parameters: Parameters = [
            "_id": currentPost!.postId!,
            "comment": commentTextView.text!,
            "userId": FBSDKProfile.current().userID
        ]
        
        Alamofire.request(NEW_COMMENT_URL, method: .put, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            self.refreshTableView(sender: nil)
        }
    }
    
    private func reloadComments() {
        
        
        do
        {
            let jsonData = try Data.init(contentsOf: GET_POSTS_URL!)
            let jsonString = NSString(data: jsonData, encoding: 1)
            
            guard let response = Mapper<Response>().map(JSONString: jsonString! as String) else { return }
            
            for post in response.response {
                if post.postId == currentPost!.postId {
                    commentsArray.removeAll()
                    for i in 0..<post.comments.count {
                        commentsArray.append(post.comments[i])
                    }
                    return
                }
            }
        }
        catch
        {
            NSLog("Failed to retrieve blog posts. \(error)")
        }
    }
    
    func refreshTableView(sender: UIRefreshControl?) {
        DispatchQueue.global(qos: .userInitiated).async {
            
            self.reloadComments()
            
            DispatchQueue.main.async {
                self.commentsTableView.reloadData()
                guard let s = sender else { return }
                s.endRefreshing()
            }
        }
    }
}
