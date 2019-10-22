//
//  MyCamera.swift
//  MyImGuider
//
//  Created by 王鹏宇 on 10/15/18.
//  Copyright © 2018 王鹏宇. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import HXPhotoPicker
import CoreMotion

enum ErrorType {
    
    case initDeviceError(msg:String?)
    case otherError(msg:String?)
}

class Camera: UIViewController,AVCapturePhotoCaptureDelegate,WPYTakePhotoBtnDelegate {
   
    
    @IBOutlet weak var flashBtn: UIButton!
    @IBOutlet weak var changeBtn: UIButton!
   
    @IBOutlet weak var takePhotoBtn: WPYTakePhotoBtn!
    
    @IBOutlet weak var selectContainView: UIView!
    @IBOutlet weak var selectStyleView: UIView!
    @IBOutlet weak var selectStyleCenterX: NSLayoutConstraint!
    
    @IBOutlet weak var takePhotoStyleBtn: UIButton!
    @IBOutlet weak var clickVideoStyleBtn: UIButton!
    @IBOutlet weak var pressVideoStyleBtn: UIButton!
    
    
    @IBOutlet weak var dotView: UIView!
   
    @IBOutlet weak var menuView: UIView!
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var selectMusicBtn: UIButton!
    @IBOutlet weak var tapFocusView: UIView!
    @IBOutlet weak var progress: UIProgressView!
    @IBOutlet weak var completeBtn: UIButton!
    
    @IBOutlet weak var deleteBtn: UIButton!
    
    @IBOutlet weak var uploadView: UIView!
    @IBOutlet weak var uploadBtn: UIButton!
    
    @IBOutlet weak var space: NSLayoutConstraint!
    @IBOutlet weak var midSpace: NSLayoutConstraint!
    
    var markViews = [UIView]()
    var completeHander:((_ image:UIImage?,_ videoURL:URL?,_ success:Bool) -> Void)?
    
//    private var handel:(([HXPhotoModel],SelectType)->Void)?
    
    var cameraStyle : CameraStyle = .clickVideo
    
    var imageView : UIImageView!
    var focusView : UIView!
    var image : UIImage = UIImage()
    
    // 捕获设备 通常是前置摄像头 后置摄像头， 麦克风（音频输入）
    var device : AVCaptureDevice?
    private var desiredPosition:AVCaptureDevice.Position = .back
    // AVCaptureDeviceInput 输入设备 它使用 AVCaptureDevice 来初始化
    var inputDevice : AVCaptureDeviceInput?
    // 当启动摄像头开始捕获输入
    var output : AVCaptureMetadataOutput?
    var imageOutPut : AVCaptureStillImageOutput?
    // 由它把输入输出结合在一起， 并开始启动捕获设备（摄像头）
    var videoDevice = AVCaptureDevice.default(for: AVMediaType.video)
    var audioDevice = AVCaptureDevice.default(for: AVMediaType.audio)
    var audioInput : AVCaptureInput?
    var movieFileOutput:AVCaptureMovieFileOutput = AVCaptureMovieFileOutput()
    var previewLayer : AVCaptureVideoPreviewLayer!
    
    private var motionManager: CMMotionManager?
    private var orientation: AVCaptureVideoOrientation = .portrait
    
    //保存所有的录像片段数组
    var videoAssets = [AVAsset]()
    //保存所有的录像片段 url 数组
    var assetURLs = [String]()
    var videoDurations = [Float]()
    var appendIndex: Int32 = 1
    var session : AVCaptureSession!
    var framePerSecond = 30
    
    
    var timer:Timer?
    var type:Int = 2
    var isComplete : Bool = false
    var isFlashOn : Bool = false
    var canCa : Bool = false
    var hadDuration:Float = 0
    var currentDuration:Double = 0
    var maxDuration:Float = 15 {
        didSet{
            movieFileOutput.maxRecordedDuration = CMTimeMake(value: Int64(maxDuration * 600), timescale: 600)
        }
    }
    var remainingTime : TimeInterval = 15.0 {
        didSet{
             movieFileOutput.maxRecordedDuration = CMTimeMake(value: Int64(remainingTime * 600), timescale: 600)
        }
    }
    
    var isRecording : Bool = false
    var oldX:CGFloat = 0
    var musicUrl:String?
    
