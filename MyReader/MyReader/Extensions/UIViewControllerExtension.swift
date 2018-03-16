//
//  UIViewControllerExtension.swift
//  boilerplate-swift
//
//  Created by GujyHy on 2018/3/1.
//  Copyright © 2018年 Gujy. All rights reserved.
//

import UIKit

public enum UIViewControllerBackItemStyle : Int {
    case white
    case black
}


extension UIViewController {
    private struct AssociatedKeys {
        static var backItem  = "backItem"
        static var naviItem  = "naviItem"
    }
    // 自定义属性
    var backItemStyle:UIViewControllerBackItemStyle? {
        get{
            return objc_getAssociatedObject(self, &AssociatedKeys.backItem) as? UIViewControllerBackItemStyle
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &AssociatedKeys.backItem, newValue as UIViewControllerBackItemStyle?, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
                
            }
        }
    }
    
    var customNavigationItem:UINavigationItem? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.naviItem) as? UINavigationItem
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &AssociatedKeys.naviItem, newValue as UINavigationItem?, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    


    // MARK: NavigationItem
    // Text
    func addNavigationRightItemWithText(_ btnText:String,target: Any?,action: Selector) {
        let rightBarItem = UIBarButtonItem(title: btnText,
                                           titleColor:.white,
                                           titleFont: kSystemFontWithSize(s: 14),
                                           titleEdgeInsets: UIEdgeInsetsMake(0, 0, 0, 0),
                                           target: target,
                                           action: action)
        self.customNavigationItem?.rightBarButtonItem = rightBarItem
    }
    func addNavigationLeftItemWithText(_ btnText:String,target: Any?,action: Selector) {
        let leftBarItem = UIBarButtonItem(title: btnText,
                                          titleColor: .white,
                                          titleFont: kSystemFontWithSize(s: 14),
                                          titleEdgeInsets: UIEdgeInsetsMake(0, 0, 0, 0),
                                          target: target,
                                          action: action)
        self.customNavigationItem?.leftBarButtonItem = leftBarItem
    }
    // Image
    func addNavigationLeftItemWithImage(_ imageName:String,target: Any?,action: Selector) {
        let image = UIImage(named: imageName)!
        let leftBarItem = UIBarButtonItem(image: image, target: target, action: action)
        self.customNavigationItem?.leftBarButtonItem = leftBarItem
    }
    
    func addNavigationRightItemWithImage(_ imageName:String,target: Any?,action: Selector) {
        let image = UIImage(named: imageName)!
        let rightBarItem = UIBarButtonItem(image: image, target: target, action: action)
        self.customNavigationItem?.rightBarButtonItem = rightBarItem
    }

}
