//
//  WPYEditRecordView.swift
//  WPYCamera
//
//  Created by 王鹏宇 on 1/18/19.
//  Copyright © 2019 王鹏宇. All rights reserved.
//

import UIKit

let kAudioItemWith = CGFloat(9.0)

protocol WPYEditRecordViewDelegate : NSObjectProtocol{
    
    func completeEdit();
    func audioViewEndChanged(startTime:TimeInterval);
}

class WPYEditRecordView: UIView,UICollectionViewDelegate,UICollectionViewDataSource {
    
    var tipLabel = UILabel()
    var collectionView :UICollectionView!
    var completeBtn : UIButton!
    var currentTime : Float = 0
    var timeLabel = UILabel()
    var dataSource = [Float]()
    var audioTimeSC:CGFloat = 15
    var interval:TimeInterval = 0
    var duration:TimeInterval = 0
    var count:Int = 0
    weak var delegate : WPYEditRecordViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        analysisAssetAudio()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
        analysisAssetAudio()
    }

}


extension WPYEditRecordView {
    
  private  func setup(){
        
        self.tipLabel.frame = CGRect(x: 100, y: 10, width: UIScreen.main.bounds.width - 200, height: 25)
        self.tipLabel.textColor = UIColor.white
        self.tipLabel.font = UIFont.systemFont(ofSize: 14)
        self.tipLabel.text = "左右拖动声谱以剪取音乐"
        self.addSubview(self.tipLabel)
        
        self.completeBtn = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 80, y: 7, width: 60, height: 30))
        self.completeBtn.backgroundColor = UIColor.red
        self.completeBtn.setTitle("完成", for: UIControl.State.normal)
        self.completeBtn.setTitleColor(UIColor.white, for: UIControl.State.normal)
        self.addSubview(self.completeBtn)
        self.completeBtn.addTarget(self, action: #selector(complete), for: UIControl.Event.touchUpInside)
        
        self.timeLabel.textColor = UIColor.white
        self.timeLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        self.timeLabel.font = UIFont.systemFont(ofSize: 12)
        self.timeLabel.frame = CGRect(x: 25, y: 60, width: 120, height: 21)
        self.timeLabel.text = "当前从00:00开始"
        self.timeLabel.textAlignment = .center
        self.timeLabel.layer.cornerRadius = 5
        self.timeLabel.clipsToBounds = true
        self.addSubview(self.timeLabel)
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: kAudioItemWith, height: 100);
        self.collectionView = UICollectionView(frame: CGRect(x: 0, y: 100, width: UIScreen.main.bounds.width, height: 100), collectionViewLayout: layout)
        self.addSubview(self.collectionView)
        self.collectionView.register(UINib(nibName:"VolumeCell", bundle: nil), forCellWithReuseIdentifier: "VolumeCell")
        self.collectionView.backgroundColor = UIColor.clear
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.bounces = false
        
    }
    
    private func analysisAssetAudio(){
        
        interval = TimeInterval(audioTimeSC / 60.0)
        
        count = Int(duration / interval)
    }
    
    
    @objc func complete(){
        
        self.delegate?.completeEdit()
    }
    
}

extension WPYEditRecordView{
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
       let X = scrollView.contentOffset.x
        
       let start = max(0,interval * TimeInterval(X / kAudioItemWith))
        
        self.delegate?.audioViewEndChanged(startTime: start)
        
        print("滚动减速结束结束。。。。。\(X)###开始时间--\(start)")
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        if !decelerate {
            
            let X = scrollView.contentOffset.x
            
            let start = max(0,interval * TimeInterval(X / kAudioItemWith))
            
            self.delegate?.audioViewEndChanged(startTime: start)
            
            print("滚动减速结束结束。。。。。\(X)###开始时间--\(start)")
            
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return   60  // count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VolumeCell", for: indexPath)
        
        return cell
    }
}
