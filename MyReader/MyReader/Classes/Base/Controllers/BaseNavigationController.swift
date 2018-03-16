//
//  BaseNavigationController.swift
//  boilerplate-swift
//
//  Created by GujyHy on 2018/3/1.
//  Copyright © 2018年 Gujy. All rights reserved.
//

import UIKit

class BaseNavigationController: UINavigationController {
    var popDelegate: UIGestureRecognizerDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.popDelegate = self.interactivePopGestureRecognizer?.delegate
        self.delegate = self
        
    }
    // 
    override var childViewControllerForStatusBarStyle: UIViewController {
        return self.topViewController!
    }

}

extension BaseNavigationController : UINavigationControllerDelegate{
    //UINavigationControllerDelegate方法
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        //实现滑动返回功能
        if viewController == self.viewControllers[0] {
            self.interactivePopGestureRecognizer!.delegate = self.popDelegate
        }
        else {
            self.interactivePopGestureRecognizer!.delegate = nil
        }
    }
}
