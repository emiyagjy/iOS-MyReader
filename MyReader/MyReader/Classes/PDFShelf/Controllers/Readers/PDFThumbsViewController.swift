//
//  PDFThumbsViewController.swift
//  MyReader
//
//  Created by GujyHy on 2018/3/15.
//  Copyright © 2018年 Gujy. All rights reserved.
//

import UIKit

protocol PDFThumbsViewControllerDelegate {
    
    func thumbsViewController(_ viewController:PDFThumbsViewController,gotoPage page:Int)
    
    func dismissThumbsViewController(_ viewController:PDFThumbsViewController)
    
}

class PDFThumbsViewController: PDFBaseViewController {

    var delegate:PDFThumbsViewControllerDelegate?
    
    var document:ReaderDocument!
    var theThumbsView:ReaderThumbsView!
    var bookmarked:[NSNumber]!  // 保存 book mark pages
    
    var thumbsOffset:CGPoint = CGPoint.zero
    var markedOffset:CGPoint = CGPoint.zero
    
    var updateBookmarked:Bool = true
    var showBookmarked:Bool   = false
    
    // MARK: Constants
 
    let PAGE_THUMB_SMALL_WIDTH:CGFloat  = 160
    let PAGE_THUMB_SMALL_HEIGHT:CGFloat = 180
    let PAGE_THUMB_LARGE:CGFloat = 256
    
