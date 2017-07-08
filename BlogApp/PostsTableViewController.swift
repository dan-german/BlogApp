//
//  ViewController.swift
//  BlogApp
//
//  Created by Dan German on 24/06/2017.
//  Copyright © 2017 Dan German. All rights reserved.
//

import UIKit
import ObjectMapper
import Alamofire
import FBSDKCoreKit

class PostsTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    //MARK: - IBOutlet
    
    @IBOutlet weak var tableView:        UITableView!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    
    @IBOutlet      var addPostView:      UIView!
    @IBOutlet weak var titleTextView:    UITextView!
    @IBOutlet weak var contentTextView:  UITextView!
    @IBOutlet weak var cancelButton:     UIButton!
    @IBOutlet weak var saveButton:       UIButton!
    
    //MARK: - Properties
    
    let GET_POSTS_URL = URL(string: "http://localhost:3000/api/getposts")
    let NEW_POST_URL = "http://localhost:3000/api/newpost"
    
    var BlogPostArray = [Post]()
    var delegate: PostDataProtocol?
    var effect: UIVisualEffect!
    let dateFormatter = DateFormatter()
    
    //MARK: - UIViewController Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        populateBlogPostArray()
        setupViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        refreshTableView(sender: nil)
    }
    
    //MARK: - Table view data source methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BlogPostArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell
        
        cell.accessoryType = .disclosureIndicator
        
        if BlogPostArray.isEmpty { return cell }
        
        cell.titleLabel.text = BlogPostArray[indexPath.row].title
        cell.nameLabel.text = BlogPostArray[indexPath.row].username
        
        let timestamp = BlogPostArray[indexPath.row].timestamp
        cell.timeLabel.text = dateFormatter.timeSince(from: Date.init(timeIntervalSince1970: timestamp!) as NSDate, numericDates: true)
        
        let userId = BlogPostArray[indexPath.row].userId
        
        let facebookProfileUrl = URL(string:"http://graph.facebook.com/\(userId!)/picture?type=large")
        let data = try? Data(contentsOf: facebookProfileUrl!)
        
        if data != nil {
            cell.profilePictureView.image = UIImage(data: data!)
        }
        
        return cell
    }
    
    //MARK: - UITextViewDelegate Methods
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.characters.count
        
        if textView == titleTextView {
            return numberOfChars <= 25
        } else if textView == contentTextView {
            return numberOfChars <= 900
        }else {
            return false
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        
        if titleTextView.text.isEmpty || contentTextView.text.isEmpty {
            saveButton.isEnabled = false
        } else {
            saveButton.isEnabled = true
        }
    }
    
    //MARK: - Navigation methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if segue.identifier == "PostDetail" {
            
            
            if let postVC = segue.destination as? PostDetailViewController {
                guard let selectedBlogCell = sender as? PostCell else {
                    fatalError("Unexpected sender: \(String(describing: sender))")
                }
                
                guard let indexPath = tableView.indexPath(for: selectedBlogCell) else {
                    fatalError("The selected cell is not being displayed by the table")
                }
                
                delegate = postVC
                delegate?.passPost(post: BlogPostArray[indexPath.row])
            }
        }
    }
    
    //MARK: - UI
    
    func setupViews() {
        
        
        tableView.tableFooterView = UIView(frame: .zero)
        
        saveButton.isEnabled = false
        
        titleTextView.textContainer.maximumNumberOfLines = 1
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.refreshTableView), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
        
        effect = visualEffectView.effect
        visualEffectView.effect = nil
        visualEffectView.isUserInteractionEnabled = false
        
        UIHelper.createBorderFor(views: titleTextView, contentTextView, cancelButton, saveButton, addPostView)
    }
    
    private func populateBlogPostArray() {
        do
        {
            let jsonData = try Data.init(contentsOf: GET_POSTS_URL!)
            let jsonString = NSString(data: jsonData, encoding: 1)
            
            guard let response = Mapper<Response>().map(JSONString: jsonString! as String) else { return }
            
            self.BlogPostArray.removeAll()
            
            for post in response.response {
                BlogPostArray.append(post)
            }
        }
        catch
        {
            NSLog("Failed to retrieve blog posts. \(error)")
        }
    }
    
    func refreshTableView(sender: UIRefreshControl?) {
        DispatchQueue.global(qos: .userInitiated).async {
            
            self.populateBlogPostArray()
            
            DispatchQueue.main.async {
                
                self.tableView.reloadData()
                guard let s = sender else { return }
                s.endRefreshing()
            }
        }
    }
    
    //MARK: - IBAction
    
    @IBAction func addPostButtonTapped(_ sender: UIBarButtonItem) {
        animateIn(addPostView)
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        createNewPost()
        animateOut(addPostView)
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        animateOut(addPostView)
    }
    
    //MARK: -
    
    func animateIn(_ viewToAnimate: UIView) {
        
        
        visualEffectView.isUserInteractionEnabled = true
        
        self.view.addSubview(viewToAnimate)
        viewToAnimate.center = self.view.center
        
        viewToAnimate.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        viewToAnimate.alpha = 0
        
        UIView.animate(withDuration: 0.4){
            self.visualEffectView.effect = self.effect
            self.addPostView.alpha = 1
            self.addPostView.transform = CGAffineTransform.identity
        }
    }
    
    func animateOut(_ viewToAnimate: UIView) {
        
        
        visualEffectView.isUserInteractionEnabled = false
        
        UIView.animate(withDuration: 0.3, animations: {
            viewToAnimate.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            viewToAnimate.alpha = 0
            
            self.visualEffectView.effect = nil
        }) { (success:Bool) in
            viewToAnimate.removeFromSuperview()
        }
    }
    
    func createNewPost() {
        
        
        let parameters: Parameters = [
            "title": titleTextView.text!,
            "content": contentTextView.text!,
            "user_id": FBSDKAccessToken.current().userID,
            "username": FBSDKProfile.current().firstName + " " + FBSDKProfile.current().lastName,
            "comments": [],
            "timestamp": Date().timeIntervalSince1970
        ]
        
        Alamofire.request(NEW_POST_URL, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            self.refreshTableView(sender: nil)
        }
    }
}

