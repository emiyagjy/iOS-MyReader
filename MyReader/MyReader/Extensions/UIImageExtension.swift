//
//  UIImageExtension.swift
//  boilerplate-swift
//
//  Created by GujyHy on 2018/2/28.
//  Copyright © 2018年 Gujy. All rights reserved.
//

import UIKit

extension UIImage {
    
    static func imageWithColor(_ color:UIColor) -> UIImage {
        
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    func imageWithCornerRadius(_ radius:CGFloat) -> UIImage {
        let rect = CGRect(origin: .zero, size: self.size)
        // 创建画板
        UIGraphicsBeginImageContextWithOptions(self.size, false, UIScreen.main.scale)
        // 用 Core Graphics 绘制 fps 60帧
        let context = UIGraphicsGetCurrentContext()!
        let path =  UIBezierPath(roundedRect: rect, cornerRadius: radius).cgPath
        context.addPath(path)
        context.clip()
        
        // 用 UIKit 绘制 fps 20帧
        //        let path =  UIBezierPath(roundedRect: rect, cornerRadius: radius)
        //        path.addClip()
        self.draw(in: rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
}


