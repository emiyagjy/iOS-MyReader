//
//  PDFNavigationView.swift
//  MyReader
//
//  Created by GujyHy on 2018/3/11.
//  Copyright © 2018年 Gujy. All rights reserved.
//

import UIKit

class PDFNavigationView: UIView {


    fileprivate var naviBar  = UINavigationBar()
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(_ navigationItem:UINavigationItem) {
        self.init()
        self.addSubview(self.naviBar)
        self.naviBar.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(kStatusBarH)
            make.left.right.bottom.equalTo(self).offset(0)
        }
        self.naviBar.pushItem(navigationItem, animated: false)
    }
    
}
