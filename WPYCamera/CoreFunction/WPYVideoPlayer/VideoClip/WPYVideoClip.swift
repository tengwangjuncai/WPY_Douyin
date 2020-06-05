//
//  WPYVideoClip.swift
//  WPYCamera
//
//  Created by 王鹏宇 on 3/1/19.
//  Copyright © 2019 王鹏宇. All rights reserved.
//

import UIKit
import Photos
import AVFoundation





class WPYVideoClip: BaseVC,UICollectionViewDelegate,UICollectionViewDataSource {
    
    var operationCellKey = "operationCellKey"
    
    var videoUrl:URL?
    var maxEditVideoTime:CGFloat = 15
    
    private var bottomView:UIView!
    private var indicatorLine:UIView!
    
    
    private var timer:Timer?
    
    private var offsetX:CGFloat = 0
    private var orientationChanged:Bool = false
    
    private var asset:AVAsset?
    private var passet:PHAsset?
    
    private var interval:TimeInterval = 0
    private var measureCount = 0
    
    private var queue:OperationQueue!
    
    private var imageCache = [String:UIImage]()
    private var opCache = [String:BlockOperation]()
    
    private var playerLayer:AVPlayerLayer!
    private var collectionView:UICollectionView!
    private var clipView:WPYClipFrameView!
    private var generator:AVAssetImageGenerator!
    
    private var nextBtn:UIButton!
    private var backBtn:UIButton!
    
    private var isInit = false
    
    var completeHander:((_ image:UIImage?,_ videoURL:URL?,_ success:Bool)-> Void)?
    
    public convenience init(maxDuration duration:CGFloat, vedio url:URL?, phAsset:PHAsset?){
        
        self.init()
        maxEditVideoTime = duration
        videoUrl = url
        passet = phAsset
    }
    
    deinit {
        
        stopTimer()
        playerLayer.player = nil
        queue.cancelAllOperations()
        NotificationCenter.default.removeObserver(self)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        if let url = videoUrl {
            
            asset = AVAsset(url: url)
        }
        
        analysisAssetImages()
        setupQueue()
        setupGennerator()
        
        setupBtn()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        if isInit {
            self.startTimer()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.stopTimer()
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        var inset = UIEdgeInsets.zero
        
        if #available(iOS 11.0, *){
            
            inset = self.view.safeAreaInsets
        }
        
        let count = CGFloat(min(measureCount, 10))
        
        playerLayer.frame = CGRect(x: 0, y: 0 , width: kScreenWidth, height: kScreenHeight)
        
        clipView.frame = CGRect(x: (CGFloat(kScreenWidth) - kItemWith * 10) / 2, y: CGFloat(kScreenHeight) - 66 - inset.bottom, width: kItemWith * count, height: kItemHeight)
        
        clipView.validRect = clipView.bounds
        
        collectionView.frame = CGRect(x: inset.left, y: CGFloat(kScreenHeight - 66 - inset.bottom), width: CGFloat(kScreenWidth) - inset.left - inset.right, height: kItemHeight)
        
        let leftOffset = (CGFloat(kScreenWidth) - kItemWith * 10)/2 - inset.left
        
        let rightOffset = (CGFloat(kScreenWidth) - kItemWith * 10) / 2 - inset.right
        collectionView.contentInset = UIEdgeInsets(top: 0, left: leftOffset, bottom: 0, right: rightOffset)
        
        collectionView.setContentOffset(CGPoint(x: offsetX - leftOffset, y: 0), animated: false)
        
        if asset != nil {
            
            
        }
        
    }
    
    private func setupBtn(){
        
        var inset = UIEdgeInsets.zero
        
        if #available(iOS 11.0, *){
            
            inset = self.view.safeAreaInsets
        }
        
        backBtn = UIButton(frame: CGRect(x: 10, y: inset.top + 20, width: 44, height: 44))
        backBtn.setImage(UIImage(named: "fanhui")!, for: .normal)
        self.view.addSubview(backBtn)
        backBtn.addTarget(self, action: #selector(cancelAction), for: UIControl.Event.touchUpInside)
        
        nextBtn = UIButton(frame: CGRect(x:kScreenWidth - 70, y: inset.top + 27, width: 60, height: 30))
        nextBtn.setTitle("下一步", for: UIControl.State.normal)
        nextBtn.backgroundColor = UIColor(red: 229/255.0, green: 33/255.0, blue: 66/255.0, alpha: 1.0)
        nextBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        
        self.view.addSubview(nextBtn)
                nextBtn.addTarget(self, action: #selector(doneAction), for: UIControl.Event.touchUpInside)
        
       let leftItem = UIBarButtonItem(customView: backBtn)
       let rightItem = UIBarButtonItem(customView: nextBtn)
        
        self.navigationItem.leftBarButtonItem = leftItem
        self.navigationItem.rightBarButtonItem = rightItem
        
        self.navigationController?.navigationBar.backgroundColor = UIColor.clear
        self.navigationController?.navigationBar.isHidden = false
    }
    

    private func setupUI(){
        
        self.view.backgroundColor = UIColor.black
        playerLayer = AVPlayerLayer()
        self.view.layer.addSublayer(playerLayer)
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: kItemWith, height: kItemHeight)
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.clear
        collectionView.clipsToBounds = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(WPYVideoClipCell.self, forCellWithReuseIdentifier: "WPYVideoClipCell")
        
        self.view.addSubview(collectionView)
        
        clipView = WPYClipFrameView()
        clipView.backgroundColor = UIColor.clear
        self.view.addSubview(clipView)
        clipViewAction()
        
        indicatorLine = UIView(frame: CGRect(x: kItemWith/2, y: -3, width: 3, height: kItemHeight + 6))
        
        indicatorLine.backgroundColor = kBgColor.withAlphaComponent(0.7)
        
    }
    
