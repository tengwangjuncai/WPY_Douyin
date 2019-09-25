//
//  CommentVC.swift
//  WPYCamera
//
//  Created by 王鹏宇 on 4/29/19.
//  Copyright © 2019 王鹏宇. All rights reserved.
//

import UIKit

class CommentVC: BaseVC {
    
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var boradView: UIView!
    @IBOutlet weak var editeView: UILabel!
    @IBOutlet weak var findBtn: UIButton!
    @IBOutlet weak var faceBtn: UIButton!
    
    @IBOutlet weak var boardViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var closeView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
       self.contentView.layer.cornerRadius = 8
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(closeAction(_:)))
        self.closeView.addGestureRecognizer(tap)
        
        if ISiPhoneX {
            self.boardViewHeight.constant = 84
        }else {
            self.boardViewHeight.constant = 50
        }
    }


    @IBAction func closeAction(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
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
