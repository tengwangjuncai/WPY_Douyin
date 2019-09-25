//
//  WPY_AVPlayer.swift
//  MyImGuider
//
//  Created by 王鹏宇 on 2018/9/13.
//  Copyright © 2018年 王鹏宇. All rights reserved.
//

import UIKit
import AVFoundation

import MediaPlayer



public enum AVPlayerPlayState {
    
    case AVPlayerPlayStatePreparing  // 准备播放
    case AVPlayerPlayStateBeigin      // 开始播放
    case AVPlayerPlayStatePlaying     // 正在播放
    case AVPlayerPlayStatePause     // 播放暂停
    case AVPlayerPlayStateEnd         // 播放结束
    case AVPlayerPlayStateBufferEmpty    // 没有缓存的数据供播放了
    case AVPlayerPlayStateBufferToKeepUp  //有缓存的数据可以供播放
    case AVPlayerPlayStateseekToZeroBeforePlay
    case AVPlayerPlayStateNotPlay     // 不能播放
    case AVPlayerPlayStateNotKnow    // 未知情况
}


public enum WPY_AVPlayerType {
    
    case PlayTypeLine  //景点，线路
    case PlayTypeSpecial //专题播放
    case PlayTypeTry     //试听
    case PlayTypeAnswer  //回答问题
    case PlayTypeDefult  //其他
}


protocol WPY_AVPlayerDelegate : class {
    
    func updateProgressWith(progress : Float)
    func changeMusicToIndex(index : Int)
    func updateBufferProgress(progress : Float)
}


//全局通知 name

let WPY_PlayerState = "WPY_PlayerState"
let CurrentPlayUrl = "CurrentPlayUrl"
let PlayType = "PlayType"


// 播放model    （可以替换自己的）

class Record: NSObject {
    var name:String?
    var imageUrl:String?
    var playpath:String?
    
}


class WPY_AVPlayer: NSObject {
    
    
    // player 单例
    static let playManager = WPY_AVPlayer()
    
    var player : AVPlayer = {
        let _player = AVPlayer()
        _player.volume = 2.0 //默认最大音量
        
        return _player
    }()// 播放器
    
    
    var playerView: WPYPlayView = WPYPlayView(frame: .zero)
    var playerItem : AVPlayerItem?  // 类似于播放磁碟
    var currentUrl : String?     //当前播放链接
    
    var isPlay : Bool = false //是否正在播放
    var isEnterBackground : Bool = false     //应用是否进入后台
    var seekToZeroBeforePlay : Bool = false  //播放前是否跳到 0
    
    var isImmediately : Bool = false   //是否立即播放
    var isEmptyBufferPause : Bool = false //没加载玩是否暂停
    var isFinish : Bool = false      //是否播放结束
    var isSeekingToTime : Bool = false // 是否正在拖动slide  调整播放时间
    var bgTaskId : UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier.invalid //后台播放申请ID
    var volume:Float = 0.5 {
        didSet{
            
            self.player.volume = volume
        }
    }
    
    var durantion : Float64 {
        
        
        if let duration = self.player.currentItem?.duration {
            return CMTimeGetSeconds(duration)
        }
        
        return  0.0
        
    }
    var progress : Float?  //播放进度
    var currentIndex : Int = 0   //当前播放
    
    //当你播放的不仅仅是音乐的话，而是多种类型的音频 例如： 试听，问题回答，音乐连续播 等等
    // 这时一定要提前分好类  会好一点
    
    var playType : WPY_AVPlayerType = WPY_AVPlayerType.PlayTypeTry  //1 景点，线路  2 专题播放  3 试听  4 回答问题 5 其他
    
    
    // 播放速度    改变播放速度
    
    var playSpeed : Float = 1.0 {
        
        didSet{
            if (self.isPlay){
                
                guard let playerItem = self.playerItem else {return}
                self.enableAudioTracks(enable: true, playerItem: playerItem)
                self.player.rate = playSpeed
            }
        }
    }
    
    
    // 音频播放数组  例如 多个需要连续播放的音频 用比较好
    
    var musicArray : [Record] = []
    weak var delegate : WPY_AVPlayerDelegate?
    var timeObserVer : Any?
    
    var currentScenicPoint : Record?
    
