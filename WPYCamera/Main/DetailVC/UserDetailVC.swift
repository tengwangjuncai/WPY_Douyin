//
//  UserDetailVC.swift
//  WPYCamera
//
//  Created by 王鹏宇 on 4/29/19.
//  Copyright © 2019 王鹏宇. All rights reserved.
//

import UIKit
import GKPageScrollViewSwift

class UserDetailVC: UITableViewController,SelectPageSectionViewDelegate,WPYContainerCellDelegate{
    
   
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var bgView: UIView!
    var bgImageView:UIImageView!
    
    @IBOutlet weak var headImgView: UIImageView!
    
    @IBOutlet weak var commonBtn: UIButton!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var addBtnWidth: NSLayoutConstraint!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var numLabel: UILabel!
    @IBOutlet weak var markLabel: UILabel!
    @IBOutlet weak var localtionLabel: UIButton!
    @IBOutlet weak var facCountLabel: UILabel!
    @IBOutlet weak var addCountLabel: UILabel!
    @IBOutlet weak var likerCountLabel: UILabel!
    
    var contentCell:WPYContainerCell!
    var sectionView:SelectPageSectionView!
    var canScroll:Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupContentCell()
        setup()
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
//        self.navigationController?.addTransitionGesture(with: self)
       self.navigationController?.addTransitionGesture(with: self, type: WPYTransitionType.rightPop)
    }
    
    func setupContentCell(){
        
        contentCell = WPYContainerCell(style: .default, reuseIdentifier: "WPYContainerCell")
        
        let videovc = AllVideosVC()
        self.addChild(videovc)
        
        let actvc = MyActVC()
        self.addChild(actvc)
        
        let uservc = AddUsersVC()
        self.addChild(uservc)
        contentCell.setup(arr: [videovc,actvc,uservc])
        
        contentCell.delegate = self
    }
    func setup(){
        
        self.title = "dddddd"
        self.statusBarStyle = .lightContent
        self.navBarTitleColor = UIColor.white
        self.navBarBarTintColor = UIColor.black
        self.navBarBackgroundAlpha = 1
        
        
        self.canScroll = true
        self.contentCell.canScroll = false
        
        
        self.bgImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 200))
        self.bgImageView.contentMode = .scaleAspectFill
        self.bgImageView.image = UIImage(named: "acountBg")
        self.bgView.addSubview(self.bgImageView)
        self.bgImageView.clipsToBounds = true
        
        self.headImgView.layer.cornerRadius = 45
        self.headImgView.layer.borderColor = UIColor(red: 32/255.0, green: 32/255.0, blue: 41/255.0, alpha: 1.0).cgColor
        
        self.headImgView.layer.borderWidth = 4
        self.cancelBtn.alpha = 0
        self.contentView.backgroundColor = UIColor(red: 32/255.0, green: 32/255.0, blue: 41/255.0, alpha: 1.0)
        
        if #available(iOS 11.0, *) {
            self.tableView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        if ISiPhoneX {
            
        }
        
        let arr = ["作品 \(arc4random()%100 + 5)","动态 \(arc4random()%100 + 5)","喜欢 \(arc4random()%200 + 10)"]
        self.sectionView = SelectPageSectionView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 44))
        self.sectionView.setup(titles: arr)
        self.sectionView.delegate = self
        
        let backBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
        backBtn.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        backBtn.setImage(UIImage(named: "返回"), for: UIControl.State.normal)
        backBtn.layer.cornerRadius = 18
        backBtn.clipsToBounds = true
        
        backBtn.addTarget(self, action: #selector(back), for: UIControl.Event.touchUpInside)
        let leftiItem = UIBarButtonItem(customView: backBtn)
        
//        self.navigationItem.leftBarButtonItem = leftiItem
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(scrollToTop), name: NSNotification.Name(rawValue: "kLeaveTopNtf"), object: nil)
        
    }
    
    @objc func scrollToTop(){
        
        self.canScroll = true;
        self.contentCell.setCanScroll(canscroll: false);
    }
    
    @objc func back(){
        
        self.sideMenuController?.hideRightViewAnimated()
    }
    
    func selectTheTab(index: Int) {
        
        self.contentCell.changeToVC(index: index)
    }
    
    func selectVC(index: Int) {
        
        self.sectionView.selectIndex(index: index)
    }
    
    @IBAction func addAction(_ sender: UIButton) {
        
        self.addBtnWidth.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.cancelBtn.alpha = 1.0
            self.view.layoutIfNeeded()
        }
    }
    @IBAction func cancelAction(_ sender: UIButton) {
        
        self.addBtnWidth.constant = 120
        UIView.animate(withDuration: 0.3) {
            self.cancelBtn.alpha = 0
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func commonAction(_ sender: UIButton) {
        
    
    }
    
    
//    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
//
//        let yOffet = scrollView.contentOffset.y
//        let H:CGFloat = 120
//
//        if yOffet <= 0 {
//
//            let factor = H - yOffet
//
//            let rect = CGRect(x: -(kScreenWidth * factor/H - kScreenWidth)/2, y: yOffet, width: kScreenWidth * factor / H, height: factor)
//
//            self.bgImageView.frame = rect
//        }
//
//        if (yOffet < H - CGFloat(kNavhHeight)){
//
//            let alpha = yOffet / (H - CGFloat(kNavhHeight))
//
//            self.navBarBackgroundAlpha = alpha
//        }else{
//
//            self.navBarBackgroundAlpha = 1
//        }
//
//
//        let tabOffsetY = self.tableView.rect(forSection: 0).origin.y - CGFloat(kNavhHeight)
//
//        print("========\(tabOffsetY)")
//
//        if scrollView.contentOffset.y > tabOffsetY {
//
//            scrollView.contentOffset = CGPoint(x: 0, y: tabOffsetY)
//
//            if self.canScroll {
//
//                self.canScroll = false
//                self.contentCell.setCanScroll(canscroll: true)
//            }else {
//
//                if(!self.canScroll){
//                    scrollView.contentOffset = CGPoint(x: 0, y: tabOffsetY)
//                }
//            }
//        }
//
//    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
   
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
//
//         Configure the cell...

        return self.contentCell
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return kScreenHeight - 44
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 44
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        return self.sectionView
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
