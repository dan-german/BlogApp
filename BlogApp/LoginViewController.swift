//
//  LoginViewController.swift
//  BlogApp
//
//  Created by Dan German on 26/06/2017.
//  Copyright © 2017 Dan German. All rights reserved.
//

import Foundation
import UIKit
import FBSDKLoginKit
import FBSDKCoreKit

//import FBSDKShareKit

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    
    //MARK: - IBOutlet
    
    @IBOutlet weak var profilePictureView: UIImageView!
    @IBOutlet weak var usernameLabel:      UILabel!
    @IBOutlet weak var continueButton: UIButton!
    
    //MARK: - UIViewController Methods
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        
        setupFBLoginButton()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onProfileUpdated(notification:)), name:NSNotification.Name.FBSDKProfileDidChange, object: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        
        if FBSDKAccessToken.current() == nil {
            continueButton.isEnabled = false
        } else {
            userLoggedIn()
        }
    }
    
    //MARK: - UI
    
    private func setupFBLoginButton() {
        
        
        UIHelper.createBorderFor(views: usernameLabel, continueButton)
        
        let loginButton = FBSDKLoginButton()
        
        loginButton.delegate = self
        
        view.addSubview(loginButton)
        
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        
        let loginButtonH = NSLayoutConstraint.constraints(withVisualFormat: "H:|-[v0]-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":loginButton])
        let loginButtonV = NSLayoutConstraint.constraints(withVisualFormat: "V:[v4]-16-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v4":loginButton])
        NSLayoutConstraint.activate(loginButtonH)
        NSLayoutConstraint.activate(loginButtonV)
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        
        if error != nil {
            print(error)
            return
        }
        
        if FBSDKAccessToken.current() != nil {
            userLoggedIn()
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        continueButton.isEnabled = false
        profilePictureView.isHidden = true
        usernameLabel.isHidden = true
        continueButton.isHidden = true
    }
    
    func userLoggedIn() {
        
        if (FBSDKProfile.current() == nil) {
            return
        }
        usernameLabel.text = FBSDKProfile.current().firstName + " " + FBSDKProfile.current().lastName
        
        let facebookProfileUrl = FBSDKProfile.current().imageURL(for: FBSDKProfilePictureMode.square, size: CGSize(width: 500, height: 500))
        
        if let d = try? Data(contentsOf: facebookProfileUrl!) {
            self.profilePictureView.image = UIImage(data: d)
        }
        
        continueButton.isEnabled = true
        profilePictureView.isHidden = false
        usernameLabel.isHidden = false
        continueButton.isHidden = false
        
    }
    
    func onProfileUpdated(notification: NSNotification) {
        userLoggedIn()
    }
}
