//
//  RectView.swift
//   
//
//  Created by GujyHy on 2018/3/7.
//  Copyright © 2018年 Gujy. All rights reserved.
//

import UIKit

class JYCustomView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // 设置圆角半径值，默认为0
    var cornerRaidus:CGFloat = 0 {
        didSet{
            self.setNeedsDisplay()
        }
    }
    
    // 设置背景色
    var foreColor:UIColor = UIColor.white {
        didSet{
            self.setNeedsDisplay()
        }
    }
    
    // 设置边框色
    var borderColor:UIColor = UIColor.white {
        didSet{
            self.setNeedsDisplay()
        }
    }
    
    // 设置边框宽度
    var borderWidth:CGFloat = 0 {
        didSet{
            self.setNeedsDisplay()
        }
    }
    
    
    // 设置颜色
    override func draw(_ rect: CGRect) {
        
        // 获取画板
        let ctx = UIGraphicsGetCurrentContext()
        // 用 CGContextRef + UIBezierPath 绘制圆角
        let path = UIBezierPath(roundedRect: rect, cornerRadius: self.cornerRaidus
            )
        path.addClip()
        ctx?.addPath(path.cgPath)
        ctx?.setLineWidth(self.borderWidth)
        ctx?.setFillColor(self.foreColor.cgColor)
        ctx?.setStrokeColor(self.borderColor.cgColor)
        ctx?.drawPath(using: CGPathDrawingMode.fillStroke)
       
    }
    
}
