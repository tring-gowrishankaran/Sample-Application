//
//  DetailViewController.swift
//  SampleRssFeed
//
//  Created by Srinivasan on 07/03/16.
//  Copyright © 2016 Tringapps, Inc. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var topicTitleLabel: UILabel!
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var topicImage: UIImageView!

    var uniqueImgId = String()
    
    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let detail = self.detailItem {
            
            uniqueImgId = detail.valueForKey("id")!.description
            
            if let label = self.detailDescriptionLabel {
                label.text = detail.valueForKey("desc")!.description
            }
            
            if let topicLabel = self.topicTitleLabel {
                topicLabel.text = detail.valueForKey("title")!.description
            }
            
            if let topicImg = self.topicImage {
                topicImg.image = UIImage(contentsOfFile: MasterViewController().getCachePath(forFileName:self.uniqueImgId))
            }
            
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

