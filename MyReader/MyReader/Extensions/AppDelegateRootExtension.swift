
//
//  AppRootExtension.swift
//  boilerplate-swift
//
//  Created by GujyHy on 2018/2/28.
//  Copyright © 2018年 Gujy. All rights reserved.
//

import UIKit

extension AppDelegate {
    
    //  MARK: 全局设置UITabBar,UINaviBar样式
    
    func setAppTheme() {
        self.setNaviBarTheme()
        self.setTabBarItemTheme()
    }
    
    /**
     * 全局设置UINaviBar样式
     */
    func setNaviBarTheme(){
        // NavigationBar Color
        // 方法一: 有色差
        //        UINavigationBar.appearance().barTintColor = UIColor.red
        // 方法二： 设置背景图
        let image = UIImage.imageWithColor(tColor_app_theme)
        UINavigationBar.appearance().setBackgroundImage(image, for: UIBarMetrics.default) // e10000
        
        // Navigation Bar Text
        UINavigationBar.appearance().titleTextAttributes =
            [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 17),
             NSAttributedStringKey.foregroundColor:UIColor.white]
    }
    /**
     * 全局设置UITabBar样式
     */
    func setTabBarItemTheme(){
        
        let attriNor = [NSAttributedStringKey.foregroundColor:tColor_tabBar_title_color_nor,
                        NSAttributedStringKey.font:UIFont.systemFont(ofSize: 12)]
        
        let attriSel = [NSAttributedStringKey.foregroundColor:tColor_tabBar_title_color_sel,
                        NSAttributedStringKey.font:UIFont.systemFont(ofSize: 12)]
        
        UITabBarItem.appearance().setTitleTextAttributes(attriNor, for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes(attriSel, for: .selected)
    }
    
    
    
    /**
     *  window实例化
     */
    func setAppWindows(){
        
        self.window                  = UIWindow(frame: UIScreen.main.bounds)
        self.window?.backgroundColor = .white
    }
    
    /**
     *  设置根视图
     */
    func setRootViewController() {
        
        if let rootViewControlelr = self.rootViewController {
            self.window?.rootViewController = rootViewControlelr
            
        }else {
            self.window?.rootViewController = UIViewController()
            
        }
        self.window?.makeKeyAndVisible()
        
    }
    
    /**
     *  首次启动引导轮播图
     */
    func createGuildeScrollView(){
        
    }
    
}

