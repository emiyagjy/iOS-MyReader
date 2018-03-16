//
//  PDFBaseViewController.swift
//  MyReader
//
//  Created by GujyHy on 2018/3/11.
//  Copyright © 2018年 Gujy. All rights reserved.
//

import UIKit

class PDFBaseViewController: UIViewController {

    var customNaviView:PDFNavigationView!
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.customNavigationItem = UINavigationItem()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = tColor_app_background
        self.customNaviView = PDFNavigationView(self.customNavigationItem!)
        self.customNaviView.backgroundColor = tColor_app_theme
        self.view.addSubview(self.customNaviView)
        self.customNaviView.snp.makeConstraints { (make) in
            make.left.right.top.equalTo(self.view).offset(0)
            make.height.equalTo(kNaviBarHeight)
        }
    }

//    override func loadView() {
//        // 改变控制器自带 view 的目的
//        let newView = UIView(frame:UIScreen.main.bounds)
//        newView.backgroundColor = .blue
//        self.view = newView
//    }

}
