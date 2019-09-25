//
//  WPYContainerCell.swift
//  WPYCamera
//
//  Created by 王鹏宇 on 4/30/19.
//  Copyright © 2019 王鹏宇. All rights reserved.
//

import UIKit

protocol WPYContainerCellDelegate:NSObjectProtocol {
    
    func selectVC(index:Int)
}


class WPYContainerCell:  UITableViewCell,UIPageViewControllerDataSource,UIPageViewControllerDelegate{
   
    

//    var pageScrollView:UIScrollView?
    var pageVC:UIPageViewController = {
        
        let vc = UIPageViewController(transitionStyle: UIPageViewController.TransitionStyle.scroll, navigationOrientation: UIPageViewController.NavigationOrientation.horizontal, options: [UIPageViewController.OptionsKey.spineLocation : UIPageViewController.SpineLocation.min])
        
        return vc
    }()
    
    var currentPage:Int = 0
    var dataArray:Array<BaseVC> = [BaseVC]()
    var delegate:WPYContainerCellDelegate?
    var canScroll:Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        // Initialization code
    }

    func setCanScroll(canscroll:Bool){
        
        canScroll = canscroll
        
        for vc in self.dataArray {
            
            vc.canScroll = self.canScroll
            
            if(!canscroll){
                
                vc.subScrollView?.contentOffset = CGPoint.zero
            }
            
        }
    }
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if (otherGestureRecognizer.view?.isKind(of: UITableView.self))!{
            return true
        }
        
        return false
    }
    
    func setup(arr:Array<BaseVC>){
        
        self.dataArray = arr
        
         self.pageVC.dataSource = self
         self.pageVC.delegate = self
        
        self.pageVC.setViewControllers([arr[0]], direction: UIPageViewController.NavigationDirection.forward, animated: true, completion: nil)
        
        self.contentView.addSubview(self.pageVC.view)
        
        self.pageVC.view.snp.makeConstraints { (make) in
            
            make.edges.equalToSuperview()
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func changeToVC(index:Int){
        
        let vc = self.dataArray[index]
        
        self.pageVC.setViewControllers([vc], direction: UIPageViewController.NavigationDirection.forward, animated: false, completion: nil)
    
    }
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard let scrollView = object as? UIScrollView else {return}
        
        if scrollView.panGestureRecognizer.state == .changed {
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PageViewGestureState"), object: "changed")
        }else if(scrollView.panGestureRecognizer.state == .ended){
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PageViewGestureState"), object: "ended")
        }
    }
    
    
    
    

    
    
    
    /// 点击或滑动 UIPageViewController 左侧边缘时触发
    ///
    /// - Parameters:
    ///   - pageViewController: 翻页控制器
    ///   - viewController: 当前控制器
    /// - Returns: 返回前一个视图控制器
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
       
        guard var index = self.dataArray.firstIndex(of: viewController as! BaseVC) else {return nil}
        
        if index == NSNotFound || index == 0 {
            
            return nil
        }
        
        index -= 1
        
        return self.dataArray[index]
    }
    
    /// 点击或滑动 UIPageViewController 右侧边缘时触发
    ///
    /// - Parameters:
    ///   - pageViewController: 翻页控制器
    ///   - viewController: 当前控制器
    /// - Returns: 返回下一个视图控制器
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard var index = self.dataArray.firstIndex(of: viewController as! BaseVC) else {return nil}
        
        if index == NSNotFound || index == self.dataArray.count - 1 {
            
            return nil
        }
        
        index += 1
        
        return self.dataArray[index]
    }
    
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        guard let index = self.dataArray.firstIndex(of: self.pageVC.viewControllers?.first as! BaseVC) else {return}
        
        delegate?.selectVC(index: index)
    }
}
