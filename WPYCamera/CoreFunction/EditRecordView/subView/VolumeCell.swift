//
//  VolumeCell.swift
//  WPYCamera
//
//  Created by 王鹏宇 on 1/18/19.
//  Copyright © 2019 王鹏宇. All rights reserved.
//

import UIKit

class VolumeCell: UICollectionViewCell {

    @IBOutlet weak var progressView: UIView!
    
    @IBOutlet weak var progressHeight: NSLayoutConstraint!
    var progressColor = UIColor.lightGray.withAlphaComponent(0.85){
        
        didSet{
            
            progressView.backgroundColor = progressColor
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.progressView.layer.cornerRadius = 3
        self.progressView.clipsToBounds = true
        self.progressView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.85)
        self.contentView.backgroundColor = UIColor.clear
    }

}