    var imageView = UIImageView() //为了设置锁屏封面
    private override init() {
        super.init()
        
        initPlayer()
    }
    
    
    func loadView(frame : CGRect,superView:UIView){
//        self.playerView.removeFromSuperview()
        
        
        superView.insertSubview(self.playerView, at: 0)
        self.playerView.frame = frame;
        self.playerView.playerLayer.frame = frame;
        self.playerView.playerLayer.isHidden = false
        self.playerView.playerFillModel = .resizeAspectFill
    }
    //播放器初始化
    
    func  initPlayer() {
        
        self.playSpeed = 1.0
        self.player.rate = 1.0
        
         self.playerView.playerLayer.player  = self.player;
        //APP进入后台通知
        NotificationCenter.default.addObserver(self, selector: #selector(configLockScreenPlay) , name:UIApplication.didEnterBackgroundNotification, object: nil)
        
//        let session = AVAudioSession.sharedInstance()
        
//        try? session.setActive(true)
        //后台播放
//        Util_OC.setAVAudioSessionCategory(.playback)
    }
    
    
    // 播放前增加配置 监测
    func currentItemAddObserver(){
        
//        //监听是否靠近耳朵
//        NotificationCenter.default.addObserver(self, selector: #selector(sensorStateChange), name:UIDevice.proximityStateDidChangeNotification, object: nil)
        
        //播放期间被 电话 短信 微信 等打断后的处理
//        NotificationCenter.default.addObserver(self, selector: #selector(handleInterreption(sender:)), name:AVAudioSession.interruptionNotification, object:AVAudioSession.sharedInstance())
        
        // 监控播放结束通知
        NotificationCenter.default.addObserver(self, selector: #selector(playMusicFinished), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player.currentItem)
        //监听状态属性 ，注意AVPlayer也有一个status属性 通过监控它的status也可以获得播放状态
        
        self.player.currentItem?.addObserver(self, forKeyPath: "status", options:[.new,.old], context: nil)
        
        //监控缓冲加载情况属性
        self.player.currentItem?.addObserver(self, forKeyPath:"loadedTimeRanges", options: [.new,.old], context: nil)
        
        self.timeObserVer = self.player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: DispatchQueue.main) { [weak self] (time) in
            
            guard let `self` = self else { return }
            
            let currentTime = CMTimeGetSeconds(time)
            self.progress = Float(currentTime)
            if self.isSeekingToTime {
                return
            }
        
            let total = self.durantion
            if total > 0 {
                self.delegate?.updateProgressWith(progress:Float(currentTime)  / Float(total))
            }
            
            
        }
    }
    
    
     // 播放后   删除配置 监测
    
    func currentItemRemoveObserver(){
        self.player.currentItem?.removeObserver(self, forKeyPath:"status")
        self.player.currentItem?.removeObserver(self, forKeyPath:"loadedTimeRanges")
        
//        NotificationCenter.default.removeObserver(self, name:UIDevice.proximityStateDidChangeNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
//        NotificationCenter.default.removeObserver(self, name:AVAudioSession.interruptionNotification, object: nil)
        
        if(self.timeObserVer != nil){
            self.player.removeTimeObserver(self.timeObserVer!)
        }
        
    }
    
    
    //锁屏 或 退入后台 保持音频继续播放
    
    @objc func configLockScreenPlay() {
//        //设置并激活音频会话类别
//        let session = AVAudioSession.sharedInstance()
//
//        Util_OC.setAVAudioSessionCategory(.playback)
//        try? session.setActive(true)
//        //允许应用接收远程控制
//        UIApplication.shared.endReceivingRemoteControlEvents()
//        //设置后台任务ID
//        var  newTaskID = UIBackgroundTaskIdentifier.invalid
//        newTaskID = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
//        if (newTaskID != UIBackgroundTaskIdentifier.invalid) && (self.bgTaskId != UIBackgroundTaskIdentifier.invalid)  {
//            UIApplication.shared.endBackgroundTask(self.bgTaskId)
//        }
//
//        self.bgTaskId = newTaskID
        
        self.pause()
        
    }
    
    
    //监测是否靠近耳朵  转换声音播放模式
    
    @objc func sensorStateChange() {
        
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
//            
//            if UIDevice.current.proximityState == true {
//                
//                //靠近耳朵
//                Util_OC.setAVAudioSessionCategory(.playAndRecord)
//            }else {
//                //远离耳朵
//                Util_OC.setAVAudioSessionCategory(.playback)
//            }
//        }
    }
    
    
    // 处理播放音频是被来电 或者 其他 打断音频的处理
    
    @objc func handleInterreption(sender:NSNotification) {
        
        let info = sender.userInfo
        guard let type : AVAudioSession.InterruptionType =  info?[AVAudioSessionInterruptionTypeKey] as? AVAudioSession.InterruptionType else { return }
        
        if type == AVAudioSession.InterruptionType.began {
            
            self.pause()
        }else {
            guard  let options = info![AVAudioSessionInterruptionOptionKey] as? AVAudioSession.InterruptionOptions else {return}
            
            if(options == AVAudioSession.InterruptionOptions.shouldResume){
                self.pause()
            }
        }
    }
    
    
    // 单个音频播放结束后的逻辑处理
    
    @objc func playMusicFinished(){
        
//        
        self.seekToZeroBeforePlay = true
        self.isPlay = false
        self.updateCurrentPlayState(state: AVPlayerPlayState.AVPlayerPlayStateEnd)
        self.musicSeekToTime(time: 0)
        self.play()
        
//        if (self.playType == WPY_AVPlayerType.PlayTypeSpecial) {
//
//            self.next()
//        }
    }
}


extension WPY_AVPlayer {
    
