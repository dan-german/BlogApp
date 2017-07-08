//
//  Helper.swift
//  BlogApp
//
//  Created by Dan German on 30/06/2017.
//  Copyright © 2017 Dan German. All rights reserved.
//

import Foundation
import UIKit

class UIHelper {
    
    
    static func createBorderFor(views: UIView...) {
        
        
        let borderColor : UIColor = UIColor(white: 0.85, alpha: 1)
        
        for view in views {
            view.layer.borderWidth = 0.5
            view.layer.borderColor = borderColor.cgColor
            view.layer.cornerRadius = 5.0
        }
    }
    
    static func makeViewCircular(view: UIView) {
        

        view.layer.masksToBounds = false
        view.layer.cornerRadius = view.frame.height/2
        view.clipsToBounds = true
    }
}
