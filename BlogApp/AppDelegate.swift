//
//  AppDelegate.swift
//  BlogApp
//
//  Created by Dan German on 24/06/2017.
//  Copyright © 2017 Dan German. All rights reserved.
//

import UIKit
import FBSDKCoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        FBSDKProfile.enableUpdates(onAccessTokenChange: true)
        
        var isUserLoggedIn = true
        
        if FBSDKAccessToken.current() == nil {
            isUserLoggedIn = false
        }
        
        print(isUserLoggedIn)
        
//      let appDomain = Bundle.main.bundleIdentifier!
//      UserDefaults.standard.removePersistentDomain(forName: appDomain)
        
        window = UIWindow(frame: UIScreen.main.bounds)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        window?.rootViewController = storyboard.instantiateViewController(withIdentifier: (isUserLoggedIn ? "NavigationController" : "LoginViewController"))
        window?.makeKeyAndVisible()
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let handled = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        return handled
    }
}