    func resetPlaySeed(){
        self.playSpeed = 1.0
    }
    //设置播放速率
    func setPlaySpeed(playSpeed:Float) {
        
        if self.isPlay{
            self.enableAudioTracks(enable: true, playerItem: self.playerItem!)
            self.player.rate = playSpeed;
        }
        self.playSpeed = playSpeed
    }
    
    
    
    /// 改变播放速率  必实现的方法
    ///
    /// - Parameters:
    ///   - enable:
    ///   - playerItem: 当前播放
    func enableAudioTracks(enable:Bool,playerItem : AVPlayerItem){
        
        for track : AVPlayerItemTrack in playerItem.tracks {
            
            if track.assetTrack?.mediaType == AVMediaType.audio {
                
                track.isEnabled = enable
            }
        }
    }
    
    
    /// 对网络音频和本地音频 地址 做统一管理
    
    func loadAudioWithPlaypath(playpath: String) -> URL{
        
    
        
//        if let lineid = lineModel?.lineid,
//            let path = DownloadManager.share.getRecordPath(lineid: lineid, playpath: playpath) {
//
//            let url = URL(fileURLWithPath: path)
//
//            return url
//        }
//
//        return URL(string: playpath)!
        
        return URL(string: playpath)!
        
    }
    
    
    /// 播放视频
    ///
    /// - Parameter url: 视频连接
    
    func playVideo(url:URL){
        self.currentItemRemoveObserver() //移除上一首的通知 观察
        
        let playerItem = AVPlayerItem(url: url)
        
        self.playerItem = playerItem
        
        self.currentUrl = url.absoluteString
        self.isImmediately = true
        self.player.replaceCurrentItem(with: playerItem)
         self .currentItemAddObserver()
    }
    
    /// 用于播放单个音频   播放方法
    ///
    /// - Parameters:
    ///   - url: 播放地址
    ///   - type: 音频类型  （以便于播放多种类型的音频）
    
    func playMusic(url : String,type:WPY_AVPlayerType){
        
        self.playType = type // 记录播放类型 以便做出不同处理
        self.setPlaySpeed(playSpeed: 1.0) //播放前初始化倍速 1.0
        
        self.currentItemRemoveObserver() //移除上一首的通知 观察
        
        let playUrl = self.loadAudioWithPlaypath(playpath: url)
        
        let playerItem = AVPlayerItem(url: playUrl)
        
        self.playerItem = playerItem
        self.currentUrl = url
        self.isImmediately = true
        
        self.player.replaceCurrentItem(with: playerItem)
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
        self .currentItemAddObserver()
    }
    
    
    
    /// 用于播放多个音频的列表  播放方法
    ///
    /// - Parameters:
    ///   - index: 播放列表中的第几个音频
    ///   - isImmediately: 是否立即播放
    
    func playTheLine(index :Int,isImmediately :Bool){
        
        self.currentItemRemoveObserver()
        self.playType = .PlayTypeLine // 记录播放类型 以便做出不同处理
        
        let record = self.musicArray[index]
        
        guard let url = record.playpath else { return }
        let playUrl = self.loadAudioWithPlaypath(playpath:url )
        
        let playerItem = AVPlayerItem(url: playUrl)
        
        self.playerItem = playerItem
        self.currentUrl = url
        self.isImmediately = isImmediately
        self.currentScenicPoint = record
        self.currentIndex = index
        if !isImmediately {
            self.pause()
        }
        self.player.replaceCurrentItem(with: playerItem)
        
        self.currentItemAddObserver()
    }
    
    
    //停止  多用于退出界面时
    
