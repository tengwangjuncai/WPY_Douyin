//
//  SelectPageSectionView.swift
//  WPYCamera
//
//  Created by 王鹏宇 on 4/29/19.
//  Copyright © 2019 王鹏宇. All rights reserved.
//

import UIKit

protocol SelectPageSectionViewDelegate:NSObjectProtocol {
    
    func selectTheTab(index:Int)
}

class SelectPageSectionView: UIView {
    
    var titles:Array<String> = [String]()
    var currentIndex = 0
    var currentBtn:NavBtn?
    var delegate:SelectPageSectionViewDelegate?
    
    func setup(titles:Array<String>){
        
        self.backgroundColor = UIColor(red: 32/255.0, green: 32/255.0, blue: 41/255.0, alpha: 1.0)
       let width = kScreenWidth / CGFloat(titles.count)
        
        var i:CGFloat = 0
        
        for title in titles {
            
            
        let  btn = NavBtn(frame: CGRect(x:CGFloat(i * width), y: 0, width: width, height: 44))
            
            btn.tag = Int(i + 200)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            btn.setTitle(title, for: UIControl.State.normal)
            btn.setTitleColor(UIColor.lightText.withAlphaComponent(0.5), for: UIControl.State.normal)
            btn.setTitleColor(UIColor.white, for: UIControl.State.selected)
            btn.addTarget(self, action: #selector(selectTheButton(sender:)), for: UIControl.Event.touchUpInside)
            self.addSubview(btn)
            
            if Int(i) == currentIndex {
                btn.isSelected = true
                btn.lineView.isHidden = false
                currentBtn = btn
            }
            
            i += 1;
            
        }
       
        
    }
    
    func selectIndex(index:Int){
        
        guard let btn = self.viewWithTag(index + 200) as? NavBtn else {return}
        
        if currentBtn != nil {
            
            currentBtn?.isSelected = false
            currentBtn?.lineView.isHidden = true
        }
        
        btn.isSelected = true
        btn.lineView.isHidden = false
        
        currentBtn = btn
        currentIndex = index
    }
    
    
    @objc func selectTheButton(sender:NavBtn){
        
        let index = sender.tag - 200
        
        if currentBtn != nil {
            
            currentBtn?.isSelected = false
            currentBtn?.lineView.isHidden = true
        }
        
        sender.isSelected = true
        sender.lineView.isHidden = false
        
        currentBtn = sender
        currentIndex = index
        
        delegate?.selectTheTab(index: index)
    }

}




import SnapKit

class NavBtn: UIButton {
    
    var lineView:UIView!
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setup(){
        
        
        lineView = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 2))
        lineView.backgroundColor = UIColor(red: 253/255.0, green: 203/255.0, blue: 0/255.0, alpha: 1.0)
        self.addSubview(lineView)
        self.lineView.isHidden = true
        
        lineView.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.snp.centerX)
            make.bottom.equalTo(self.snp.bottom)
            make.width.equalTo(55)
            make.height.equalTo(1.5)
        }
    }
}
