//
//  WPYPlayView.swift
//  WPYCamera
//
//  Created by 王鹏宇 on 1/14/19.
//  Copyright © 2019 王鹏宇. All rights reserved.
//

import UIKit


public typealias PlayerFillMode = AVLayerVideoGravity

class WPYPlayView: UIView {

    public override class var layerClass : AnyClass{
        get{
            return AVPlayerLayer.self
        }
    }
    
   public var playerLayer: AVPlayerLayer{
        
        get{
            return self.layer as! AVPlayerLayer
        }
    }
    
   public  var player: AVPlayer? { //fd3E66
        
        get{
            return self.playerLayer.player
        }
        
        set{
            self.playerLayer.player = newValue
            if let _ = self.playerLayer.player {
                self.playerLayer.isHidden = false
            }else{
                self.playerLayer.isHidden = true
            }
        }
    }
   public var playerBackgroundColor: UIColor? {
        
        get {
            if let cgColor = self.playerLayer.backgroundColor {
                return UIColor(cgColor: cgColor)
            }
            return nil
        }
        
        set {
            self.playerLayer.backgroundColor = newValue?.cgColor
        }
    }
   public var playerFillModel:PlayerFillMode {
        
        get{
            return self.playerLayer.videoGravity
        }
        
        set {
            self.playerLayer.videoGravity = newValue
        }
    }
    
    public var isReadyForDisplay:Bool {
        get {
            return self.playerLayer.isReadyForDisplay
        }
    }
   
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.playerLayer.isHidden = true
        
        self.playerFillModel = PlayerFillMode.resizeAspect
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.playerLayer.isHidden = true
        self.playerFillModel = PlayerFillMode.resizeAspect
    }
    
    deinit {
        self.player?.pause()
        self.player = nil
    }
}
