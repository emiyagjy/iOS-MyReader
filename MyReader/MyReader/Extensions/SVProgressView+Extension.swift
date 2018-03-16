//
//  SVProgressView+Extension.swift
//  MyReader
//
//  Created by GujyHy on 2018/3/12.
//  Copyright © 2018年 Gujy. All rights reserved.
//

import UIKit
import SVProgressHUD

extension SVProgressHUD {
    
 
    static func showHUD(withText text:String){
        SVProgressHUD.setMinimumSize(CGSize(width:AdaptedWidthValue(x: 100), height: AdaptedWidthValue(x: 100)))
        SVProgressHUD.setMinimumDismissTimeInterval(2)
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.showSuccess(withStatus: text)
    }
 
}
