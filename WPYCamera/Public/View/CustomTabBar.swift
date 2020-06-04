//
//  CustomTabBar.swift
//  WPYCamera
//
//  Created by 王鹏宇 on 4/15/19.
//  Copyright © 2019 王鹏宇. All rights reserved.
//

import UIKit

protocol CustomTabBarDelegate:class {
    
    func selectIndex(index : Int);
    func midAction();
}

class CustomTabBar: UIView {

    var delegate:CustomTabBarDelegate?
    var currentBtn:CustomItem?
    var count = 0
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   
    func setup(titles:Array<String>){
        
        let width = kScreenWidth / CGFloat(titles.count)
        let height:CGFloat = 49.0
        var i = 0
        count = titles.count
        
        for title in titles {
            
            
            
           
            if i == count / 2 {
                let btn = UIButton(frame: CGRect(x: width * CGFloat(i), y: 0, width: width, height: height))
                 btn.setImage(UIImage(named: title), for: .normal)
                 btn.addTarget(self, action: #selector(midBtnAction), for: UIControl.Event.touchUpInside)
                self.addSubview(btn)
//                btn.backgroundColor = UIColor.red
            }else{
                let btn = CustomItem(frame: CGRect(x: width * CGFloat(i), y: 0, width: width, height: height))
                btn.addTarget(self, action: #selector(tapAction(sender:)), for: UIControl.Event.touchUpInside)
                btn.setTitleColor(UIColor.lightText, for: UIControl.State.normal)
                btn.setTitleColor(UIColor.white, for: UIControl.State.selected)
                btn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
                
                if i < count / 2 {
                    btn.tag = 100 + i
                }else{
                    btn.tag = 99 + i
                }
                
                self.addSubview(btn)
                btn.setTitle(title, for: UIControl.State.normal)
            }
            i += 1
        }
        
        let topLine = UIView(frame: CGRect(x: 0, y: 0, width: kScreenHeight, height: 0.5))
        self.addSubview(topLine)
        topLine.backgroundColor = UIColor.groupTableViewBackground.withAlphaComponent(0.3)
    }
    @objc func tapAction(sender:CustomItem){
        
        let index = sender.tag - 100
        
        self.delegate?.selectIndex(index: index)
        
        
        if self.currentBtn != nil {
            
            self.currentBtn?.isSelected = false
            self.currentBtn?.lineView.isHidden = true
            self.currentBtn?.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        }
        
        sender.isSelected = true
        sender.lineView.isHidden = false
        sender.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        self.currentBtn = sender
    }
    
    func select(index:Int){
        
        let btn = self.viewWithTag(index + 100) as! CustomItem
        
        self.tapAction(sender: btn)
    }
    
    @objc func midBtnAction(){
        
        self.delegate?.midAction()
    }

    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}


import SnapKit

class CustomItem: UIButton {
    
    var lineView:UIView!
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setup(){
        
      
        lineView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 2))
        lineView.backgroundColor = UIColor.groupTableViewBackground
        self.addSubview(lineView)
        self.lineView.isHidden = true
        
        lineView.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.snp.centerX)
            make.bottom.equalTo(self.snp.bottom)
            make.width.equalTo(35)
            make.height.equalTo(2)
        }
        
        
    }
}
