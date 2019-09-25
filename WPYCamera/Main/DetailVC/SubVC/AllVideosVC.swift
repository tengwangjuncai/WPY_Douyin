//
//  AllVideosVC.swift
//  WPYCamera
//
//  Created by 王鹏宇 on 4/30/19.
//  Copyright © 2019 王鹏宇. All rights reserved.
//

import UIKit
import GKPageScrollViewSwift

typealias listScrollViewScrollBlock = (_ scrollView:UIScrollView)->Void

class AllVideosVC: BaseVC,UICollectionViewDelegate,UICollectionViewDataSource,UIScrollViewDelegate,GKPageListViewDelegate{
    
    
    
    var scrollBlock: listScrollViewScrollBlock?
    
    @IBOutlet weak var collectionView: UICollectionView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setup()
    }


    func setup(){
        
        
        guard let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {return}
        
        let width = (kScreenWidth - 2)/3
        layout.itemSize  = CGSize(width: width, height: width/2*3)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 1
        
        self.collectionView.register(UINib(nibName: "VideoCell", bundle: nil), forCellWithReuseIdentifier: "VideoCell")
        self.subScrollView = self.collectionView
        
        self.collectionView.panGestureRecognizer.delaysTouchesBegan = false
    }
    
}


extension AllVideosVC {
    
    
    func listScrollView() -> UIScrollView {
        
        return self.collectionView
    }
    
    func listViewDidScroll(callBack: @escaping (UIScrollView) -> ()) {
        
        self.scrollBlock = callBack
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if let  listScrollBlock = self.scrollBlock{
            
            listScrollBlock(scrollView)
        }
        
        
//        let offsetY = scrollView.contentOffset.y
//        if !self.canScroll {
//
//            scrollView.contentOffset = CGPoint.zero
//        }
//
//        if(offsetY < 0){
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "kLeaveTopNtf"), object: 1)
//            self.canScroll = false
//            scrollView.contentOffset = .zero
//        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 18
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCell", for: indexPath)
        
        cell.contentView.backgroundColor = UIColor(red: CGFloat(arc4random()%255) / 255.0, green: CGFloat(arc4random()%255) / 255.0, blue: CGFloat(arc4random()%255) / 255.0, alpha: 1.0)
        
        
        
        return cell
    }
}
