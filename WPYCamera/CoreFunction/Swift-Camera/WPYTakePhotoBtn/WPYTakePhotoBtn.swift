//
//  WPYTakePhotoBtn.swift
//  WPYCamera
//
//  Created by 王鹏宇 on 1/7/19.
//  Copyright © 2019 王鹏宇. All rights reserved.
//

import UIKit

enum CameraStyle {
    
    case defult
    case takePhoto
    case clickVideo
    case pressVideo
}

protocol WPYTakePhotoBtnDelegate:NSObjectProtocol {
    
    func startRecordDelegate(_ sender:WPYTakePhotoBtn)
    func stopRecordDelegate(_ sender:WPYTakePhotoBtn)
    func takePhotoDelegate(_ sender:WPYTakePhotoBtn)
    func videoZoomFactor(_ zoom:CGFloat)
}



class WPYTakePhotoBtn: UIView {

    private var centerLayer : CAShapeLayer!
    private var tipLabel : UILabel!
    private var centerView : UIView!
    private var viewWidth : CGFloat!
    private var viewCenter : CGPoint!
    private var cameraStyle : CameraStyle = .defult
    private var isRecording : Bool = false
    private var originalCenter:CGPoint!
    
    weak var delegate: WPYTakePhotoBtnDelegate?
    
    var startTime : TimeInterval = 0.0
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        initUI()
    }
   
    override init(frame: CGRect){
        super.init(frame: frame)
        initUI()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }
    
    
    private func initUI(){
        
         viewCenter = CGPoint(x: frame.size.width / 2.0, y: frame.size.height / 2)
        
        viewWidth = frame.size.width
        originalCenter = self.center;
        
        let r = (viewWidth - 30) / 2.0
        let path = bezierPathBy(r,0.1)
        
        centerLayer = CAShapeLayer()
        centerLayer.path = path.cgPath
        
        centerLayer.fillRule = .evenOdd
        centerLayer.fillColor = UIColor(red: 255/255.0, green: 62/255.0, blue: 86/255.0, alpha: 1).cgColor
        self.layer.addSublayer(centerLayer)
        
        centerView = UIView(frame: CGRect(x: viewCenter.x - r, y: viewCenter.y - r, width: 2 * r, height: 2 * r))
        centerView.layer.cornerRadius = r;
        
        centerView.backgroundColor = UIColor(red: 255/255.0, green: 62/255.0, blue: 86/255.0, alpha: 1)
        self.addSubview(centerView)
        
        tipLabel = UILabel()
        tipLabel.textColor = UIColor.white
        tipLabel.text = "按住"
        
        tipLabel.font = UIFont.systemFont(ofSize: 14)
        tipLabel.sizeToFit()
        tipLabel.center = viewCenter
        
        self.addSubview(tipLabel)
        
        changeStyle(.clickVideo)
    }
    
    
}



extension WPYTakePhotoBtn{
    
    private func bezierPathBy( _ path1Radius:CGFloat, _ path2Redius:(CGFloat?))->UIBezierPath{
        
        let path1 = UIBezierPath(arcCenter: viewCenter, radius: path1Radius, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: false)
        
        guard let path2Redius = path2Redius else { return path1 }
        
        let path2 = UIBezierPath(arcCenter: viewCenter, radius: path2Redius, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: false)
        
        path1.append(path2)
        
        return path1
    }
    
    
    
