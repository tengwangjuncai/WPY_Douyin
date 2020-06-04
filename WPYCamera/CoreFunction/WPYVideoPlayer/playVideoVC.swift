//
//  playVideoVC.swift
//  WPYCamera
//
//  Created by 王鹏宇 on 1/14/19.
//  Copyright © 2019 王鹏宇. All rights reserved.
//

import UIKit
import Photos
import HXPhotoPicker


class playVideoVC: BaseVC,WPYEditRecordViewDelegate{
    
    
   
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var VolumeView: UIView!
    @IBOutlet weak var originalSlider: UISlider!
    @IBOutlet weak var BGMSlider: UISlider!
    @IBOutlet weak var volumeBottomSpace: NSLayoutConstraint!
    
    @IBOutlet weak var turnVoluneBtn: UIButton!
    
    
    var videoURL:URL?
    var audioURL:URL?
    var player:WPY_AVPlayer?
    var recordView : WPYEditRecordView!
    var audioPlayer:AVAudioPlayer?
    var isMusicEditing: Bool = false
    var orignalVolume : Float = 0.5
    var BGMVolume : Float = 0.5
    var audioClipTime:TimeInterval = 0
    
    var isFrommRecord = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.isHidden = true
        // Do any additional setup after loading the view.
        
        self.player = WPY_AVPlayer.playManager
        //视频播放层
        self.player?.playerView.playerBackgroundColor = UIColor.black
        
