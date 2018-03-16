//
//  JYTableViewCell.swift
//  MyReader
//
//  Created by GujyHy on 2018/3/13.
//  Copyright © 2018年 Gujy. All rights reserved.
//

import UIKit

class JYTableViewCell: UITableViewCell {

    
    
    var btmline:CALayer = {
        let layer = CALayer()
        layer.backgroundColor = tColor_line_gray.cgColor
        return layer
    }()
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.layer.addSublayer(self.btmline)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.btmline.frame = CGRect(x: 0, y: self.bounds.size.height - 1/kMeasureScale,
                                    width: kScreenW, height:1/kMeasureScale)
    }
    
    
}
