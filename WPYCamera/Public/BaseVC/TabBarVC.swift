//
//  TabBarVC.swift
//  WPYCamera
//
//  Created by 王鹏宇 on 4/12/19.
//  Copyright © 2019 王鹏宇. All rights reserved.
//

import UIKit


class TabBarVC: UITabBarController,CustomTabBarDelegate{
   
    
    
    var customTabBar: CustomTabBar!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        initVC()
        self.navigationController?.navigationBar.isHidden = true
       
        setup()
        
        
    }
    
    private func initVC(){
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        
        let homVC = HomeVC()
        homVC.nav = self.navigationController;
        let nav1 = BaseNavController(rootViewController: homVC);
        
        let FavVC = storyBoard.instantiateViewController(withIdentifier: "FavorPage")
        let nav2 = BaseNavController(rootViewController: FavVC);
        
        self.addChild(nav1)
        self.addChild(nav2)
    }
    
    private func setup(){
        
        let H:CGFloat = CGFloat(49 + kBottomHeight)
        
        let Y = kScreenHeight - H
        
        customTabBar = CustomTabBar(frame: CGRect(x: 0, y: Y, width: kScreenWidth, height:H))
        customTabBar.setup(titles: ["首页","addMid","关注"])
        customTabBar.delegate = self
        self.view.addSubview(customTabBar)
        self.tabBar.isHidden = true
        
        self.customTabBar.select(index: 0)
        
    }
    

    
    
    func selectIndex(index: Int) {
       
        
        if index == 0 {
            self.customTabBar.backgroundColor = UIColor.clear
            sideMenuController?.isRightViewSwipeGestureEnabled = true
        }else{
            self.customTabBar.backgroundColor = UIColor.darkGray
            sideMenuController?.isRightViewSwipeGestureEnabled = false
        }
        
       self.selectedIndex = index
        
        
    
    }
    
    func midAction() {
        
        let nav = UINavigationController(rootViewController: Camera())

        self.present(Camera(), animated: true, completion: nil)
        
//        self.navigationController?.pushViewController(nav, animated: true)
        
    }
}