    var zoomFactor:CGFloat? {
        
        didSet {
            guard let device = device else {return}
            guard var zoom = zoomFactor else {return}
            
            let maxZoom = device.activeFormat.videoMaxZoomFactor - 10
            if zoom > maxZoom {
                zoom = maxZoom
            }
            
            if zoom < 1.0 {
                zoom = 1.0
            }
            
            try! device.lockForConfiguration()
            
            device.ramp(toVideoZoomFactor: zoom, withRate: 10)
            
            device.unlockForConfiguration()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        IsOk()
        setup()
        initCamera()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = true
    }

    
    //界面初始化操作
    
    func setup(){
        
        self.completeBtn.layer.cornerRadius = 20
        self.completeBtn.clipsToBounds = true
        self.space.constant = (UIScreen.main.bounds.width / 2 - 134) / 3
        self.midSpace.constant = (UIScreen.main.bounds.width / 2 - 134) / 3
        self.completeBtn.isHidden = true
        self.deleteBtn.isHidden = true
        
        self.navigationController?.navigationBar.isHidden = true
        
        self.dotView.layer.cornerRadius = 3
        self.flashBtn.isHidden = true
        focusView = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        focusView.layer.cornerRadius = 40
        
        focusView.layer.borderColor = UIColor.white.withAlphaComponent(0.95).cgColor
        focusView.layer.borderWidth = 1.0
        focusView.backgroundColor = UIColor.clear
        self.view.addSubview(focusView)
        focusView.isHidden = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(focusGesture(tap:)))
        
        self.tapFocusView.addGestureRecognizer(tap)
        
        flashBtn.setImage(UIImage(named: "闪光灯-关"), for: .normal)
        isFlashOn = false
        
        self.takePhotoBtn.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(becomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(enterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    
    @objc private func enterBackground() {
        
        self.takePhotoBtn.Recording()
        
    }
    
    @objc private func becomeActive() {
        
       self.takePhotoBtn.Recording()
        
    }
    
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func goBigImage(){
        
        setupBrowser(images: [self.image], index: 0)
    }
    
   
    func videoRecordFinish(videoUrl: URL?,error:ErrorType?){
        
        takePhotoBtn.Recording()
        
        guard let url = videoUrl else {
            
            self.completeHander?(nil,nil,false)
            
            return
        }
        
        if (self.progress.progress * maxDuration) < 2 {
            
            print("录制时间过短")
            UIView.animate(withDuration: 0.25) {
                [weak self] in
                guard let   `self` = self else {return}
                
                self.progress.progress = 0
            }
            return
        }
//        self.completeHander?(nil,url,true)
        self.finishVide(url: url)
    }
    
    
    func finishVide(url:URL){
        
        let playVC = playVideoVC()
        playVC.videoURL = url
        self.navigationController?.pushViewController(playVC, animated: true)
    }

   
    
}



//--------------------------照相机 界面的响应操作---------------------

extension Camera {
    
    
    
    @objc func focusGesture(tap : UITapGestureRecognizer){
        
        let point = tap.location(in: tap.view)
        self.focusAtPoint(point: point)
    }
    
    @IBAction func changeCamera(_ sender: UIButton) {
        
        self.changeFrontOrBackCamera()
    }
    
    @IBAction func back(_ sender: UIButton) {
        
        if self.assetURLs.count > 0 && self.markViews.count > 0 && self.videoDurations.count > 0 {
            
             self.showSheet()
        }else{
            self.dismiss(animated: true, completion: nil)
        }
    
    }
    
    @IBAction func selectMusic(_ sender: UIButton) {
        
          guard let path = Bundle.main.path(forResource: "真的不容易.mp3", ofType: nil) else {return}
        
        MusicPlayerManager.playManager.playMusic(url: path)
        self.musicUrl = path
        
        session.beginConfiguration()
        self.session.removeInput(self.audioInput!)
        session.commitConfiguration()
        print("---------------已经选好背景音乐")
    }
    
    
    @IBAction func flashAction(_ sender: UIButton) {
        
        self.flashAction(sender)
    }
    
    
    func showSheet(){
        
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        let exit = UIAlertAction(title: "退出", style: UIAlertAction.Style.default) { (item) in
            
            self.dismiss(animated: true, completion: nil)
        }
        
        let cancel = UIAlertAction(title: "取消", style: UIAlertAction.Style.cancel, handler: nil)
        
        let reset = UIAlertAction(title: "重新录制", style: UIAlertAction.Style.destructive) { (item) in
            
            
            self.reset()
        }
        
        sheet.addAction(cancel)
        sheet.addAction(reset)
        sheet.addAction(exit)
        
        self.present(sheet, animated: true, completion: nil)
    }
    
    
    func takePhotosAction() {
        
        let status = PHPhotoLibrary.authorizationStatus()
        if status == PHAuthorizationStatus.authorized {
            
            self.shutterCamera()
            return
        }
        
        PHPhotoLibrary.requestAuthorization { status in
            
            if status == PHAuthorizationStatus.restricted || status == PHAuthorizationStatus.denied || status == PHAuthorizationStatus.notDetermined {
                
                let alertVC = UIAlertController(title: "提示", message: "照片权限，未授权", preferredStyle: UIAlertController.Style.actionSheet)
                
                let goAction =  UIAlertAction(title: "去设置", style: UIAlertAction.Style.default) { (UIAlertAction) in
                    
                    if  let url = URL(string: UIApplication.openSettingsURLString){
                        if UIApplication.shared.canOpenURL(url){
                            UIApplication.shared.openURL(url)
                        }
                    }
                }
                alertVC.addAction(goAction)
                self.present(alertVC, animated: true, completion: nil)
                
            }else {
                self.shutterCamera()
            }
        }
    }
    
    @IBAction func changePhotoStyle(_ sender: UIButton) {
        
        if sender == clickVideoStyleBtn {
            changeStyle(.clickVideo)
            
        }else if sender  == pressVideoStyleBtn {
            changeStyle(.pressVideo)
        }else {
            changeStyle(.takePhoto)
        }
    }
    
    private func changeStyle(_ style:CameraStyle){
        cameraStyle = style
        
        let width = self.selectStyleView.frame.width / 3.0
        
        if style == .clickVideo {
            
            selectStyleCenterX.constant = 0
            self.progress.isHidden = false
            self.selectMusicBtn.isHidden = false
            self.flashBtn.isHidden = true
        }else if style == .pressVideo {
            
            selectStyleCenterX.constant = -width
            self.progress.isHidden = false
            self.selectMusicBtn.isHidden = false
            self.flashBtn.isHidden = true
            
        }else {
            self.progress.isHidden = true
            self.selectMusicBtn.isHidden = true
            self.flashBtn.isHidden = false
            selectStyleCenterX.constant = width
        }
        takePhotoBtn.changeStyle(cameraStyle)
        
        UIView.animate(withDuration: 0.25) {
            [weak self] in
            guard let `self` = self else {return}
            
            self.view.layoutIfNeeded()
        }
        
    }
    
    
    func startRecordDelegate(_ sender: WPYTakePhotoBtn) {
        

        self.startRecording()
        self.selectContainView.isHidden = true
        self.uploadView.isHidden = true
        self.selectMusicBtn.isHidden = true
       
    }
    
    func stopRecordDelegate(_ sender: WPYTakePhotoBtn) {
        
        self.stopRecording()
    }
    
    func takePhotoDelegate(_ sender: WPYTakePhotoBtn) {
        
        self.takePhotosAction()
    }
    
    func videoZoomFactor(_ zoom: CGFloat) {
        
        self.zoomFactor = zoom
    }

    
    func addMarkViewWith(duration:Float){
        
        let x = (UIScreen.main.bounds.width - 32.0) * CGFloat(duration)/15.0 - 2.0
        
        let markView = UIView(frame: CGRect(x: x, y: 0, width: 3, height: 5))
            markView.backgroundColor = UIColor.white
        self.markViews.append(markView)
        
        self.progress.addSubview(markView)
    }
    
    func resetProgressView(duration:Float){
        
        if let view = self.markViews.last {
            
            view.removeFromSuperview()
            
            self.markViews.removeLast()
        }
        self.progress.setProgress(duration/15, animated: true)
        self.hadDuration = duration
        self.remainingTime = TimeInterval(maxDuration - duration)
        if hadDuration == 0 {
            self.deleteBtn.isHidden = true
            self.uploadView.isHidden = false
            self.completeBtn.isHidden = true
            self.selectContainView.isHidden = false
            self.selectMusicBtn.isHidden = false
        }
        self.videoDurations.removeLast()
    }
    
    @IBAction func deleteAction(_ sender: UIButton) {
        
        if self.assetURLs.count > 0 && self.videoDurations.count > 0{
            
            
            self.deleteSingleVideo()
            
            guard let duration =  self.videoDurations.last else{return}
            self.resetProgressView(duration:duration)
        }
    }
    
    @IBAction func completeAction(_ sender: UIButton) {
        
        if movieFileOutput.isRecording {
            self.stopRecording()
            self.isComplete = true
        }else{
            mergeVideos()
        }
        
    }
    
    @IBAction func uploadVideo(_ sender: UIButton) {
        
        let browser = HXPhotoManager(type:self.type == 1 ? .photo : .video )
        
        browser?.configuration.openCamera = false
        browser?.configuration.selectTogether = false
        browser?.configuration.cameraCellShowPreview = false
        browser?.configuration.navBarBackgroudColor = UIColor.black
        browser?.configuration.hideOriginalBtn = true
        
        if self.type == 2 {
            browser?.configuration.singleSelected = true
            browser?.configuration.singleJumpEdit = false
            browser?.configuration.videoCanEdit = false
            
            browser?.configuration.videoMaximumDuration = 15
            browser?.configuration.replaceVideoEditViewController = false
            
            
            browser?.configuration.shouldUseEditAsset = {
                [weak self] viewController,isFinish,manager,beforeModel in
                
                guard let `self` = self else {return}
                guard let asset = beforeModel?.asset else{ return }
                
                let editVC = WPYVideoClip(maxDuration: 15, vedio: nil, phAsset: asset)
                let nav = UINavigationController(rootViewController: editVC)
                editVC.completeHander = {
                    
                    [weak self] image,url,success in
//                    guard let `self` = self else { return }
                    
                    if success {
                        
//                        let afterModel = HXPhotoModel(videoURL: url)
//                        self.closeAll()
                    }
                }
                viewController?.present(nav, animated: true, completion: nil)
            }
        }else{
            
            browser?.configuration.photoMaxNum = 1
            browser?.configuration.deleteTemporaryPhoto = false
            browser?.configuration.lookLivePhoto = false
            browser?.configuration.lookGifPhoto = true
            browser?.configuration.saveSystemAblum = false
        }
        

       
        
        self.hx_presentSelectPhotoController(with: browser, didDone: {
            [weak self] allList, videoList, photoList, original, viewController, manager in
            guard let `self` = self else { return }
            
            
            if let list = allList{
                
                if let model = list.first{
                    
                    if model.subType == HXPhotoModelMediaSubType.video {

                        guard let asset = model.asset else{ return }

                        let editVC = WPYVideoClip(maxDuration: 15, vedio: nil, phAsset: asset)
//                        let nav = UINavigationController(rootViewController: editVC)

                       self.navigationController?.pushViewController(editVC, animated: true)
                    }
                }
            }
            
            
            
        
            
        }) { viewController, manager in
            
            
        }
       
    }
    
    
    private func closeAll(){
        
       var  rootVC = self.presentingViewController
        while (rootVC?.presentingViewController != nil) {
            
            rootVC = rootVC?.presentingViewController
        }
        
        rootVC?.dismiss(animated: false, completion: nil)
    }
}




//--------------------照相机 操作相关---------------------

extension Camera : AVCaptureFileOutputRecordingDelegate{
    
    
    // 检测是否有照相机权限
    
    func IsOk() {
        //相机权限
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        
        //此应用程序没有被授权访问的照片数据。可能是家长控制权限
        //用户已经明确否认了这一照片数据的应用程序访问
        if authStatus == AVAuthorizationStatus.restricted || authStatus == AVAuthorizationStatus.denied {
            
            let alertVC = UIAlertController(title: "提示", message: "照相机权限，未授权", preferredStyle: UIAlertController.Style.actionSheet)
            
            let goAction =  UIAlertAction(title: "去设置", style: UIAlertAction.Style.default) { (UIAlertAction) in
                
                if  let url = URL(string: UIApplication.openSettingsURLString){
                    if UIApplication.shared.canOpenURL(url){
                        UIApplication.shared.openURL(url)
                    }
                }
            }
            alertVC.addAction(goAction)
            self.present(alertVC, animated: true, completion: nil)
        }
    }
    
    // 照相机初始化
    
    func initCamera(){
        
        //使用AVMediaType.video 指明self.device 代表视频 默认使用后置摄像头进行初始化
        
        
        for dev in AVCaptureDevice.devices(for: .video) {
            
            if dev.position == desiredPosition{
                
                self.device = dev
                break
            }
        }
        
        guard let dev = self.device else {
            
            return
        }
        
        
        //使用设备初始化输入
        self.inputDevice = try? AVCaptureDeviceInput(device:device!)
        
        //生成输出对象
        self.output = AVCaptureMetadataOutput()
        self.imageOutPut = AVCaptureStillImageOutput()
        
//        let videoInput = try! AVCaptureDeviceInput(device: self.videoDevice!)
        self.audioInput = try! AVCaptureDeviceInput(device: self.audioDevice!)
        //生成会话，用来结合输出
        self.session = AVCaptureSession()
        
        
//        if self.session.canSetSessionPreset(AVCaptureSession.Preset(rawValue: "AVCaptureSessionPreset1280x720")){
//
//            self.session.sessionPreset = .photo
//        }
        
//        if self.session.canAddInput(videoInput){
//            self.session.addInput(videoInput)
//        }
        
        if self.session.canAddInput(self.audioInput!){
            self.session.addInput(self.audioInput!)
        }
        
        if self.session.canAddInput(self.inputDevice!){
            self.session.addInput(self.inputDevice!)
        }
        
        if self.session.canAddOutput(self.imageOutPut!){
            
            self.session.addOutput(self.imageOutPut!)
        }
        
        if self.session.canAddOutput(movieFileOutput){
            
            session.addOutput(movieFileOutput)
        }
        
        //使用 self.session. 初始化预览层  self.session负责驱动input信息采集layer
        //负责把图像渲染显示
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
        self.previewLayer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        self.previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.view.layer.insertSublayer(self.previewLayer, below: self.tapFocusView.layer)
        
        //开始启动
        self.session.startRunning()
        
        
        
        if (try? device?.lockForConfiguration()) != nil {
            
            if (device?.isFlashModeSupported(.auto)) != nil {
                device?.flashMode = .auto
                
            }
            //自动白平衡
            if device?.isWhiteBalanceModeSupported(.autoWhiteBalance) ?? false{
                
                device?.whiteBalanceMode = .autoWhiteBalance
            }
            
            if device!.isExposurePointOfInterestSupported{
                
                device?.exposureMode = .continuousAutoExposure
            }
            
            if let flag = device?.hasFlash{
                
                if !flag {return}
            }
            
            if device?.flashMode == .on || device?.flashMode == .off {
                
                device?.flashMode = .off
                self.isFlashOn = false
                self.flashBtn.setImage(UIImage(named: "闪光灯-关")
                    , for: .normal)
            }
            
            device?.unlockForConfiguration()
            
            remainingTime = TimeInterval(maxDuration)
        }
        
    }
    
    
    // 照相机聚焦操作
    
    func focusAtPoint(point : CGPoint){
        
        let size = self.view.bounds.size
        let  focusPoint = CGPoint(x: point.y / size.height, y: 1 - point.x / size.width)
        
        if ((try? device?.lockForConfiguration()) != nil) {
            
            if let flag = self.device?.isFocusModeSupported(AVCaptureDevice.FocusMode.autoFocus),flag == true {
                self.device?.focusPointOfInterest = focusPoint
                self.device?.focusMode = AVCaptureDevice.FocusMode.autoFocus
            }
            
            if let flag2 = self.device?.isExposureModeSupported(AVCaptureDevice.ExposureMode.autoExpose),flag2 == true {
                
                self.device?.exposurePointOfInterest = focusPoint
                self.device?.exposureMode = AVCaptureDevice.ExposureMode.autoExpose
            }
            
            self.device?.unlockForConfiguration()
            self.focusView.center = point
            self.focusView.isHidden = false
            self.focusView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            UIView.animate(withDuration: 0.3, animations: {
                
                self.focusView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                
            }) { (finished) in
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: {
                    self.focusView.isHidden = true
                })
            }
            
        }
    }
    
    // 照相机 拍照操作
    
    func shutterCamera(){
        
        let videoConnection : AVCaptureConnection? = imageOutPut?.connection(with: AVMediaType.video)
        
        if videoConnection == nil {
            print("take photo failed")
            
            return
        }
        
        self.imageOutPut?.captureStillImageAsynchronously(from: videoConnection!) { (_ imageDataSampleBuffer : CMSampleBuffer?, _ error : Error?) in
            
            if imageDataSampleBuffer == nil {
                return
            }
            
            guard let imageData : Data = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer!) else {return} //照片数据流
            
            if let sampleImage = UIImage(data: imageData){
                self.image = sampleImage
                
                self.saveImageToPhotoAlbum(image: self.image)
                
                self.goBigImage()
                
            }
        }
        
    }
    
    
    //保存图片到照片墙
    
    func saveImageToPhotoAlbum(image : UIImage){
        
        UIImageWriteToSavedPhotosAlbum(image, self,  #selector(saveImage(image:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc private func saveImage(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject) {
        
        if error != nil{
            print("图片保存失败")
        }else{
            
        }
    }
    
    
   // 切换前后摄像头
    
    func changeFrontOrBackCamera() {
        
        //1 获取之前的摄像头
        guard var position = self.inputDevice?.device.position else {return}
        //2 获取当前应该显示的镜头
        position = position == .front ? .back : .front
        
        //3 创建新的device
        
        let devices = AVCaptureDevice.devices(for: AVMediaType.video)
        guard let device = devices.filter({$0.position == position}).first else {
            return
        }
        
        let animation = CATransition()
        animation.duration = 0.5
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        animation.type = CATransitionType(rawValue: "oglFlip")
        
        animation.subtype = (position == .front) ? CATransitionSubtype.fromLeft : CATransitionSubtype.fromRight
        
        //4 根据新的device创建新的input
        guard let videoInput = try? AVCaptureDeviceInput(device: device) else {return}
        
        self.previewLayer .add(animation, forKey: nil)
        //5 在session中 切换 inout
        session.beginConfiguration()
        session.removeInput(self.inputDevice!)
        if session.canAddInput(videoInput){
            session.addInput(videoInput)
        }
        
        session.commitConfiguration()
        
        self.inputDevice = videoInput
    }
    
    //切换 闪光灯
    
    func changeFlash(_ sender:UIButton){
        
        guard let device = inputDevice?.device else {return}
        
        if device.isFlashAvailable {
            try? device.lockForConfiguration()
        }
        
        switch device.flashMode.rawValue {
        case 0:
            device.flashMode = AVCaptureDevice.FlashMode.on
            sender.setImage(UIImage(named: "闪光灯-开")
                , for: .normal)
            break
        case 1:
            device.flashMode = AVCaptureDevice.FlashMode.auto
            sender.setImage(UIImage(named: "闪光灯-关")
                , for: .normal)
            break
        default:
            
            device.flashMode = AVCaptureDevice.FlashMode.off
            sender.setImage(UIImage(named: "闪光灯-关")
                , for: .normal)
        }
        
        device.unlockForConfiguration()
    }
    
    
    // 开始录像
    
    func startRecording(){
        
        if movieFileOutput.isRecording {
            return
        }
        
        guard let path = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true).first else {
            
             print("----------------初始化失败")
            return
        }
        
        let filePath = "\(path)/temp-\(appendIndex).mov"
        appendIndex += 1
        
        let outputURL = URL(fileURLWithPath: filePath)
        let fileManager = FileManager.default
        if(fileManager.fileExists(atPath: filePath)){
            do{
                try fileManager.removeItem(atPath: filePath)
            } catch _{
                
            }
        }
        
        guard let movieConnection = movieFileOutput.connection(with: AVMediaType.video) else {
            
            print("------------------初始化失败")
            return
        }
        
        movieConnection.videoScaleAndCropFactor = zoomFactor ?? 1.0
        
        movieFileOutput.startRecording(to:outputURL, recordingDelegate: self )
        
        if MusicPlayerManager.playManager.currentUrl != nil {
             MusicPlayerManager.playManager.play()
        }
    }
    
    // 停止录像
    
    func stopRecording(){
        
        if movieFileOutput.isRecording {
            movieFileOutput.stopRecording()
            
            MusicPlayerManager.playManager.pause()
        }
    }
    
    
    /// 保存视频到相册
    ///
    /// - Parameters:
    ///   - outputFileURL: 视频缓存链接
    ///   - completionHandler: 成功、 错误
    func saveVideoToLibary(outputFileURL:URL,completionHandler: @escaping (Bool,ErrorType?) -> Swift.Void){
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputFileURL)
        }) { (success, error) in
            
            completionHandler(success,ErrorType.otherError(msg:error?.localizedDescription))
        }
    }
    
    
    
    
    
    //-----------------AVCaptureFileOutputRecordingDelegate-----------
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        
        self.isComplete = false
        self.backBtn.isHidden = true
        self.deleteBtn.isHidden = true
        self.menuView.isHidden = true
        startTimer()
        self.videoDurations.append(hadDuration)
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        
//        self.videoRecordFinish(videoUrl: outputFileURL, error: ErrorType.otherError(msg: error?.localizedDescription))
        
        let asset = AVURLAsset(url: outputFileURL, options: nil)
        var duration : TimeInterval = 0.0
        duration = CMTimeGetSeconds(asset.duration)
        print("生成视频片段：\(asset)")
        videoAssets.append(asset)
        assetURLs.append(outputFileURL.path)
        remainingTime = remainingTime - duration
        hadDuration = hadDuration + Float(duration)
        
        if self.deleteBtn.isHidden {
            self.deleteBtn.isHidden = false
            self.backBtn.isHidden = false
            self.menuView.isHidden = false
        }
        if remainingTime <= 0 || isComplete{
            
            self.deleteBtn.isHidden = false
            self.takePhotoBtn.stop()
            mergeVideos()
            
        }
        if remainingTime > 0 {
            self.addMarkViewWith(duration: hadDuration)
        }
        
        stopTimer()
    }
    
    private func startTimer(){
        
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    }
    
    private func stopTimer(){
        
        timer?.invalidate()
        timer = nil
    }
    
    @objc private func timerAction(){
        
        if !movieFileOutput.isRecording{
            
            return
        }
        
        currentDuration = CMTimeGetSeconds(movieFileOutput.recordedDuration)
        
       let  sumTime =  hadDuration + Float(currentDuration)
        var value = sumTime / maxDuration
        
        if value >= 1.0 {
            
            value = 1.0
        }
        
        if value >= 0.1 {
            self.completeBtn.isHidden = false
        }else{
            self.completeBtn.isHidden = true
        }
        self.progress.progress = value;
    }
    
    func mergeVideos(){
        
        MusicPlayerManager.playManager.pause()
        var duration:Float64 = 0
        
        let composition = AVMutableComposition()
        
        //  合并视频，音频轨道
        
        let firstTrack = composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: CMPersistentTrackID())
        
        var audioTrack:AVMutableCompositionTrack? = nil
       if self.musicUrl == nil {
          audioTrack  = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: CMPersistentTrackID())
        }
        
        
        var insertTime: CMTime = CMTime.zero
        
        for asset in videoAssets {
            
            print("合并视频片段：\(asset)")
            do {
                try firstTrack?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: asset.duration), of:asset.tracks(withMediaType: AVMediaType.video)[0], at: insertTime)
            }catch _ {
                
            }
            
            if audioTrack != nil {
                
                            do {
                
                                try audioTrack?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: asset.duration), of: asset.tracks(withMediaType: AVMediaType.audio)[0], at: insertTime)
                            }catch _{
                
                            }
            }
            insertTime = CMTimeAdd(insertTime, asset.duration)
            
            duration = CMTimeGetSeconds(insertTime)
        }
        
        //旋转视频图像，防止90度颠倒
        firstTrack?.preferredTransform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
        
        //获取合并后的视频路径
       
        
        let videoPath = WPYVideoEditManager.mergeVideoURL()
        
       

        let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPreset1280x720)!
        exporter.outputURL = videoPath
        exporter.outputFileType = AVFileType.mp4
        exporter.shouldOptimizeForNetworkUse = true
        exporter.timeRange = CMTimeRangeMake(start: CMTime.zero, duration: CMTimeMakeWithSeconds(duration, preferredTimescale:Int32(framePerSecond)))
        
    
        exporter.exportAsynchronously {
            
            DispatchQueue.main.async(execute: {
                if let url = exporter.outputURL {
                    self.finishVide(url: url)
                }
            })
           
        }
    }
    
    
    
    //重置各个参数，准备行的视频录制
    func reset(){
        
        for assetURL in assetURLs {
            
            if(FileManager.default.fileExists(atPath: assetURL)){
                do{
                    try FileManager.default.removeItem(atPath: assetURL)
                }catch _{
                    
                }
                print("删除视频片段:\(assetURL)")
            }
        }
        
        for view in markViews {
            
            view.removeFromSuperview()
        }
        
       self.resetConfig()
    }
    
    func deleteSingleVideo(){
        
        self.isComplete = false
        if let url = self.assetURLs.last {
            
            if(FileManager.default.fileExists(atPath: url)){
                do{
                    try FileManager.default.removeItem(atPath: url)
                }catch _{
                    
                }
                if appendIndex > 0 {
                    appendIndex = appendIndex - 1
                }
                print("删除视频片段:\(url)")
        }
        
             self.assetURLs.removeLast()
            self.videoAssets.removeLast()
        }
        
        
    }
    
    func resetConfig(){
        
        self.isComplete = false
        self.progress .setProgress(0, animated: true)
        videoAssets.removeAll(keepingCapacity: false)
        assetURLs.removeAll(keepingCapacity:false)
        videoDurations.removeAll(keepingCapacity: false)
        markViews.removeAll(keepingCapacity: false)
        appendIndex = 1
        self.hadDuration = 0
        self.deleteBtn.isHidden = true
        self.uploadView.isHidden = false
        self.completeBtn.isHidden = true
        self.selectContainView.isHidden = false
        self.selectMusicBtn.isHidden = false
        oldX = 0
        currentDuration = 0
        isRecording = false
        remainingTime = TimeInterval(maxDuration)
    }
}




