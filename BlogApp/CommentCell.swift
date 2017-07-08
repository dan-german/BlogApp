//
//  CommentCell.swift
//  BlogApp
//
//  Created by Dan German on 28/06/2017.
//  Copyright © 2017 Dan German. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {

    @IBOutlet weak var profilePictureView: UIImageView!
    @IBOutlet weak var commentTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        UIHelper.createBorderFor(views: commentTextView)
        UIHelper.makeViewCircular(view: profilePictureView)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
