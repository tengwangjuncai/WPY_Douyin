//
//  Util.swift
//  WPYCamera
//
//  Created by 王鹏宇 on 4/15/19.
//  Copyright © 2019 王鹏宇. All rights reserved.
//

import UIKit


let kScreenWidth = UIScreen.main.bounds.size.width
let kScreenHeight = UIScreen.main.bounds.size.height

let kNavhHeight = ISiPhoneX ? 84 : 64

let kTabBarHeight = ISiPhoneX ? 83 : 49

let kBottomHeight = ISiPhoneX ?  34 : 0

let VideoKey = "videoKey"


var ISiPhoneX:Bool {
    
    guard #available(iOS 11.0, *) else { return false}
    
    let inset = UIApplication.shared.windows.first?.safeAreaInsets
    
    return (inset!.bottom > 0)
}

class Util: NSObject {

    

}
