//
//  JYSandBox.swift
//  boilerplate
//
//  Created by GujyHy on 2018/3/12.
//  Copyright © 2018年 Gujy. All rights reserved.
//

import UIKit


 // ducment ，持久数据一般都存在此目录下
let documentPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true).first

// temp ，临时文件夹，重启时会被清除
let cachesPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true).first

// library 存储程序的默认设置或其它 状态信息
let libraryPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true).first
