//
//  UINavigationControllerExtension.swift
//  boilerplate-swift
//
//  Created by GujyHy on 2018/3/1.
//  Copyright © 2018年 Gujy. All rights reserved.
//

import UIKit

extension UINavigationController {
    
    func ex_pushViewController(_ viewController: UIViewController, animated: Bool) {
        viewController.hidesBottomBarWhenPushed = true
        self.pushViewController(viewController, animated: animated)
        if  self.childViewControllers.count > 1 {
            let imageName:String!
            if viewController.backItemStyle == .black{
                imageName = "ic_navibar_back_black"
            }else {
                imageName = "ic_navibar_back_white"
            }
            viewController.addNavigationLeftItemWithImage(imageName, target: self, action: #selector(popSelf))
        }
    }
    
    @objc func popSelf(){
        self.popViewController(animated: true)
    }
}
