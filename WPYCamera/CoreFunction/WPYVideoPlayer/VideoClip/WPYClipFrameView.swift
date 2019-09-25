//
//  WPYClipFrameView.swift
//  WPYCamera
//
//  Created by 王鹏宇 on 3/1/19.
//  Copyright © 2019 王鹏宇. All rights reserved.
//

import UIKit

let kItemHeight = CGFloat(50)
let kItemWith = kItemHeight * 2 / 3
let kBgColor = UIColor(red: 253/255.0, green: 203/255.0, blue: 0/255.0, alpha: 1.0)

class WPYClipFrameView: UIView {

    
    private var leftView:UIView!
    private var rightView:UIView!
    private var borderView:UIView!
    
    var validRect:CGRect = CGRect.zero {
        didSet{
            
            leftView.frame = CGRect(x: validRect.origin.x, y: 0, width: kItemWith / 2, height: kItemHeight)
            
            rightView.frame = CGRect(x: (validRect.origin.x + validRect.size.width - kItemWith / 2), y: 0, width: kItemWith / 2, height: kItemHeight)
            borderView.frame = validRect
            
            self.setNeedsLayout()
        }
    }
    
    var editViewValidRectChanged:(()->Void)?
    var editViewValidRectEndChanged:(()->Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(){
        
        self.backgroundColor = UIColor.clear
       
        self.borderView = UIView(frame: self.bounds)
        self.borderView.layer.borderWidth = 2
        self.borderView.layer.borderColor = kBgColor.withAlphaComponent(0.7).cgColor
        self.borderView.backgroundColor = UIColor.clear
        self.addSubview(borderView)
        
        leftView = UIView(frame: CGRect(x: 0, y: 0, width: kItemWith/2, height: kItemHeight))
        leftView.backgroundColor = kBgColor.withAlphaComponent(0.7)
        leftView.isUserInteractionEnabled = true
        leftView.tag = 0
        self.addSubview(leftView)
        
        leftView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panAction(_:))))
        
        
        rightView = UIView(frame: CGRect(x: 0, y: 0, width: kItemWith/2, height: kItemHeight))
        rightView.backgroundColor = kBgColor.withAlphaComponent(0.7)
        rightView.isUserInteractionEnabled = true
        rightView.tag = 1
        self.addSubview(rightView)
        rightView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panAction(_:))))
        
    }
    
    @objc func panAction(_ gesture:UIPanGestureRecognizer){
        
        self.borderView.layer.borderColor = kBgColor.withAlphaComponent(0.7).cgColor
        
        var point = gesture.location(in: self)
        
        var rect = self.validRect
        
        let w = self.frame.width
        
        var minX = CGFloat(0)
        var maxX = w
        
        switch gesture.view?.tag ?? 0 {
        case 0://left
            maxX = rect.origin.x + rect.size.width - kItemWith
            point.x = max(minX,min(point.x,maxX))
            point.y = 0
            
            let width = rect.size.width - (point.x - rect.origin.x)
            if width < kItemWith * 3 {
                
                rect.origin.x = rect.maxX - kItemWith * 3
                rect.size.width = kItemWith * 3
                
            }else{
                rect.size.width = width
                rect.origin.x = point.x
            }
        
        case 1://right
            
            minX = rect.origin.x + kItemWith
            maxX = w - kItemWith / 2
            
            point.x = max(minX, min(point.x, maxX))
            point.y = 0
            
            rect.size.width = (point.x - rect.origin.x + kItemWith / 2)
            
            if rect.size.width < kItemWith * 3 {
                rect.size.width = kItemWith * 3
            }
        default:
            break
        }
        
        self.validRect = rect
        
        switch gesture.state {
        case .began,.changed:
            
            self.editViewValidRectChanged?()
        case .ended,.cancelled :
            
            self.layer.borderColor = UIColor.clear.cgColor
            self.editViewValidRectEndChanged?()
            
        default:
            break
        }
        
    
        
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        // 扩大下有效范围
        var left = leftView.frame
        left.origin.x = left.origin.x - kItemWith / 2
        left.size.width = left.size.width + kItemWith / 2
        
        var right = rightView.frame
        right.size.width = right.size.width + kItemWith / 2
        
        if left.contains(point){
            
            return leftView
        }
        
        if right.contains(point){
            
            return rightView
        }
        
        return nil
    }
    
//    override func draw(_ rect: CGRect) {
//
//        let context = UIGraphicsGetCurrentContext()
//
//        context?.clear(self.validRect)
//        context?.setStrokeColor(UIColor.orange.cgColor)
//        context?.setLineWidth(4.0)
//
//        let topPoints = [CGPoint(x: self.validRect.origin.x, y: 0),CGPoint(x: self.validRect.origin.x+self.validRect.size.width, y: 0)]
//
//        let bottomPoints = [CGPoint(x: self.validRect.origin.x, y: kItemHeight),CGPoint(x: self.validRect.origin.x + self.validRect.size.width, y: kItemHeight)]
//
//        context?.addLines(between: topPoints)
//        context?.addLines(between: bottomPoints)
//
//        context?.drawPath(using: .stroke)
//    }
}

