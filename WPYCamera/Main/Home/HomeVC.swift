//
//  HomeVC.swift
//  WPYCamera
//
//  Created by 王鹏宇 on 6/18/19.
//  Copyright © 2019 王鹏宇. All rights reserved.
//

import UIKit
import HXPhotoPicker

class HomeVC: BaseVC,UICollectionViewDataSource,UICollectionViewDelegate,HomePageCellDelegate,WPY_VCPushDelegate{
    
    
    var nav:UINavigationController!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var currentIndex:Int = 0
    
    var dataSource = [WPYPhotoModel]()
    var navDelegate = WPY_NavDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
         setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
         super.viewWillAppear(animated)
        self.pushDelegate = self
        loadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.nav.addTransitionGesture(with: self, type:WPYTransitionType.rightLeftPush)
    }
    func loadData(){
        
        //        guard let array =  UserDefaults.standard.array(forKey: VideoKey) as? [URL] else {return}
        
        guard let arr = DBHelper.manager.selec() as? [WPYPhotoModel] else  {return}
        self.dataSource = arr
        self.collectionView.reloadData()
        
        if self.dataSource.count > 0{
            self.playTheVideoWith(index: 0)
        }
        
    }

    
    func setup(){
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        if let collectionLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            
            collectionLayout.itemSize = CGSize(width: kScreenWidth, height: kScreenHeight)
            collectionLayout.minimumLineSpacing = 0.1
            collectionLayout.minimumInteritemSpacing = 0.1
        }
        
        self.collectionView.register(UINib(nibName: "HomePageCell", bundle: nil), forCellWithReuseIdentifier: "HomePageCell")
        
        if #available(iOS 11.0, *) {
            
            self.collectionView.contentInsetAdjustmentBehavior = .never
        }else{
            
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
    }
    
    func playTheVideoWith(index:Int){
        
        let model = self.dataSource[index]
        guard let url = URL(string: model.videoUrl ?? "") else {return}
        
        let indexPath = IndexPath(row: index, section: 0)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
            
            guard let cell = self.collectionView.cellForItem(at: indexPath)  as? HomePageCell else {return}
            
            cell.playVideo(url: url)
        }
        
        self.currentIndex = index
        
    }
    
    
    func goCommentDetail() {
        
        let commentVC = CommentVC()
        commentVC.modalPresentationStyle = UIModalPresentationStyle.custom
        self.present(commentVC, animated: true, completion: nil)
    }
    
    //HomePageCellDelegate
    
    func goUserDetail() {
        
//        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
//        let vc = storyBoard.instantiateViewController(withIdentifier: "UserDetailVC")
        
        let vc = DYViewController()
        
        self.nav.pushViewController(vc, animated: true)
       
    }
    
    func pushRightVC() {
        
        let leftVC = LeftVC()
        self.nav.pushViewController(leftVC, animated: true)
    }
    
    func pushLeftVC() {
        goUserDetail()
    }
    
}


extension HomeVC  {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let row = Int(scrollView.contentOffset.y / self.collectionView.frame.height)
        if(row != self.currentIndex){
            
            self.playTheVideoWith(index: row)
        }
    }
    
    
    @objc public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return   self.dataSource.count
    }
    
    @objc(collectionView:cellForItemAtIndexPath:) public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomePageCell", for: indexPath) as! HomePageCell
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        
        guard let cell = cell as? HomePageCell  else {return}
        
        cell.delegate = self
        let mm = self.dataSource[indexPath.row]
        
        if let model = HXPhotoModel(videoURL: URL(string: mm.videoUrl ?? "")){
            cell.maskImageView.image = model.previewPhoto
            cell.contentLabel.text = mm.content ?? ""
            cell.playerLayer.player = nil
            cell.urlPath = ""
            
            cell.maskImageView.isHidden = false
        }
        
    }
    
}
