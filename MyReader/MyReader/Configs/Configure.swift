//
//  Configure.swift
//  boilerplate-swift
//
//  Created by GujyHy on 2018/3/1.
//  Copyright © 2018年 Gujy. All rights reserved.
//

import UIKit

let AppId = ""

// 命名空间
let AppName    = Bundle.main.object(forInfoDictionaryKey: "CFBundleExecutable") as! String
let AppVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