    private func setupQueue(){
        
        queue = OperationQueue()
        queue.maxConcurrentOperationCount = 3
        
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationChanged), name: UIApplication.willChangeStatusBarOrientationNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(appResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(appBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        
    }
    
    private func setupGennerator(){
        
        if let asset = asset {
            
            generator = AVAssetImageGenerator(asset: asset)
            
            ///按比例生成， 不指定会默认视频原来的格式大小
            generator.maximumSize = CGSize(width: kItemWith * 4, height: kItemHeight * 4)
            generator.appliesPreferredTrackTransform = true
            //防止时间出现偏差
            generator.requestedTimeToleranceBefore = CMTime.zero
            generator.requestedTimeToleranceAfter = CMTime.zero
            generator.apertureMode = .productionAperture
            
        }
    }
    
    private func analysisAssetImages(){
        
        if let passet = passet {
            
            let duration = passet.duration
            
            interval = TimeInterval(maxEditVideoTime / 10.0)
            measureCount = Int(duration / interval)
            
            PHCachingImageManager.default().requestPlayerItem(forVideo: passet, options: nil) {
                [weak self] item, info in
                
                guard let  `self` = self else { return }
                guard let  item = item else {return}
                
                DispatchQueue.main.async {
                    
                    let player = AVPlayer(playerItem: item)
                    self.playerLayer.player = player
                    
                    self.isInit = true
                    self.startTimer()
                }
            }
            
            //PHAsset是来自相册的视频地址和相关信息
            PHCachingImageManager.default().requestAVAsset(forVideo: passet, options: nil) {
                [weak self] asset, _, _ in
                
                guard let `self` = self else {return}
                
                DispatchQueue.main.async {
                    
                    self.asset = asset
                    self.setupGennerator()
                    self.collectionView.reloadData()
                }
            }
        }else {
            
            if let Aduration = asset?.duration {
                
                let duration = CMTimeGetSeconds(Aduration)
                interval = TimeInterval(maxEditVideoTime / 10.0)
                
                measureCount = Int(duration / interval)
                
                let player = AVPlayer(url: videoUrl!)
                
                self.playerLayer.player = player
                
            }
        }
    }
    
    private func startTimer(){
        
        self.stopTimer()
        
        let duration = interval * TimeInterval(self.clipView.validRect.size.width / kItemWith)
        
        timer = Timer.scheduledTimer(timeInterval: duration, target: self, selector: #selector(playPartVideo), userInfo: nil, repeats: true)
        
        timer?.fire()
        RunLoop.main.add(timer!, forMode: RunLoop.Mode.common)
        
        indicatorLine.frame = CGRect(x: self.clipView.validRect.origin.x + kItemWith/2, y: -3, width: 3, height: kItemHeight + 6)
        self.clipView.addSubview(indicatorLine)
        
        UIView.animate(withDuration: duration, delay: 0, options:[.repeat,.allowUserInteraction,.curveLinear], animations: {
            [weak self] in
            
            guard let `self` = self else { return }
            self.indicatorLine.frame = CGRect(x: self.clipView.validRect.maxX - 3 - kItemWith/2, y: -3, width: 3, height: kItemHeight + 6)
            
        }, completion: nil)
        
        
    }
    
    private func stopTimer(){
        
        timer?.invalidate()
        timer = nil
        
        self.playerLayer.player?.pause()
        self.indicatorLine.removeFromSuperview()
    }
    
    @objc private func playPartVideo(){
        
        self.playerLayer.player?.play()
        self.playerLayer.player?.seek(to: getStartTime(), toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
    }
    
    
    @objc private func deviceOrientationChanged(){
        
        offsetX = self.collectionView.contentOffset.x + self.collectionView.contentInset.left
        orientationChanged = true
    }
    
    @objc private func appResignActive(){
        
        stopTimer()
    }
    
    @objc private func appBecomeActive(){
        
        startTimer()
    }
    
    @objc private func cancelAction(){
        
        DispatchQueue.main.async {
            [weak self] in
            guard let `self` = self else {return}
            
            self.stopTimer()
            self.completeHander?(nil,nil,false)
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    @objc private func doneAction(){
        
        stopTimer()
//        self.view.showLoadingHUDText("到出中")
        self.view.hx_showLoadingHUDText("到出中")
        
        WPYVideoEditManager.cropVideo(asset: asset!, cropRange: getTimeRange()) {
            [weak self] url, duration,success in
            
            guard let `self` = self else {return}
            
            DispatchQueue.main.async {
                
                self.view.hx_handleLoading()
                //                self.completeHander?(nil,url,true)
                let playVC = playVideoVC()
                playVC.videoURL = url
                playVC.isFrommRecord = true
                self.navigationController?.pushViewController(playVC, animated: true)
            }
        }
        
    }
    
    private func clipViewAction(){
        
        clipView.editViewValidRectChanged = {
            [weak self] in
            guard let `self` = self else { return }
            self.stopTimer()
            self.playerLayer.player?.seek(to: self.getStartTime(), toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        }
        
        clipView.editViewValidRectEndChanged = {
            
            [weak self] in
            guard let `self` = self else {return}
            self.startTimer()
        }
    }
    
    private func getStartTime()-> CMTime{
        
        let rect = self.collectionView.convert(self.clipView.validRect, from: self.clipView)
        let s = max(0,interval * TimeInterval(rect.origin.x / kItemWith))
        
        return CMTime(seconds: s, preferredTimescale: (self.playerLayer.player?.currentTime().timescale)!)
    }
    
    private func getTimeRange() ->CMTimeRange {
        
        let start = getStartTime()
        
        let d = interval * TimeInterval(self.clipView.validRect.size.width / kItemWith)
        
        let duration = CMTime(seconds: d, preferredTimescale: (self.playerLayer.player?.currentTime().timescale)!)
        
        return CMTimeRange(start: start, end: duration)
    }

}


extension WPYVideoClip {
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if self.playerLayer.player == nil || orientationChanged {
            
            orientationChanged = false
            return
        }
        stopTimer()
        
        self.playerLayer.player?.seek(to: getStartTime(), toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        if !decelerate
        {
            startTimer()
        }
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        startTimer()
    }
    
    
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if asset == nil {
            return 0
        }
        
        return measureCount
//
//        return 0
    }
    
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"WPYVideoClipCell", for: indexPath) as! WPYVideoClipCell
        
        if imageCache.contains(key: "\(indexPath.row)") {
            
            cell.imageView.image = imageCache["\(indexPath.row)"]
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard let asset = asset else {
            
            return
        }
        
        if imageCache.contains(key: "\(indexPath.row)") || opCache.contains(key: "\(indexPath.row)") {
            
            return
        }
        
        let op = BlockOperation{
            
            [weak self] in
            guard let `self` = self else {return}
            
            let row = indexPath.row
            let i = TimeInterval(row) * self.interval
            
            let time = CMTime(value: CMTimeValue(CMTimeScale(i + 0.35) * asset.duration.timescale), timescale: asset.duration.timescale)
            
            guard let cgImg = try? self.generator.copyCGImage(at: time, actualTime: nil) else {
                
                objc_removeAssociatedObjects(cell)
                
                return
            }
            
            let image = UIImage(cgImage: cgImg)
            self.imageCache["\(indexPath.row)"] = image
            DispatchQueue.main.async {
                
                if let nowIndexPath = collectionView.indexPath(for: cell)
                {
                    
                    if row == nowIndexPath.row
                    {
                        let cell = cell as! WPYVideoClipCell
                        
                        cell.imageView.image = image
                    }
                    else
                    {
                        if self.imageCache.contains(key: "\(nowIndexPath.row)")
                        {
                            
                            let cell = cell as! WPYVideoClipCell
                            cell.imageView.image =  self.imageCache["\(nowIndexPath.row)"]
                        }
                    }
                }
                
                self.opCache.removeValue(forKey: "\(row)")
                objc_removeAssociatedObjects(cell);
            }
        }
        
        queue.addOperation(op)
        self.opCache["\(indexPath.row)"] = op
        
        objc_setAssociatedObject(cell, &operationCellKey, op
            , objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard let op = objc_getAssociatedObject(cell, &operationCellKey) as? BlockOperation else {
            
            return
        }
        
        op.cancel()
        objc_removeAssociatedObjects(cell)
        opCache.removeValue(forKey: "\(indexPath.row)")
    }
    
    
}


extension Dictionary {
    
    func contains(key:String) -> Bool {
        
        return self.contains{  (key1,value1) -> Bool in
            
            guard let key2 = key1 as? String else {return false}
            
            return key == key2
        }
        
        }
        
}
