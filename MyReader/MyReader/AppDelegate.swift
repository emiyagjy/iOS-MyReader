//
//  AppDelegate.swift
//  MyReader
//
//  Created by GujyHy on 2018/3/8.
//  Copyright © 2018年 Gujy. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var rootViewController:UIViewController?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
    
        self.setNaviBarTheme()
        self.setAppWindows()
        self.setHomeViewController()
        self.setRootViewController()
        
        self.configurePDF()
        
        return true

    }
    
    func setHomeViewController(){
        let vc = PDFShelfViewController()
        let nav = BaseNavigationController(rootViewController: vc)
//        nav?.navigationBar.isHidden = true
        nav.navigationBar.isHidden = true
        self.rootViewController = nav
    }
    
    func configurePDF() {
        
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask)[0]
//        let fileName = "Sample.pdf"
        let fileName  = "日本小学.pdf"
        
        // 把 App 下 pdf 文件 copy 到 应用 documents 目录下用用做测试
        if let localFilePath = Bundle.main.url(forResource: fileName, withExtension: nil){
            let toPath = documentDirectory.appendingPathComponent(fileName)
            if !fileManager.fileExists(atPath: toPath.path) {
                try? fileManager.copyItem(at: localFilePath, to: toPath)
            }
        }
    }

    
    // MARK: Cycle life
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