        self.player?.loadView(frame:CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight), superView: self.view)
        
        let singleGesture = UITapGestureRecognizer(target: self, action: #selector(singleAction))
        singleGesture.numberOfTapsRequired = 1
       
        
        self.setup()
        if let url = videoURL {
            self.player?.playVideo(url: url)
//
//            guard let path = Bundle.main.path(forResource: "真的不容易.mp3", ofType: nil) else {return}
//
//            if(MusicPlayerManager.playManager.currentUrl != nil){
//                MusicPlayerManager.playManager.musicSeekToTime(time: 0)
//                MusicPlayerManager.playManager.play()
//            }else{
//                MusicPlayerManager.playManager.playMusic(url: path)
//                MusicPlayerManager.playManager.play()
//            }
            
            self.cutAudioAndPlay(start: 0)
            
            
        }else{
            
            print("没有视频连接")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.player?.play()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        self.audioPlayer?.stop()
        self.player?.pause()
    }
    
    deinit {
        
        self.player = nil
        self.audioPlayer = nil
    }
    
    func setup(){
        
        //音频剪辑层
        self.recordView = WPYEditRecordView(frame: CGRect(x: 0, y: UIScreen.main.bounds.height + 40, width: UIScreen.main.bounds.width, height: 210))
        
        self.recordView.delegate = self
        self.view.addSubview(self.recordView)
        
        
        self.VolumeView.isHidden = true
        //音量调节层
        self.originalSlider.value = orignalVolume
        self.BGMSlider.value = BGMVolume
        
        originalSlider.addTarget(self, action: #selector(changeOriginalVolume(_:)), for: UIControl.Event.valueChanged)
        BGMSlider.addTarget(self, action: #selector(changeBGMVolume(_:)), for: UIControl.Event.valueChanged)
        
        
        
    }
    
    func changePlay(audioStartTime:TimeInterval){
        
        self.player?.musicSeekToTime(time: 0)
        
        self.audioPlayer?.currentTime = audioStartTime
        self.audioPlayer?.play()
    }
    
    func setupAudio(){
        
        guard let path = Bundle.main.path(forResource: "真的不容易.mp3", ofType: nil) else {return}
        let audioUrl = URL(fileURLWithPath: path)
        do{
            self.audioPlayer = try AVAudioPlayer.init(contentsOf: audioUrl)
            self.audioPlayer?.numberOfLoops = -1
            self.audioPlayer?.volume = self.BGMVolume * 2
            self.audioPlayer?.prepareToPlay()
            
            self.audioPlayer?.play()
        }catch {
            
        }
        
    }
    func cutAudioAndPlay(start:TimeInterval){
        
         guard let path = Bundle.main.path(forResource: "真的不容易.mp3", ofType: nil) else {return}
        
        let audioUrl = URL(fileURLWithPath: path)
        let musicAsset = AVAsset(url:audioUrl)
        let musicTime = CGFloat(musicAsset.duration.value) / CGFloat(musicAsset.duration.timescale)
        
//        let videoAsset = AVAsset(url: self.videoURL!)
//        let videoTime = CGFloat(videoAsset.duration.value) / CGFloat(videoAsset.duration.timescale)
//
//        let time = (musicTime > videoTime) ? videoTime : musicTime
//
        let startTime = CMTimeMake(value: Int64(start), timescale: 1)
        let duration = CMTimeMake(value: Int64(15), timescale: 1)
       
        WPYVideoEditManager.cutWith(avAsset: musicAsset, audioPath: audioUrl, cropRange: CMTimeRangeMake(start: startTime, duration: duration), completed:{ (url, isSuccess) in
            
            if isSuccess,let musicUrl = url {
                do {
                    self.audioPlayer = try AVAudioPlayer.init(contentsOf: musicUrl)
                    self.audioPlayer?.numberOfLoops = -1
                    self.audioPlayer?.volume = self.BGMVolume * 2
                    self.audioPlayer?.prepareToPlay()
                    
                    self.audioPlayer?.play()
                    self.player?.musicSeekToTime(time: 0)
                }
                catch {
                    print(error)
                }
                
                self.audioURL = url
            }
        })
    }

    
    @objc func changeOriginalVolume(_ sender:UISlider){
    
       self.orignalVolume = sender.value * 2
        self.player?.volume = sender.value * 2
        
    }
    
   @objc func changeBGMVolume(_ sender:UISlider){
    self.audioPlayer?.volume = sender.value * 2
    self.BGMVolume = sender.value * 2
    }
    
    
    
    
    func volumeViewAppear(){
        
        self.volumeBottomSpace.constant = 0
        
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        }) { (finish) in
            self.backBtn.isHidden = true
            self.editBtn.isHidden = true
            self.turnVoluneBtn.isHidden = true
            self.nextBtn.isHidden = true
            
            self.VolumeView.isHidden = false
        }
    }
    
    func volumeViewDisappear(){
        self.volumeBottomSpace.constant = -240
        
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        }) { (finish) in
            self.backBtn.isHidden = false
            self.editBtn.isHidden = false
            self.turnVoluneBtn.isHidden = false
            self.nextBtn.isHidden = false
            
            self.VolumeView.isHidden = true
        }
    }
    
    func editViewAppear(){
        
        UIView.animate(withDuration: 0.3, animations: {
            self.recordView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - 244, width: UIScreen.main.bounds.width, height: 210)
        }) { (finish) in
            self.backBtn.isHidden = true
            self.editBtn.isHidden = true
            self.turnVoluneBtn.isHidden = true
            self.nextBtn.isHidden = true
            self.isMusicEditing = true
        }
    }
    
    func editViewDisappear(){
        UIView.animate(withDuration: 0.3, animations: {
            self.recordView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height + 40, width: UIScreen.main.bounds.width, height: 210)
        }) { (finish) in
            self.backBtn.isHidden = false
            self.editBtn.isHidden = false
            self.turnVoluneBtn.isHidden = false
            self.nextBtn.isHidden = false
            self.isMusicEditing = false
        }
        
    }
    
    
    @IBAction func turnVolumeAction(_ sender: UIButton) {
        
        self.volumeViewAppear()
    }
    
    @IBAction func completeTurnVolume(_ sender: UIButton) {
        self.volumeViewDisappear()
    }
    
    
    @IBAction func backAction(_ sender: UIButton) {
        
        if isFrommRecord {
            let alert = UIAlertController(title: "返回上一步将丢失当前效果是否返回？", message: "", preferredStyle: UIAlertController.Style.alert)
            let confirm = UIAlertAction(title: "确定", style: UIAlertAction.Style.default) { (item) in
                
                WPYVideoEditManager.deleteTheVideoWithPath(path: WPYVideoEditManager.mergeVideoPath())
                
                self.navigationController?.popViewController(animated: true)
            }
            
            let cancel = UIAlertAction(title: "取消", style: UIAlertAction.Style.default, handler: nil)
            
            alert.addAction(cancel)
            alert.addAction(confirm)
            
            self.present(alert, animated: true, completion: nil)
        }else{
            
            WPYVideoEditManager.deleteTheVideoWithPath(path: WPYVideoEditManager.mergeVideoPath())
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func musicEditAction(_ sender: UIButton) {
        
//        if(audioPlayer == nil){
//
//            self.setupAudio()
//        }
        self.editViewAppear()
    }
    
    
    @IBAction func nextAction(_ sender: UIButton) {
        
        MusicPlayerManager.playManager.pause()
        
        WPYVideoEditManager.audioVideMerge(audioURL: self.audioURL!, videoURL: self.videoURL!, audioVolume: self.audioPlayer?.volume ?? 0 , videoVolume: self.player?.volume ?? 1) { (outPath, isSuccess) in
            
//            self.saveVideoToLibary(outputFileURL:outPath, completionHandler: { (isfinish, error) in
//
//                if isfinish{
//
//                    print("保存成功")
//                }else{
//                    print("保存失败")
//                }
//            })
            
             DispatchQueue.main.async {
                
                if let model = HXPhotoModel(videoURL: outPath) {
                    
                    
                    let releaserVC = ReleaseVC()
                    releaserVC.model = model
                    self.navigationController?.pushViewController(releaserVC, animated: true)
                }
            }
            
        }
    }
    
    
    func saveVideoToLibary(outputFileURL:URL,completionHandler: @escaping (Bool,ErrorType?) -> Swift.Void){
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputFileURL)
        }) { (success, error) in
            
            completionHandler(success,ErrorType.otherError(msg:error?.localizedDescription))
        }
    }
    
    
    //# 音频剪辑代理方法-------------------------------------
    
    func completeEdit() {
        self.editViewDisappear()
    }
    
    func audioViewEndChanged(startTime: TimeInterval) {
        
//        changePlay(audioStartTime: startTime)
        
        cutAudioAndPlay(start: startTime)
    }
    
    @objc func singleAction(){
        
        if self.player!.isPlay {
            
            self.player?.pause()
        }else{
            self.player?.play()
        }
    }

    
   

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
