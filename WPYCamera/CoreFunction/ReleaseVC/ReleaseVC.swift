//
//  ReleaseVC.swift
//  WPYCamera
//
//  Created by 王鹏宇 on 4/19/19.
//  Copyright © 2019 王鹏宇. All rights reserved.
//

import UIKit

import HXPhotoPicker

import IQKeyboardManagerSwift

class ReleaseVC: BaseVC {
    
    @IBOutlet weak var inputTextView: IQTextView!
    
    @IBOutlet weak var videoImageView: UIImageView!
    
    var model:HXPhotoModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.navigationController?.navigationBar.isHidden = true
    }
    
    func setup(){
        
        self.title = "发布"
        self.inputTextView.placeholder = "这一刻的想法……"
        
        if let thumbImage = self.model?.thumbPhoto {
            
            self.videoImageView.image = thumbImage
        }
        
        let image = UIImage(named:"fanhui")?.withRenderingMode(.alwaysOriginal)
        
        let leftItem = UIBarButtonItem(image: image, style: UIBarButtonItem.Style.plain, target: self, action: #selector(back))
        
        self.navigationItem.leftBarButtonItem = leftItem
    }

    @IBAction func submit(_ sender: UIButton) {
        
        let model = WPYPhotoModel()
        model.name = "wpy"
        model.content = inputTextView.text
        model.videoUrl = self.model?.videoURL.absoluteString
        model.thumbImage = self.model?.thumbPhoto
        
        
        DBHelper.manager.insert(model: model)
        
        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popToRootViewController(animated: true)
        
    }
    
    @IBAction func preserve(_ sender: UIButton) {
    }
    
    
    @objc func back(){
        
        if  var path = self.model?.videoURL.absoluteString {
            
            path = String(path.suffix(path.count - 7))
            WPYVideoEditManager.deleteTheVideoWithPath(path: path)
        }
        
    
        self.navigationController?.popViewController(animated: true)
    }
}
