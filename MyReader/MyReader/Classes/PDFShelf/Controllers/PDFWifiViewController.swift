//
//  PDFWifiViewController.swift
//  MyReader
//
//  Created by GujyHy on 2018/3/9.
//  Copyright © 2018年 Gujy. All rights reserved.
//

import UIKit
import SVProgressHUD

let PORT = 8888

class PDFWifiViewController: PDFBaseViewController {
    
    var webServer:GCDWebUploader!
    var internetReachability:Reachability!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customNavigationItem?.title = "Wifi 上传"
        self.bulidUI()
        self.buildData()
        self.initServer()
        self.configureReachability()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.reachabilityChanged, object: nil)
        self.stopWebServer()
    }

    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.reachabilityChanged, object: nil)
        self.stopWebServer()
    }
    
    // MARK: Private
    
    func bulidUI() {
        self.view.addSubview(self.bgView)
        self.bgView.snp.makeConstraints { (make) in
            make.top.equalTo(self.customNaviView.snp.bottom).offset(30)
            make.left.equalTo(self.view).offset(50)
            make.right.equalTo(self.view).offset(-50)
            make.height.equalTo(35)
        }
        self.bgView.addSubview(self.ipAddressLabel)
        self.ipAddressLabel.snp.makeConstraints { (make) in
            make.edges.equalTo(self.bgView).inset(UIEdgeInsets.zero)
        }
        self.view.addSubview(self.messageLabel)
        self.messageLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.bgView.snp.bottom).offset(30)
            make.left.right.equalTo(self.bgView)
        }
    }
    func buildData(){
        self.messageLabel.text = "小看PDF浏览器提供 Wi-Fi 传输共享数据服务，请在任意浏览器访问如上地址，上传的文件将被存放在手机本地"
        
    }
    
    func initServer () {
        self.webServer = GCDWebUploader(uploadDirectory: documentPath!)
        self.webServer.title                 = "小看PDF阅读器"
        self.webServer.prologue              = "欢迎使用小看PDF阅读器"
        self.webServer.allowedFileExtensions =  ["pdf"]
        self.webServer.footer                     = "";
        self.webServer.delegate                   = self
    }
    func startWebServer() -> Bool{
        return self.webServer.start(withPort: UInt(PORT), bonjourName: "")
    }
    func stopWebServer(){
        if self.webServer.isRunning {
            self.webServer.stop()
        }
    }
    
    func startWiFi() {
        // 开启服务
        if self.startWebServer() {
            self.ipAddressLabel.text = self.getIpAddressAddPort()
        }else{
            self.ipAddressLabel.text = "启动服务失败"
        }
    }
    
    func startWWAN() {
        self.stopWebServer()
        self.ipAddressLabel.text = "当前网络未能使用 Wi-Fi 传输服务"
    }
    
    // 获取 ip 地址 + 端口号
    func getIpAddressAddPort() -> String {
        return "http://\(SJXCSMIPHelper.deviceIPAdress()!):\(self.webServer.port)"
    }
    
    // MARK: Private
 
    func configureReachability(){
        
        self.internetReachability = Reachability.forInternetConnection()
        self.internetReachability.startNotifier()
        self.updateInterfaceWithReachability(self.internetReachability)
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged), name:NSNotification.Name.reachabilityChanged, object: nil)
    }
    func updateInterfaceWithReachability(_ reachability:Reachability) {
        let status:NetworkStatus = reachability.currentReachabilityStatus()
        switch status {
        case ReachableViaWiFi:
            self.startWiFi()
            break
        case ReachableViaWWAN:
            self.startWWAN()
            break
        default:
            break
        }
    }
    
    @objc func reachabilityChanged(_ notifi:Notification) {
        let reachability = notifi.object as! Reachability
        self.updateInterfaceWithReachability(reachability)
    }
    
    // MARK: lazy
    var bgView:JYCustomView = {
        let view = JYCustomView()
        view.cornerRaidus    = 15
        view.foreColor       = .black
        return view
    }()
    
    var ipAddressLabel:UILabel = {
        let label = UILabel()
        label.textColor     = UIColor.white
        label.textAlignment = .center
        label.font          = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    var messageLabel:UILabel = {
        let label = UILabel()
        label.textColor     = UIColor.gray
        label.textAlignment = .center
        label.font          = UIFont.systemFont(ofSize: 15)
        label.numberOfLines = 0
        return label
    }()
    
}

extension PDFWifiViewController: GCDWebUploaderDelegate {
    // 当文件下载完成后回调
    func webUploader(_ uploader: GCDWebUploader, didDownloadFileAtPath path: String) {
    }
    // 当文件上传后回调
    func webUploader(_ uploader: GCDWebUploader, didUploadFileAtPath path: String) {
        SVProgressHUD.showHUD(withText:"上传成功")
    }
    // 已经把文件删除
    func webUploader(_ uploader: GCDWebUploader, didDeleteItemAtPath path: String) {
        SVProgressHUD.showHUD(withText:"删除成功")
    }
    // 移动文件
    func webUploader(_ uploader: GCDWebUploader, didMoveItemFromPath fromPath: String, toPath: String) {
    }
    
}



