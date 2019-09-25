//
//  HomePageCell.swift
//  WPYCamera
//
//  Created by 王鹏宇 on 4/16/19.
//  Copyright © 2019 王鹏宇. All rights reserved.
//

import UIKit

protocol HomePageCellDelegate:NSObjectProtocol {
    
    func goUserDetail()
    func goCommentDetail()
}

class HomePageCell: UICollectionViewCell,WPY_AVPlayerDelegate,Rotatable {
    
    

    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var maskImageView: UIImageView!
    @IBOutlet weak var maskGradView: UIView!
    @IBOutlet weak var progress: UIProgressView!
    
    @IBOutlet weak var progressBotomSpace: NSLayoutConstraint!
    
    
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var playBtnWith: NSLayoutConstraint!
    
    @IBOutlet weak var headbtn: UIButton!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var addOKImageView: UIImageView!
    @IBOutlet weak var addOKWidth: NSLayoutConstraint!
    
    @IBOutlet weak var favBtn: UIButton!
    @IBOutlet weak var favLabel: UILabel!
    @IBOutlet weak var commentBtn: UIButton!
    @IBOutlet weak var commentLabel: UILabel!
    
    
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var songNameLabel: UILabel!
    
    var delegate:HomePageCellDelegate?
    
    var urlPath:String = ""
    
    var playerLayer:AVPlayerLayer!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setup()
    }
    
    
    func setup(){
        
        progressBotomSpace.constant = CGFloat(kTabBarHeight)
        headbtn.layer.cornerRadius = 25
        headbtn.clipsToBounds = true
        headbtn.layer.borderColor = UIColor.white.cgColor
        headbtn.layer.borderWidth = 1.0
        
        addBtn.layer.cornerRadius = 11
        addBtn.clipsToBounds = true
        
        addOKImageView.layer.cornerRadius = 12
        addOKImageView.clipsToBounds = true
        addOKImageView.alpha = 0
        
        favBtn.alpha = 0.9
        let favCount = Float((arc4random()%30)/10)
        self.favLabel.text = "\(favCount + 1)w"
        
        let commentcCount = arc4random()%5000
        self.commentLabel.text = "\(commentcCount)"
        
        playBtn.isHidden = true
        playerLayer = AVPlayerLayer()
        self.contentView.layer.insertSublayer(playerLayer, below: maskImageView.layer)
        playerLayer.player = WPY_AVPlayer.playManager.player
        playerLayer.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight)
        
        let botom = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        let top = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        let gradientLayer = CAGradientLayer.gradientLayer(colors: [botom,top], position: .bottomToTop, frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 200))
        
        self.maskGradView.layer.addSublayer(gradientLayer)
        
        NotificationCenter.default.addObserver(self, selector: #selector(changePlayStateWith(_:))
            , name: NSNotification.Name(rawValue: WPY_PlayerState), object: nil)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(playOrStop))
        self.contentView.addGestureRecognizer(tap)
        
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(favAnimation(tap:)))
            tap2.numberOfTapsRequired = 2
        self.contentView.addGestureRecognizer(tap2)
        tap.require(toFail: tap2)
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
        self.playerLayer = nil
    }
    
    @objc func favAnimation(tap : UITapGestureRecognizer){
        
       
        
        let point = tap.location(in: self.contentView)
        let heartImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        heartImageView.image = UIImage(named: "favAnimation")
        heartImageView.center = point
        heartImageView.alpha = 0.6
        heartImageView.contentMode = .scaleAspectFit
        self.contentView.addSubview(heartImageView)
        
        UIView.animate(withDuration: 0.1, animations: {
            
            var rect = heartImageView.frame
            rect.size.width = 70
            rect.size.height = 70
            heartImageView.frame = rect
            heartImageView.alpha = 1.0
            
            
        }) { (isfinish) in
            
             self.favBtn.isSelected = true
            UIView.animate(withDuration: 0.3, delay: 0.3, options: UIView.AnimationOptions.curveLinear, animations: {
                
                var rect = heartImageView.frame
                rect.size.width = 150
                rect.size.height = 150
                heartImageView.frame = rect
                heartImageView.alpha = 0.2
                
            }) { (isfinish) in
                
                heartImageView.removeFromSuperview()
            }
        }
        
    }

    @IBAction func goDetail(_ sender: Any) {
        
        delegate?.goUserDetail()
    }
    
    @IBAction func addAction(_ sender: UIButton) {
        
        rotateAnimationFrom(addBtn, toItem: addOKImageView, duration: 0.5)
        
        self.addOKWidth.constant = 0
        UIView.animate(withDuration: 0.5, delay: 0.7, options: UIView.AnimationOptions.curveLinear, animations: {
            
            self.contentView.layoutIfNeeded()
            
        }) { (isfinish) in
            
//            self.addOKImageView.isHidden =  true
        }
        
    }
    
    func reset(){
         rotateAnimationFrom(addOKImageView, toItem: addBtn, duration: 0.1)
        self.addOKWidth.constant = 24
    }
    
    @IBAction func favAction(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func commentAction(_ sender: UIButton) {
        
        delegate?.goCommentDetail()
    }
    
    func playVideo(url:URL){
        
        self.urlPath  = url.absoluteString
        WPY_AVPlayer.playManager.playVideo(url: url)
        WPY_AVPlayer.playManager.delegate = self
        self.playerLayer.player = WPY_AVPlayer.playManager.player
    }
    
    
    @objc func playOrStop(){
        
        if WPY_AVPlayer.playManager.isPlay {
            WPY_AVPlayer.playManager.pause()
            playBtnAppearAnimation()
        }else{
            WPY_AVPlayer.playManager.play()
            playBtnDisappear()
        }
    }
    
    func playBtnAppearAnimation(){
        
        self.playBtn.isHidden = false
        self.playBtnWith.constant = 60
        UIView.animate(withDuration: 0.25) {
            self.playBtn.alpha = 0.9
            self.layoutIfNeeded()
        }
    }
    
    func playBtnDisappear(){
        
        self.playBtn.isHidden = true
        self.playBtn.alpha = 0.5
        self.playBtnWith.constant = 100
    }
    

    func updateProgressWith(progress: Float) {
        
        self.progress.progress = progress
    }
    
    func changeMusicToIndex(index: Int) {
        
    }
    
    func updateBufferProgress(progress: Float) {
        
    }
    
    @objc func changePlayStateWith(_ notif:Notification){
        
         guard let state = notif.userInfo?[WPY_PlayerState] as? AVPlayerPlayState , let url = notif.userInfo?[CurrentPlayUrl] as? String else {return}
        
        if url != self.urlPath {
            return
        }
        
        switch state {
        case .AVPlayerPlayStateBeigin,.AVPlayerPlayStatePreparing:
            
            self.maskImageView.isHidden = true
            
        case .AVPlayerPlayStatePlaying:
            self.maskImageView.isHidden = true
            self.playBtn.isHidden = true
            
        default:
            break
        }
    }
}