//-------------------------------------------------------------------


import SKPhotoBrowser

// MARK: - 配置点击浏览大图
extension UIViewController : SKPhotoBrowserDelegate {
    
    
    private struct BrowserStoreKey {
        
        static var browserViewKey = "browserViewKey"
    }
    
    private var browserView:((_ index:Int) -> UIView?)? {
        
        set {
            
            objc_setAssociatedObject(self, &BrowserStoreKey.browserViewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            
            return objc_getAssociatedObject(self, &BrowserStoreKey.browserViewKey) as? ((Int) -> UIView?)
        }
    }
    
    func setupBrowser(images:[Any]?,index:Int,browserView:((_ index:Int) -> UIView?)? = nil) {
        
        guard let images = images else { return }
       
        DispatchQueue.once(token: "skconfig") {
            SKPhotoBrowserOptions.displayAction = false
            SKPhotoBrowserOptions.displayStatusbar = true
            SKPhotoBrowserOptions.displayCounterLabel = true
            SKPhotoBrowserOptions.displayBackAndForwardButton = true
            SKPhotoBrowserOptions.enableSingleTapDismiss = true
            SKPhotoBrowserOptions.displayStatusbar = true
        }
        
        self.browserView = browserView
        
        let photos = images.compactMap { image -> SKPhoto? in
            
            if let image = image as? String  {
                
                return SKPhoto.photoWithImageURL(image, holder: nil)
            }
            
            if let image = image as? UIImage {
                
                return SKPhoto.photoWithImage(image)
            }
            
            return nil
        }
        
        let browser = SKPhotoBrowser(photos: photos, initialPageIndex: index)
        browser.cancelTitle = "cancel"
        browser.delegate = self
//        browser.setNavBarStyle(.transparency)
        
        self.present(browser, animated: true, completion: nil)
    }
    
    public func viewForPhoto(_ browser: SKPhotoBrowser, index: Int) -> UIView? {
        
        let view = self.browserView?(index)
        
        return view
    }
}



//extension DispatchQueue {
//
//    private static var onceTracker = [String]()
//
//    //Executes a block of code, associated with a unique token, only once.  The code is thread safe and will only execute the code once even in the presence of multithreaded calls.
//    public class func once(token: String, block: () -> Void)
//    {   // 保证被 objc_sync_enter 和 objc_sync_exit 包裹的代码可以有序同步地执行
//        objc_sync_enter(self)
//        defer { // 作用域结束后执行defer中的代码
//            objc_sync_exit(self)
//        }
//
//        if onceTracker.contains(token) {
//            return
//        }
//
//        onceTracker.append(token)
//        block()
//    }
//}