    func changeStyle(_ style : CameraStyle){
        
        if style == cameraStyle {
            
            return
        }
        
        switch style {
        case .clickVideo:
            
            centerLayer.fillColor = UIColor(red: 255/255.0, green: 62/255.0, blue: 86/255.0, alpha: 1).withAlphaComponent(0.4).cgColor
            centerView.backgroundColor = UIColor(red: 255/255.0, green: 62/255.0, blue: 86/255.0, alpha: 1)
            tipLabel.isHidden = true
            centerView.isHidden = false
            if cameraStyle == .pressVideo || cameraStyle == .defult{
                showClickView()
            }
            
        case .pressVideo:
            
            self.originalCenter = self.center
            self.centerLayer.fillColor = UIColor(red: 255/255.0, green: 62/255.0, blue: 86/255.0, alpha: 1).cgColor
            centerView.backgroundColor = UIColor(red: 255/255.0, green: 62/255.0, blue: 86/255.0, alpha: 1)
            tipLabel.isHidden = false
            showPressView()
            
        case .takePhoto:
            
            centerLayer.fillColor = UIColor.white.withAlphaComponent(0.4 ).cgColor
            centerView.backgroundColor = UIColor.white
            centerView.isHidden = false
            tipLabel.isHidden = true
            if cameraStyle == .pressVideo || cameraStyle == .defult {
                
                showClickView()
            }
        default: break
            
        }
        
        cameraStyle = style
    }
    
    private func pathAnimation(layer:CALayer, fromValue:CGPath,toValue:CGPath, duration:CFTimeInterval,repeatCount:Float,autoreverss:Bool){
        
        let pathAnimation = CABasicAnimation(keyPath: "path")
        pathAnimation.fromValue = fromValue
        pathAnimation.toValue = toValue
        pathAnimation.autoreverses = autoreverss
        pathAnimation.duration = duration
        pathAnimation.repeatCount = repeatCount
        pathAnimation.fillMode = .forwards
        pathAnimation.isRemovedOnCompletion = false
        
        layer.add(pathAnimation, forKey: "path")
        
    }
    
    
    private func showClickView() {
        
        let r1 = (viewWidth - 20) / 2.0
        let r2 = (viewWidth - 30) / 2.0
        
        let path1 = bezierPathBy(r2, 0.1)
        let path2 = bezierPathBy(r1, r2)
        
        pathAnimation(layer: centerLayer, fromValue: path1.cgPath, toValue: path2.cgPath, duration: 0.25, repeatCount: 1, autoreverss: false)
        
        let r3 = (viewWidth - 40) / 2.0
        
        UIView.animate(withDuration: 0.25) {
            
            [weak self] in
            guard let `self` = self else { return }
            
            self.centerView.bounds = CGRect(x: 0, y: 0, width: 2 * r3, height: 2 * r3)
            self.centerView.layer.cornerRadius = r3
        }
        
    }
    
