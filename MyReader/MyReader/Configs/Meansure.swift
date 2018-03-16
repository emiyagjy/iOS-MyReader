//
//  Meansure.swift
//  boilerplate-swift
//
//  Created by GujyHy on 2018/2/28.
//  Copyright © 2018年 Gujy. All rights reserved.
//

import UIKit

let kStatusBarH: CGFloat = UIApplication.shared.statusBarFrame.size.height

let kScreenW = UIScreen.main.bounds.width
let kScreenH = UIScreen.main.bounds.height
let kMeasureScale = UIScreen.main.scale

let kNaviBarHeight : CGFloat = isPhoneX ? 88 : 64
let kTabBarHeight  : CGFloat = isPhoneX ? 49 + 34 : 49

let isPhone4  = kScreenH  <  568 ? true : false
let isPhone5  = kScreenH  == 568 ? true : false
let isPhone6  = kScreenH  == 667 ? true : false
let isPhone6P = kScreenH  == 736 ? true : false
let isPhoneX  = kScreenH  == 812 ? true : false

let kScreenWidthRatio  = (kScreenW / 375.0)    // 设计根据iphone6进行适配
let kScreenHeightRatio = (kScreenH / 667.0)

let kSingleLineWidth           =   1 / kMeasureScale
let kSingleLineAdjustOffset    =   (1 / kMeasureScale) / 2

let kCommonPageSize:Int  = 10
let kCommonPageSizeThirty:Int  = 30

func AdaptedWidthValue(x:CGFloat) -> CGFloat {
    let result = ceilf(Float(x)) * kScreenWidthRatio
    return result
}

func AdaptedHeightValue(x:CGFloat) -> CGFloat {
    var  result:CGFloat = 0
    if isPhoneX {
        result = CGFloat(ceilf(Float(x)))
    }else{
        result = ceilf(Float(x)) * kScreenHeightRatio
    }
    return result
}

func kSystemFontWithSize(s:CGFloat) -> UIFont {
    let font = UIFont.systemFont(ofSize: AdaptedWidthValue(x: s))
    return font
}
func kSystemBoldFontWithSize(s:CGFloat) -> UIFont {
    var font = UIFont.boldSystemFont(ofSize: AdaptedWidthValue(x: s))
    if #available(iOS 8.2, *) {
        font = UIFont.systemFont(ofSize: AdaptedWidthValue(x: s), weight: .bold)
    }
    return font
}
