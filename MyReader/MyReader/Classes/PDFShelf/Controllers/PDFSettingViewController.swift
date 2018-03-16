//
//  PDFSettingViewController.swift
//  MyReader
//
//  Created by GujyHy on 2018/3/10.
//  Copyright © 2018年 Gujy. All rights reserved.
//

import UIKit

class PDFSettingViewController: UIViewController {

    
    var brightnessSlider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        brightnessSlider = UISlider()
 
        brightnessSlider.value = Float(UIScreen.main.brightness)
        brightnessSlider.minimumValueImage = UIImage(named:"BrightnessMin")
        brightnessSlider.maximumValueImage = UIImage(named:"BrightnessMax")
        brightnessSlider.maximumValue = 1
        brightnessSlider.minimumValue = 0
        brightnessSlider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        self.view.addSubview(brightnessSlider)
        
        brightnessSlider.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(self.view).offset(0)
            make.left.equalTo(self.view).offset(8)
            make.right.equalTo(self.view).offset(-8)
        }
    }
    
    @objc func sliderValueChanged(_ sender: UISlider) {
        UIScreen.main.brightness = CGFloat(brightnessSlider.value)
    }
    

}