    // MARK: UIViewController methods
    convenience init(readerDocument object:ReaderDocument) {
        self.init(nibName: nil, bundle: nil)
  
        self.bookmarked = [NSNumber]()
        self.document = object
  
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        assert(delegate != nil)
        assert(document != nil)
        self.view.backgroundColor = UIColor.gray
        self.configureNaviItems()
        self.configureThumsView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.theThumbsView.reloadThumbsCenter(on: (self.document.pageNumber.intValue - 1))
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    open override var prefersStatusBarHidden: Bool {
        return false
    }
 
    // MARK: Private
    func configureNaviItems() {
        self.addNavigationLeftItemWithImage("ic_navibar_dismiss_white", target: self, action: #selector(dismissVC))
        // titleView
//        let thumbsImage:UIImage   = UIImage(named:"ic_navibar_thumb")!
//        let bookmarkImage:UIImage = UIImage(named:"Reader-Mark-Y")!
        let items:[Any]   = ["全部","书签"]
        let segmentControl = UISegmentedControl(items: items)
        segmentControl.tintColor  = UIColor.white
        self.customNavigationItem?.titleView = segmentControl
        segmentControl.selectedSegmentIndex = 0
        segmentControl.addTarget(self, action: #selector(segmentControlValueChange), for: UIControlEvents.valueChanged)
    }
    func configureThumsView() {
        var scrollViewInsets = UIEdgeInsets.zero
        scrollViewInsets.top = kNaviBarHeight
        
        // ReaderThumbsView
        // 如果改成 collectionView ?
        theThumbsView = ReaderThumbsView(frame: self.view.bounds)
        theThumbsView.contentInset = scrollViewInsets
        theThumbsView.scrollIndicatorInsets = scrollViewInsets
        if #available(iOS 11, *) {
            theThumbsView.contentInsetAdjustmentBehavior = .never
        }
        theThumbsView.delegate = self; // ReaderThumbsViewDelegate
        self.view.insertSubview(theThumbsView, belowSubview: self.customNaviView)
        
        let viewSize = self.view.bounds.size // View size
        let min = ((viewSize.width < viewSize.height) ? viewSize.width : viewSize.height)
        let thumbSize_width = ((min > 320.0) ? CGFloat(floorf(Float(min / 3.0))): PAGE_THUMB_SMALL_WIDTH)
//        let min_h = viewSize.height
//        let thumbSize_height =  ((min_h > 480.0) ? CGFloat(floorf(Float(min_h / 3.0))): PAGE_THUMB_SMALL_HEIGHT)

        theThumbsView.setThumbSize(CGSize(width: thumbSize_width, height: thumbSize_width))
    }
    
    func showAllThumb() {
        
        self.showBookmarked = false // Show all thumbs
        self.markedOffset   = theThumbsView.insetContentOffset() // save mark offset
        theThumbsView.reloadThumbsContentOffset(self.thumbsOffset)
    }
    
    func showBookMark() {
        
        showBookmarked = true; // Only bookmarked
        
        self.thumbsOffset = theThumbsView.insetContentOffset() // save thumb offset
        if (updateBookmarked == true){ // Update bookmarked list
            self.bookmarked.removeAll() // Empty the list first
            self.document.bookmarks.enumerate({ (page, stop) in
                self.bookmarked.append(NSNumber(value:page))
            })
            self.markedOffset = .zero
            updateBookmarked = false // Reset
        }
        theThumbsView.reloadThumbsContentOffset(markedOffset)
    }

    
    // MARK: Events
    @objc func dismissVC(){
        if let _delegate = delegate  {
            _delegate.dismissThumbsViewController(self)
        }
    }
    
    @objc func segmentControlValueChange (_ control:UISegmentedControl) {
        switch control.selectedSegmentIndex {
        case 0:
            self.showAllThumb()
            break
        case 1:
            self.showBookMark()
            break
        default:
            break
        }
    }
 
    
}

extension PDFThumbsViewController : ReaderThumbsViewDelegate {
  
    func numberOfThumbs(in thumbsView: ReaderThumbsView!) -> UInt {
        return showBookmarked ? UInt(self.bookmarked.count) : UInt(document.pageCount.intValue)
    }
    
    // 返回cell
    func thumbsView(_ thumbsView: ReaderThumbsView!, thumbCellWithFrame frame: CGRect) -> Any! {
        let v = ThumbsPageThumb(frame: frame)
//        v.backgroundColor = UIColor.randomColor
        return v//ThumbsPageThumb(frame: frame)
    }
    // 核心代码 ，更新 cell 内容
    func thumbsView(_ thumbsView: ReaderThumbsView!, updateThumbCell thumbCell: Any!, for index: Int) {
     
        let cell = thumbCell as! ThumbsPageThumb
        let size = cell.maximumContentSize() // Get the cell's maximum content size
        let page = (showBookmarked ? bookmarked[index].intValue : (index + 1))
        cell.showText(String(format:"%i",page))
        cell.showBookmark(document.bookmarks.contains(page))

        let fileURL = document.fileURL
        let guid    = document.guid
        let phrase   = document.password; // Document info
        
        let thumbRequest = ReaderThumbRequest.new(for: cell,
                                                  fileURL: fileURL,
                                                  password: phrase,
                                                  guid: guid,
                                                  page: page,
                                                  size: size)
        let image = ReaderThumbCache.sharedInstance().thumbRequest(thumbRequest, priority: true)
        if !(image is NSNull) {
            let _image = image as! UIImage
            if _image.isKind(of: UIImage.self) {
                cell.show(_image)
            }
        }
    }
    
    func thumbsView(_ thumbsView: ReaderThumbsView!, didSelectThumbWith index: Int) {
        let page = (showBookmarked ? bookmarked[index].intValue : (index + 1))
        if let _delegate = self.delegate {
            _delegate.thumbsViewController(self, gotoPage: page)
            _delegate.dismissThumbsViewController(self)
        }
    }
    
    func thumbsView(_ thumbsView: ReaderThumbsView!, didPressThumbWith index: Int) {
        let page = (showBookmarked ? bookmarked[index].intValue : (index + 1))
        if document.bookmarks.contains(page) {
            document.bookmarks.remove(page)
        }else {
            document.bookmarks.add(page)
        }
        self.updateBookmarked = true
        thumbsView.refreshThumb(with: index)
    }
    
    func thumbsView(_ thumbsView: ReaderThumbsView!, refreshThumbCell thumbCell: Any!, for index: Int) {
        let page = (showBookmarked ? bookmarked[index].intValue : (index + 1))
        let cell = thumbCell as! ThumbsPageThumb
        cell.showBookmark(document.bookmarks.contains(page)) // Show bookmarked status
    }
    


    
}








