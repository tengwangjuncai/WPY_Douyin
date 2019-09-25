//
//  MusicPlayerManager.swift
//  WPYCamera
//
//  Created by 王鹏宇 on 1/17/19.
//  Copyright © 2019 王鹏宇. All rights reserved.
//

import UIKit

class MusicPlayerManager: NSObject {

    // player 单例
    static let playManager = MusicPlayerManager()
    
    var player : AVPlayer = {
        let _player = AVPlayer()
        _player.volume = 2.0 //默认最大音量
        
        return _player
    }()// 播放器
    
    var playerItem : AVPlayerItem?  // 类似于播放磁碟
    var currentUrl : String?     //当前播放链接
    
    
    

    /// 播放音频
    ///
    /// - Parameter url: 视频连接
    
    func playMusic(url:String){
       
        let playerItem = AVPlayerItem(url: URL(fileURLWithPath: url))
        
        self.currentUrl = url
        self.playerItem = playerItem
        self.player.replaceCurrentItem(with: playerItem)
//        self.play()
    }
    
    
    func play(){
        
        self.player.play()
    }
    
    func pause(){
        
        self.player.pause()
    }
    
    
    /// 跳到 指定的时间点 播放
    ///
    /// - Parameter time: 指定时间点
    func musicSeekToTime(time :Float) {
        
        guard let durantion = self.player.currentItem?.duration, !durantion.isIndefinite else {
            return
        }
        
        let interval = CMTimeGetSeconds(durantion)
        
       
        if interval != 0 {
            
            let seekTime = CMTimeMake(value: Int64(Float64(time) * interval), timescale: 1)
            self.player.seek(to: seekTime) { (complete) in
            }
        }else {
            
            let seekTime = CMTimeMake(value: 0, timescale: 1)
            self.player.seek(to: seekTime) { (complete) in
            }
        }
        
    }
    
}