    func stop(){
        self.pause()
        self.isImmediately = false
        self.currentUrl = nil
        UIApplication.shared.endReceivingRemoteControlEvents()
    }
    
    // 播放
    func play(){
        
        if self.seekToZeroBeforePlay {
            
            self.musicSeekToTime(time: 0.0)
            self.updateCurrentPlayState(state: AVPlayerPlayState.AVPlayerPlayStateseekToZeroBeforePlay)
            self.seekToZeroBeforePlay = false
        }

        self.isPlay = true
        self.player.play()
        self.updateCurrentPlayState(state: AVPlayerPlayState.AVPlayerPlayStatePlaying)
        //暂停是改了 播放速率  播放时及时改变播放倍速
        if self.playerItem != nil {
            self.enableAudioTracks(enable: true, playerItem: self.playerItem!)
        }
        self.player.rate = self.playSpeed
        self.setNowPlayingInfo()
    }
    
    
    /// 暂停
    func pause(){
        
        self.isPlay = false
        self.updateCurrentPlayState(state: AVPlayerPlayState.AVPlayerPlayStatePause)
        player.pause()
        self.setNowPlayingInfo()
    }
    
    
    /// 下一首
    func next(){
        
        if self.playType == WPY_AVPlayerType.PlayTypeLine || self.playType == WPY_AVPlayerType.PlayTypeSpecial {
            
            let index = self.currentIndex + 1
            let count = self.musicArray.count
            if index >= count {
                print("已是最后一首了")
                return
            }
            
            self.changeTheMusicByIndex(index: index)
        }
    }
    
    
    /// 上一首
    func previous(){
        
        if self.playType == WPY_AVPlayerType.PlayTypeLine || self.playType == WPY_AVPlayerType.PlayTypeSpecial {
            
            let index = self.currentIndex - 1
            if index < 0 {
                print("已是第一个了")
                return
            }
            self.changeTheMusicByIndex(index: index)
        }
    }
    
    /// 跳到 指定的时间点 播放
    ///
    /// - Parameter time: 指定时间点
    func musicSeekToTime(time :Float) {
        
        guard let durantion = self.player.currentItem?.duration, !durantion.isIndefinite else {
            return
        }
        
        let interval = CMTimeGetSeconds(durantion)
        
        self.isSeekingToTime = true
        if interval != 0 {
            
            let seekTime = CMTimeMake(value: Int64(Float64(time) * interval), timescale: 1)
            self.player.seek(to: seekTime) { (complete) in
                self.isSeekingToTime = false
                self.setNowPlayingInfo()
            }
        }else {
            
            let seekTime = CMTimeMake(value: 0, timescale: 1)
            self.player.seek(to: seekTime) { (complete) in
                self.isSeekingToTime = false
                self.setNowPlayingInfo()
            }
            self.progress = 0
        }
        
    }
    
    
    /// 设置锁屏时 播放中心的播放信息、
    
