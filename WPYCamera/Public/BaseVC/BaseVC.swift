//
//  BaseVC.swift
//  WPYCamera
//
//  Created by 王鹏宇 on 4/15/19.
//  Copyright © 2019 王鹏宇. All rights reserved.
//

import UIKit

class BaseVC: UIViewController {
    
    var canScroll:Bool = false
    var subScrollView:UIScrollView?

    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.statusBarStyle = .lightContent
        self.navBarTitleColor = UIColor.white
        self.navBarTitleColor = UIColor.white
        self.navBarBarTintColor = UIColor.white
        self.navBarBackgroundAlpha = 0
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
