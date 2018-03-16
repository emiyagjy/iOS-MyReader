//
//  StringExtension.swift
//  boilerplate-swift
//
//  Created by GujyHy on 2018/2/28.
//  Copyright © 2018年 Gujy. All rights reserved.
//

import UIKit
import Foundation

extension String {
    static func className(_ aClass: AnyClass) -> String {
        return NSStringFromClass(aClass).components(separatedBy: ".").last!
    }
    func substring(from: Int) -> String {
        //        return self.substring(from: self.characters.index(self.startIndex, offsetBy: from))
        var newStr = ""
        let startIndex:Index = Index(encodedOffset: from)
        self.enumerateSubstrings(in: startIndex..<self.endIndex, options:.byComposedCharacterSequences) {
            (substring, substringRange, _, _) in
            newStr += substring!
        }
        return newStr
    }
    
    
    func substring(to: Int) -> String {
        //        return self.substring(from: self.characters.index(self.startIndex, offsetBy: from))
        var newStr = ""
        let endIndex:Index = Index(encodedOffset: to)
        self.enumerateSubstrings(in: self.startIndex..<endIndex, options:.byComposedCharacterSequences) {
            (substring, substringRange, _, _) in
            newStr += substring!
        }
        return newStr
    }
    
    var length: Int {
        return self.count
    }
    
    // 银行卡号转正常号 － 去除4位间的空格
    func bankNumToNormalNum() -> String{
        return self.replacingOccurrences(of: " ", with: "")
    }
    
    // 正常号转银行卡号 － 增加4位间的空格
    func normalNumToBankNum() -> String {
        var tmpStr = self.bankNumToNormalNum() as NSString
        let size:Int = tmpStr.length / 4
        var tmpStrArr = [Any]()
        for i in 0..<size {
            tmpStrArr.append(tmpStr.substring(with: NSMakeRange(i * 4, 4)))
        }
        tmpStrArr.append(tmpStr.substring(with: NSMakeRange(size * 4, (tmpStr.length % 4))))
        tmpStr = (tmpStrArr as NSArray).componentsJoined(by: " ") as NSString
        return tmpStr as String
    }
    
    
    //    // URL Decode
    //    func URLDecode() -> String? {
    ////        return self.stringByRemovingPercentEncoding // `stringByReplacingPercentEscapesUsingEncoding` is deprecated
    //    }
    //
    // URL Encode
    func URLEncode() -> String? {
        let allowedCharacterSet = (CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[] ").inverted)
        return self.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet)
        
    }
    
    
}