    func setNowPlayingInfo(){
        
        if (self.playType == .PlayTypeLine || self.playType == .PlayTypeSpecial) && self.currentScenicPoint != nil {
            
           
            var info = Dictionary<String,Any>()
            info[MPMediaItemPropertyTitle] = self.currentScenicPoint?.name ?? ""
            
            if let image = UIImage(named: "AppIcon"){
                info[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(image:image)//显示的图片
            }
            
//            if  let url = self.currentScenicPoint?.pictureArray?.first ,let image = UIImage(named: "AppIcon"){
//                imageView.kf.setImage(with: URL(string:url), placeholder: image, options: nil, progressBlock: nil) { (img, _, _, _) in
//
//                    if
//                    info[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(image:img)//显示的图片
//                }
//            }else{
//
//            }
            
            
            info[MPMediaItemPropertyPlaybackDuration] = self.durantion //总时长
            
            if let duration = self.player.currentItem?.currentTime() {
               info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(duration)
            }
           
            
            info[MPNowPlayingInfoPropertyPlaybackRate] = 1.0//播放速率
            
            MPNowPlayingInfoCenter.default().nowPlayingInfo = info
        }
    }
    
    
    
    /// 上一首 下一首切换时  以便于播放界面做相应的调整
    ///
    /// - Parameter index: 当前播放
    
    func changeTheMusicByIndex(index : Int){
        self.playTheLine(index: index, isImmediately: true)
        
        delegate?.changeMusicToIndex(index: index)
    }
    
    
    //    //后台操作   在delegate 或者 某个VC 中初始化
    
    //    override func remoteControlReceived(with event: UIEvent?) {
    //        guard let event = event else {
    //            print("no event\n")
    //            return
    //        }
    //
    //        if event.type == UIEventType.remoteControl {
    //            switch event.subtype {
    //            case .remoteControlTogglePlayPause:
    //                print("暂停/播放")
    //
    //            case .remoteControlPreviousTrack:
    //                print("上一首")
    //                self.previous()
    //            case .remoteControlNextTrack:
    //                print("下一首")
    //                self.next()
    //            case .remoteControlPlay:
    //                print("播放")
    //               self.play()
    //            case .remoteControlPause:
    //                print("暂停")
    //                self.pause()
    //            default:
    //                break
    //            }
    //        }
    //    }
    //
    
    
    
    
    /// 实时更新播放状态  全局通知（便于多个地方都用到音频播放，改变播放状态）
    ///
    /// - Parameter state: 播放状态
    
    func updateCurrentPlayState(state : AVPlayerPlayState){
        
        if self.currentUrl != nil {
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: WPY_PlayerState), object: nil, userInfo: [WPY_PlayerState : state,CurrentPlayUrl : self.currentUrl!,PlayType : self.playType])
            
        }else {
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: WPY_PlayerState), object: nil, userInfo: [WPY_PlayerState : state,CurrentPlayUrl : "",PlayType : self.playType])
        }
    }
    
    
    
    
    func timeFormatted(totalSeconds : Float64) -> String{
        
        let interval = TimeInterval(totalSeconds)
        
        return interval.durationText
    }
    
    /// 当前播放时间
    
    var currentTime : String {
        
        if let current = self.player.currentItem?.currentTime(){
            
            return timeFormatted(totalSeconds: CMTimeGetSeconds(current))
        }
        
        return ""
        
        
    }
    
    
    /// 播放音频总时长
    
    var totalTime : String {
        
        return self.timeFormatted(totalSeconds:self.durantion)
    }
    
    
    /// 观察者   播放状态  和  缓冲进度
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        let item = object as! AVPlayerItem
        
        if keyPath == "status" {
            //            var  status:AVPlayerItemStatus = AVPlayerItemStatus.unknown
            //            if change != nil {
            //
            //                let arr = change?[NSKeyValueChangeKey.newKey] as! Array<Any>
            //
            //                status = change?[NSKeyValueChangeKey.newKey] as! AVPlayerItemStatus
            //            }
            switch item.status {
            case AVPlayerItem.Status.readyToPlay:
                
                if isImmediately {
                    self.play()
                }else{
                    self.setNowPlayingInfo()
                }
            case AVPlayerItem.Status.failed,AVPlayerItem.Status.unknown:
                self.updateCurrentPlayState(state: AVPlayerPlayState.AVPlayerPlayStateNotPlay)
            }
        }else if keyPath == "loadedTimeRanges" {
            
            let array = item.loadedTimeRanges
            
            let timeRange = array.first?.timeRangeValue
            
            guard let start = timeRange?.start , let end = timeRange?.end else {
                return
            }
            
            let startSeconds = CMTimeGetSeconds(start)
            let durationSeconds = CMTimeGetSeconds(end)
            
            let totalBuffer = startSeconds + durationSeconds
            
            let total = self.durantion
            if totalBuffer != 0  && total != 0{
                
                delegate?.updateBufferProgress(progress: Float(totalBuffer) / Float(total))
                print("\(Float(totalBuffer) / Float(total))")
            }
        }
    }
}



extension TimeInterval {
    
    var durationText:String {
        
        if self.isNaN || self.isInfinite {
            
            return "00:00"
        }
        
        let hours = Int(self.truncatingRemainder(dividingBy: 86400) / 3600)
        let minutes = Int(self.truncatingRemainder(dividingBy: 3600) / 60)
        let seconds = Int(self.truncatingRemainder(dividingBy: 60))
        
        if hours > 0 {
            
            return String(format: "%i:%02i:%02i", hours, minutes, seconds)
        } else {
            
            return String(format: "%02i:%02i", minutes, seconds)
        }
    }
}