    private func showPressView(){
        
        let r1 = (viewWidth - 20) / 2.0
        let r2 = (viewWidth - 30) / 2.0
        
        let path1 = bezierPathBy(r1,r2)
        let path2 = bezierPathBy(r2, 0.1)
        
        
        pathAnimation(layer: centerLayer, fromValue: path1.cgPath, toValue: path2.cgPath, duration: 0.25, repeatCount: 1, autoreverss: false)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.25) {
            [weak self] in
            guard let `self` = self else {return}
            
            if self.cameraStyle == .pressVideo {
                self.centerView.isHidden = true
            }
        }
    }
    
    func startOrStopRecording(){
        
        if isRecording {
            
            if cameraStyle == .pressVideo{
                stopPressVideo()
            }else {
                Recording()
            }
        }
    }
    
    
    
    func stopPressVideo(){
        
        if cameraStyle == .pressVideo {
            
            self.delegate?.videoZoomFactor(1.0)
            
            UIView.animate(withDuration: 0.25) {
                [weak self] in
                guard let `self` = self else {return}
                self.center = self.originalCenter
            }
            
            let endTime = Date.init().timeIntervalSince1970
            let time = endTime - startTime
            
            if time < 1 {
                
            }
        }
        
        Recording()
    }
    
    func stop(){
        isRecording = false
        clickAnimation(isRecording)
    }
    
    func  Recording(){
    
        
        switch cameraStyle {

        case .takePhoto:
            self.delegate?.takePhotoDelegate(self)

        case .clickVideo:

            if isRecording {
                isRecording = false
                self.delegate?.stopRecordDelegate(self)
            }else {
                isRecording = true
                self.delegate?.startRecordDelegate(self)
            }

            clickAnimation(isRecording)

        case .pressVideo:

            if isRecording {

                isRecording = false
                self.delegate?.stopRecordDelegate(self)
            }else{
                isRecording = true
                self.delegate?.startRecordDelegate(self)
            }

            pressAnimation(isRecording)

        default:
            break
        }
    }
    
    private func pressAnimation(_ isStart:Bool){
        
        let r1 = (viewWidth - 20) / 2.0
        let r3 = (viewWidth  + 10) / 2.0
        let r4 = (viewWidth + 20) / 2.0
        
        let path1 = bezierPathBy(r1, 0.1)
        let path2 = bezierPathBy(r4, r3)
        
        var fromValue = path1
        var toValue = path2
        
        if !isStart {
            fromValue = path2
            toValue = path1
        }
        
        pathAnimation(layer: centerLayer, fromValue: fromValue.cgPath, toValue: toValue.cgPath, duration: 0.5, repeatCount: 1, autoreverss: false)
        
        UIView.animate(withDuration: 0.25) {
            
            [weak self] in
            guard let `self` = self else {return}
            
            self.tipLabel.alpha = isStart ? 0.0 : 1.0
        }
        
        if !isStart {
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            [weak self] in
            guard let `self` = self else { return }
            
            if(self.isRecording){
                self.breathAnimation()
            }
        }
        
    }
    
    
    private func clickAnimation(_ isStart:Bool){
        
        let r1 = (viewWidth - 20) / 2.0
        let r2 = (viewWidth - 30) / 2.0
        
        let r3 = viewWidth / 2.0
        let r4 = (viewWidth + 20) / 2.0
        
        let path1 = bezierPathBy(r1, r2)
        let path2 = bezierPathBy(r4, r3)
        
        var fromValue = path1
        var toValue = path2
        
        if !isStart {
            fromValue = path2
            toValue = path1
        }
        
        pathAnimation(layer: centerLayer, fromValue: fromValue.cgPath, toValue: toValue.cgPath, duration: 0.5, repeatCount: 1, autoreverss: false)
        
        let r5 = isStart ? (viewWidth / 3) / 2.0 : (viewWidth - 40) / 2.0
        
        
        UIView.animate(withDuration: 0.25) {
            [weak self] in
            guard let `self` = self else { return }
            
            self.centerView.bounds = CGRect(x: 0, y: 0, width: r5 * 2, height: r5 * 2)
            self.centerView.layer.cornerRadius = isStart ? 5 : r5
        }
        
        if !isStart {
            
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            [weak self] in
            guard let `self` = self else {return}
            
            if (self.isRecording){
                
                self.breathAnimation()
            }
        }
    }
    
    private func breathAnimation(){
        
        let r1 = (viewWidth + 10) / 2.0
        let r2 = (viewWidth + 20) / 2.0
        let r3 = (viewWidth) / 2.0
        
        let path1 = bezierPathBy(r2, r1)
        let path2 = bezierPathBy(r2, r3)
        
        pathAnimation(layer: centerLayer, fromValue: path1.cgPath, toValue: path2.cgPath, duration: 0.5, repeatCount: MAXFLOAT, autoreverss: true)
    }
}


extension WPYTakePhotoBtn {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if cameraStyle == .pressVideo {
            guard let touch = touches.first else {
                
                return
            }
            let point =  touch.location(in: self.superview)
            
            self.center = point
            startTime = Date.init().timeIntervalSince1970
            
            Recording()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if cameraStyle != .pressVideo {
            return
        }
        
        guard let touch = touches.first else {return}
        
        let point = touch.location(in: self.superview)
        
        self.center = point
        let disY = self.originalCenter.y - point.y
        
        var scale = disY / self.originalCenter.y + 1.0
        
        if scale < 1.0 {
            scale = 1.0
        }
        self.delegate?.videoZoomFactor(scale)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        stopPressVideo()
    }
}
