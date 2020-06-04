//
//  MenuVC.swift
//  WPYCamera
//
//  Created by 王鹏宇 on 4/15/19.
//  Copyright © 2019 王鹏宇. All rights reserved.
//

import UIKit

class MenuVC: LGSideMenuController,LGSideMenuDelegate {

    var isOff:Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()

        config()
        // Do any additional setup after loading the view.
    }
    

    func config(){
        
        self.leftViewWidth = kScreenWidth * 4 / 5
        self.leftViewPresentationStyle = LGSideMenuPresentationStyle.slideAbove
        
        self.rightViewWidth = kScreenWidth
        self.rightViewPresentationStyle = LGSideMenuPresentationStyle.slideAbove
        
        self.leftViewStatusBarStyle = UIStatusBarStyle.default
        self.rootViewStatusBarStyle = UIStatusBarStyle.lightContent
        self.rightViewStatusBarStyle = UIStatusBarStyle.lightContent
        
        self.rightViewSwipeGestureRange = LGSideMenuSwipeGestureRangeMake(kScreenWidth / 2.0, 44);
        self.leftViewSwipeGestureRange = LGSideMenuSwipeGestureRangeMake(44, kScreenWidth/3.0)
        
        self.delegate = self
        
    }

    
    override func showRightViewPrepare(withGesture: Bool) {
        
        super.showRightViewPrepare(withGesture: withGesture)
        if WPY_AVPlayer.playManager.isPlay {
            WPY_AVPlayer.playManager.pause()
            isOff = true
        }
    }
    
    func didHideRightView(_ rightView: UIView, sideMenuController: LGSideMenuController) {
        
//        super.didHideRightView(rightView, sideMenuController: sideMenuController)
        
        if isOff {
            
            WPY_AVPlayer.playManager.play()
            isOff = false
            
        }
        
    }
    
    
}
