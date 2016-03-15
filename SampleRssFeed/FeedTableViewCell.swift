//
//  FeedTableViewCell.swift
//  SampleRssFeed
//
//  Created by Srinivasan on 07/03/16.
//  Copyright © 2016 Tringapps, Inc. All rights reserved.
//

import UIKit

class FeedTableViewCell: UITableViewCell {
    
    @IBOutlet weak var topicTitle:UILabel!
    @IBOutlet weak var topicImage:UIImageView!
    @IBOutlet weak var topicDesc:UILabel!
    
    
    var cellID = String()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
