//
//  DYViewController.swift
//  WPYCamera
//
//  Created by 王鹏宇 on 6/25/19.
//  Copyright © 2019 王鹏宇. All rights reserved.
//

import UIKit
import GKPageScrollViewSwift

class DYViewController: BaseVC,GKPageScrollViewDelegate,UIScrollViewDelegate {
    
    
    
    lazy var pageScrollView:GKPageScrollView = {
        let pageScroll = GKPageScrollView(delegate: self)
        
        return pageScroll
    }()
    
    lazy var pageView:UIView = {
        
        let page = UIView()
        page.backgroundColor = UIColor.clear
        
        page.addSubview(self.scrollView)
        
        return page
    }()
    lazy var scrollView:UIScrollView = {
        
         let scrolllH = kScreenHeight - CGFloat(kNavhHeight)
        
        let scroll = UIScrollView(frame: CGRect(x: 0, y:0, width: kScreenWidth, height: scrolllH))
        
        scroll.isPagingEnabled = true
        scroll.bounces = false
        scroll.delegate = self
        scroll.showsHorizontalScrollIndicator = false
        
        for (i,vc) in self.childVCs.enumerated(){
            
            self.addChild(vc)
            scroll.addSubview(vc.view)
            vc.view.frame = CGRect(x: CGFloat(i) * kScreenWidth, y: 0, width: kScreenWidth, height: scrolllH)
        }
        
        scroll.contentSize = CGSize(width:CGFloat(self.childVCs.count)  * kScreenWidth, height: 0)
        
        return scroll
    }()
    
    var titles:Array<String> = []
    lazy var childVCs:Array<UIViewController> = {
        
        let publicVC = AllVideosVC()
        let dynamicVC = AllVideosVC()
        let loveVC = AllVideosVC()
    
        return [publicVC,dynamicVC,loveVC]
    }()
    
    lazy var headerView:UIView = {
       
        let header = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 400))
        header.backgroundColor = UIColor(red: 32/255.0, green: 32/255.0, blue: 41/255.0, alpha: 1.0)
        
        return header
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setup()
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        self.navigationController?.addTransitionGesture(with: self, type: WPYTransitionType.rightPop)
    }
    
    func setup(){
        
        self.pageScrollView.delegate = self
        self.pageView.backgroundColor = UIColor.white
        self.view.addSubview(self.pageScrollView)
        self.pageScrollView.frame = UIScreen.main.bounds
        
        self.pageScrollView.reloadData()
        
    }
    

    func shouldLazyLoadList(in pageScrollView: GKPageScrollView) -> Bool {
        return false
    }
    
    func headerView(in pageScrollView: GKPageScrollView) -> UIView {
        
        return self.headerView
    }
    
    func pageView(in pageScrollView: GKPageScrollView) -> UIView {
        
        return self.pageView
    }
    
    func listView(in pageScrollView: GKPageScrollView) -> [GKPageListViewDelegate] {
        
        return self.childVCs as! [GKPageListViewDelegate]
    }
    
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.pageScrollView.horizonScrollViewWillBeginScroll()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        self.pageScrollView.horizonScrollViewDidEndedScroll()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        self.pageScrollView.horizonScrollViewDidEndedScroll()
    }

}

extension DYViewController{
    
   
}
