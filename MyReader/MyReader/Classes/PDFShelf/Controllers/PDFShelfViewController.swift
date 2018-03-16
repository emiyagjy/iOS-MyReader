//
//  PDFShelfViewController.swift
//  MyReader
//
//  Created by GujyHy on 2018/3/8.
//  Copyright © 2018年 Gujy. All rights reserved.
//

import UIKit
import SnapKit

/*
 首页显示 PDF 列表
 */
class PDFShelfViewController: PDFBaseViewController {
    
    var documents   = [ReaderDocument] ()
    var fileManager = FileManager.default
    var deleteCellIndex:Int = 0
    
 
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customNavigationItem?.title = "小看 PDF 阅读器"
        self.addNavigationRightItemWithImage("ic_navibar_wifi", target: self, action: #selector(wifiAction))
        self.tableView.dataSource = self
        self.tableView.delegate   = self
        self.tableView.backgroundColor = .clear
        self.tableView.separatorStyle  = .none
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(self.view).offset(0)
            make.top.equalTo(self.customNaviView.snp.bottom).offset(0)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.refreshData()
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: Private
    fileprivate func refreshData() {
 
        // 读取 document 下的所有文件
        let contents:[URL] = try! fileManager.contentsOfDirectory(at: URL(fileURLWithPath: documentPath!), includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
        
        self.documents =  contents.flatMap{ ReaderDocument.withDocumentFilePath($0.path, password: "") }
        self.tableView.reloadData()
    }
    
    func getPDFName(_ fileName:String) -> String{
        let arr = fileName.components(separatedBy: ".")
        return arr.first!
    }
    
    func getPDFSizeMB(_ fileSize:Int) -> String {
        let size:CGFloat = fileSize / (1024 * 1024)
        let sizeStr      = String(format:"%.2f MB",size)
        return sizeStr
    }
    
    fileprivate func pushPDFWifiViewController () {
        let vc = PDFWifiViewController()
        vc.backItemStyle = .white
        self.navigationController?.ex_pushViewController(vc, animated: true)
    }
    
    func popupAlertViewController() {
        let  alertVC = UIAlertController(title: "提示", message: "确认要删除该文档", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (alert) in
        }))
        alertVC.addAction(UIAlertAction(title: "确认", style: .default, handler: { (alert) in
            self.deleteFile()
            self.refreshData()
        }))
        self.present(alertVC, animated: true) {
        }
    }
    
    func deleteFile() {
        let document = self.documents[self.deleteCellIndex]
        if let _url = document.fileURL {
            try! self.fileManager.removeItem(at: _url)
        }
        
    }
    

    // MARK: Lazy
    var tableView:UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.showsVerticalScrollIndicator = false
        tv.showsHorizontalScrollIndicator = false
        tv.register(PDFShelfCell.self, forCellReuseIdentifier: "PDFShelfCell")
//        if #available(iOS 11.0, *) {
//           tv.contentInsetAdjustmentBehavior = .never
//        }
        return tv
    }()
    // MARK: Event
    @objc func wifiAction() {
        self.pushPDFWifiViewController()
    }
    
}

extension PDFShelfViewController:UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.documents.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let idx  = indexPath.row
        let document:ReaderDocument = self.documents[idx]
        let cell = tableView.dequeueReusableCell(withIdentifier: "PDFShelfCell") as! PDFShelfCell
        cell.titleLabel.text = self.getPDFName(document.fileName!)
        cell.sizeLabel.text  = self.getPDFSizeMB(document.fileSize.intValue)
        cell.timeLabel.text  = document.fileDateString
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.delete
    }

    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "删除"
    }
    // 进入编辑模式，按下出现的编辑按钮后
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        tableView.setEditing(false, animated: true)
        if editingStyle == .delete {
            self.deleteCellIndex = indexPath.row
            self.popupAlertViewController()
        }
    }
}

extension PDFShelfViewController:UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let idx = indexPath.row
        let document = self.documents[idx]
        print("document file path = ", document.fileURL)
//        let vc = JYReaderViewController(readerDocument: document)!
        let vc = PDFReaderViewController(readerDocument:document)
        self.navigationController?.pushViewController(vc, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }

}






