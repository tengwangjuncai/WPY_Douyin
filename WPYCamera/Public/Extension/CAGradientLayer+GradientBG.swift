//
//  CAGradientLayer+GradientBG.swift
//  ImGuider X
//
//  Created by llt on 2018/9/12.
//  Copyright © 2018年 imguider. All rights reserved.
//

import UIKit

enum GradientPosition {
    
    case topToBottom
    case bottomToTop
    case leftToRight
    case rightToLeft
    
    case topLeftToBottomRigth
    case bottomRigthToTopLeft
    case topRightToBottomLeft
    case bottomLeftToTopRight
}

extension CAGradientLayer {
    
    class func gradientLayer(colors:[UIColor], position:GradientPosition, frame:CGRect) -> CAGradientLayer {
        
        var start = CGPoint.zero
        var end = CGPoint.zero
        
        switch position {
            
        case .topToBottom:
            
            start = CGPoint(x: 0, y: 0)
            end = CGPoint(x: 0, y: 1)
        case .bottomToTop:
            
            start = CGPoint(x: 0, y: 1)
            end = CGPoint(x: 0, y: 0)
        case .leftToRight:
            
            start = CGPoint(x: 0, y: 0)
            end = CGPoint(x: 1, y: 0)
        case .rightToLeft:
            
            start = CGPoint(x: 1, y: 0)
            end = CGPoint(x: 0, y: 0)
        case .topLeftToBottomRigth:
            
            start = CGPoint(x: 0, y: 0)
            end = CGPoint(x: 1, y: 1)
        case .bottomRigthToTopLeft:
            
            start = CGPoint(x: 1, y: 1)
            end = CGPoint(x: 0, y: 0)
        case .topRightToBottomLeft:
            
            start = CGPoint(x: 1, y: 0)
            end = CGPoint(x: 0, y: 1)
        case .bottomLeftToTopRight:
            
            start = CGPoint(x: 0, y: 1)
            end = CGPoint(x: 1, y: 0)
        }
        
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.colors = colors.compactMap({$0.cgColor})
        gradientLayer.startPoint = start
        gradientLayer.endPoint = end
        gradientLayer.frame = frame
        
        return gradientLayer
    }
}

