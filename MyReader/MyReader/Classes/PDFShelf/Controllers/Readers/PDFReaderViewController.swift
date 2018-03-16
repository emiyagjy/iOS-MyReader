//
//  PDFReaderViewController.swift
//  MyReader
//
//  Created by GujyHy on 2018/3/13.
//  Copyright © 2018年 Gujy. All rights reserved.
//

let SCROLLVIEW_OUTSET_SMALL = 4.0
let SCROLLVIEW_OUTSET_LARGE = 8.0

let PAGEBAR_HEIGHT = 48.0
let TAP_AREA_SIZE:CGFloat  = 48.0

enum ReaderDisplayMode:Int {
    case vertical = 0
    case Horizontal = 1
}

import UIKit

class PDFReaderViewController: PDFBaseViewController {
    
    var document:ReaderDocument!
    var theScrollView:UIScrollView!
    var readerMainPagebar:ReaderMainPagebar!
    
    var markButton:UIButton!
    var markBarItem:UIBarButtonItem!
    var thumbsItem:UIBarButtonItem!
    var settingItem:UIBarButtonItem!
    
    var currentPage:Int = 0   // 当前页
    var minimumPage:Int = 0   // 最小页数
    var maximumPage:Int = 0   // 最大页数
    
    var contentViews:[String:Any]!
    var lastHideTime:Date! // 解决手势 与 touchBegin ，点击Bars不消失的问题
    
    fileprivate var markWhiteImage:UIImage {
        get {
            return UIImage(named:"ic_navibar_mark_white")!
        }
    }
    fileprivate var markRedImage:UIImage {
        get {
            return UIImage(named:"ic_navibar_mark_red")!
        }
    }
    
   fileprivate var settingImage:UIImage {
        get {
            return UIImage(named:"ic_navibar_settings")!
        }
        
    }
    
   fileprivate var displayMode:ReaderDisplayMode = .vertical {
        didSet{
            if let _scrollView = theScrollView {
                self.updateContentSize(_scrollView)
            }
        }
    }
    fileprivate var isStausBarShow:Bool = true {
        didSet{
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    var userInterfaceIdiom:UIUserInterfaceIdiom!
    var scrollViewOutset:CGFloat = 0
    
    // MARK: UIViewController methods
    convenience init(readerDocument object:ReaderDocument) {
        self.init(nibName: nil, bundle: nil)
        
        scrollViewOutset = CGFloat(userInterfaceIdiom == UIUserInterfaceIdiom.pad ? SCROLLVIEW_OUTSET_LARGE : SCROLLVIEW_OUTSET_SMALL)
        
        object.updateProperties()
        self.document = object
        
        ReaderThumbCache.touch(withGUID: object.guid) // Touch the document thumb cache directory
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        assert(document != nil); // Must have a valid ReaderDocument
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.initData()
        self.configureNaviItems()
        self.configureScrollView()
        self.configurePageBar()
        self.configureGestureRecognizer()
        self.showDocument()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard theScrollView.contentSize == .zero else {return}
       
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    open override var prefersStatusBarHidden: Bool {
        return !isStausBarShow
    }
    
    // MARK: Getters
    func getScrollContentOffsetWithPage(_ page:Int) -> CGPoint{
        var contentOffset:CGPoint = .zero
        if self.displayMode == .vertical {
            contentOffset = CGPoint(x: 0, y:CGFloat(theScrollView.bounds.size.height * (page - 1)))
        }else{
            contentOffset = CGPoint(x: CGFloat(theScrollView.bounds.size.width * (page - 1)), y:0)
        }
        return contentOffset
    }
    
    func getContentViewFrameWithPage(_ page:Int,scrollView:UIScrollView) -> CGRect {
        var viewRect:CGRect = CGRect.zero
        viewRect.size = scrollView.bounds.size
        if self.displayMode == .vertical {
            viewRect.origin.y = (viewRect.size.height * (page - 1));  // Update Y
            viewRect = viewRect.insetBy(dx: scrollViewOutset, dy: 0)
        }else{
            viewRect.origin.x = (viewRect.size.width * (page - 1)); // Update X
            viewRect = viewRect.insetBy(dx: scrollViewOutset, dy: 0)
        }
        return viewRect
    }
    
    func getScrollContentSize(_ scrollView:UIScrollView) -> CGSize{
        if self.displayMode == .vertical {
            // 上下滚动
            let contentHeight  = (scrollView.bounds.size.height * maximumPage);
            let contentWidth   = scrollView.bounds.size.width; // Width
            return CGSize(width: contentWidth, height: contentHeight)
        }else {
            // 左右滚动
            let contentHeight  = scrollView.bounds.size.height; // Height
            let contentWidth   = (scrollView.bounds.size.width * maximumPage);
            return CGSize(width: contentWidth, height: contentHeight)
        }
    }
    
    func getPageWithScrollView(_ scrollView:UIScrollView) -> Int{
        if self.displayMode == .vertical {
            let viewHeight     = scrollView.bounds.size.height
            let contentOffsetY = scrollView.contentOffset.y
            let page = Int(contentOffsetY / viewHeight)
            return page
        }else {
            let viewWidth     = scrollView.bounds.size.width
            let contentOffsetX = scrollView.contentOffset.x
            let page = Int(contentOffsetX / viewWidth)
            return page
        }
    }
    
    // MARK: Private
    
    fileprivate func initData() {
        contentViews = [String:Any]()
        lastHideTime = Date()
        minimumPage = 1
        maximumPage = document.pageCount.intValue
    }
    
    fileprivate func configureNaviItems() {
        
        // back
        self.addNavigationLeftItemWithImage("ic_navibar_back_white", target: self, action: #selector(popSelf))
        
        markButton = UIButton()
        markButton.tag = LONG_MAX
        markButton.bounds = CGRect(x: 0, y: 0, width: self.markRedImage.size.width, height: self.markRedImage.size.height)
        markButton.addTarget(self, action: #selector(addOrRemoveBookmark), for: .touchUpInside)
        self.markBarItem = UIBarButtonItem(customView:markButton)
        //       self.markBarItem = UIBarButtonItem(image: UIImage(named:"Reader-Mark-Y11"), target: self, action: #selector(addOrRemoveBookmark(_:)))
        
        self.thumbsItem  = UIBarButtonItem(image:UIImage(named:"ic_navibar_thumb"), target: self, action: #selector(thumbsAction(_:)))
        
        self.settingItem = UIBarButtonItem(image:self.settingImage, target: self, action: #selector(settingAction(_:)))
        
        let space      = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: self, action: nil)
        space.width = 25
        self.customNavigationItem?.rightBarButtonItems = [space,markBarItem,space,thumbsItem,space,settingItem]
    }
    
    fileprivate func configureScrollView() {
        let viewRect = self.view.bounds;
        //        let scrollViewRect = viewRect.insetBy(dx: -scrollViewOutset, dy: 0)
        theScrollView = UIScrollView(frame: viewRect)
        self.view.insertSubview(theScrollView, belowSubview: self.customNaviView)
        if #available(iOS 11.0, *){
            theScrollView.contentInsetAdjustmentBehavior  = .never
        }
        theScrollView.autoresizesSubviews = false
        theScrollView.contentMode = .redraw
        theScrollView.showsHorizontalScrollIndicator = false
        theScrollView.showsVerticalScrollIndicator = false
        theScrollView.scrollsToTop = false
        theScrollView.delaysContentTouches = false
        theScrollView.isPagingEnabled = true
        theScrollView.autoresizingMask = UIViewAutoresizing.flexibleWidth.union(UIViewAutoresizing.flexibleHeight)
        theScrollView.backgroundColor = .black
        theScrollView.delegate = self
    }
    
    fileprivate func configurePageBar(){
        var pageBarRect         = self.view.bounds
        pageBarRect.size.height = CGFloat(PAGEBAR_HEIGHT)
        pageBarRect.origin.y    = self.view.bounds.size.height - pageBarRect.size.height
        self.readerMainPagebar  = ReaderMainPagebar(frame: pageBarRect, document: self.document)
        self.readerMainPagebar.delegate = self
        self.view.addSubview(self.readerMainPagebar)
    }
    
    fileprivate func configureGestureRecognizer() {
        let singleTapOne = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap))
        singleTapOne.numberOfTouchesRequired = 1
        singleTapOne.numberOfTapsRequired = 1
        singleTapOne.delegate = self
        self.view.addGestureRecognizer(singleTapOne)
        
        let sinlgeTapTwo = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        sinlgeTapTwo.numberOfTouchesRequired = 1
        sinlgeTapTwo.numberOfTapsRequired = 2
        sinlgeTapTwo.delegate = self
        self.view.addGestureRecognizer(sinlgeTapTwo)
    }
    
    
    // MARK: UIGestureRecognizer action methods
    @objc func handleSingleTap(_ recognizer:UITapGestureRecognizer) {
        
        if recognizer.state == UIGestureRecognizerState.recognized {
            
            let viewRect = (recognizer.view?.bounds)! // View bounds
            let point = recognizer.location(in: recognizer.view)  // Point
            let areaRect = viewRect.insetBy(dx:TAP_AREA_SIZE, dy: 0) // Area rect
            
            if areaRect.contains(point)  == true { // Single tap is inside area
                if lastHideTime.timeIntervalSinceNow < -0.75 {
                    if self.customNaviView.alpha < 1 {
                        self.showBars()
                    }else{
                        self.hideBars()
                    }
                }else{
                }
                return
            }
            
            var nextPageRect = viewRect
            nextPageRect.size.width = TAP_AREA_SIZE
            nextPageRect.origin.x = viewRect.size.width - TAP_AREA_SIZE
            
            if nextPageRect.contains(point) == true // page++
            {
                self.incrementPageNumber()
                return
            }
            
            var prevPageRect = viewRect
            prevPageRect.size.width = TAP_AREA_SIZE
            if prevPageRect.contains(point) == true // page--
            {
                self.decrementPageNumber()
                return;
            }
        }
    }
    
    @objc func handleDoubleTap(_ recognizer:UITapGestureRecognizer) {
        if recognizer.state == UIGestureRecognizerState.recognized {
            
            let viewRect = (recognizer.view?.bounds)! // View bounds
            let point = recognizer.location(in: recognizer.view)  // Point
            let zoomRect = viewRect.insetBy(dx:TAP_AREA_SIZE, dy: 0) // Area rect
            
            if zoomRect.contains(point)  == true { // Single tap is inside area
                let key = String(format:"%d",currentPage)
                let targetView = contentViews[key] as! ReaderContentView
                targetView.zoomIncrement(recognizer)
                //                 [targetView zoomDecrement:recognizer];
                return
            }
            
            var nextPageRect = viewRect
            nextPageRect.size.width = TAP_AREA_SIZE
            nextPageRect.origin.x = viewRect.size.width - TAP_AREA_SIZE
            
            if nextPageRect.contains(point) == true // page++
            {
                self.incrementPageNumber()
                return
            }
            
            var prevPageRect = viewRect
            prevPageRect.size.width = TAP_AREA_SIZE
            if prevPageRect.contains(point) == true // page--
            {
                self.decrementPageNumber()
                return;
            }
        }
    }
    func decrementPageNumber() {
        
        if ((maximumPage > minimumPage) && (currentPage != minimumPage)){
            var contentOffset = theScrollView.contentOffset // Offset
            if self.displayMode == .vertical {
                contentOffset.y -= theScrollView.bounds.size.height // View Y--
            }else{
                contentOffset.x -= theScrollView.bounds.size.width // View X--
            }
            theScrollView.setContentOffset(contentOffset, animated: true)
        }
    }
    
    func incrementPageNumber() {
        
        if ((maximumPage > minimumPage) && (currentPage != maximumPage)){
            var contentOffset = theScrollView.contentOffset; // Offset
            if self.displayMode == .vertical {
                contentOffset.y += theScrollView.bounds.size.height // View Y++
            }else{
                contentOffset.x += theScrollView.bounds.size.width; // View X++
            }
            theScrollView.setContentOffset(contentOffset, animated: true)
        }
        
    }
    
    
    // MARK: PDFReaderViewController methods
    func closeDocument () {
        self.document.archiveDocumentProperties()
        ReaderThumbQueue.sharedInstance().cancelOperations(withGUID: document.guid)
        ReaderThumbCache.sharedInstance().removeAllObjects()
    }
    
    func showDocument(){
        
        self.updateContentSize(self.theScrollView) // Update content size first
        
        self.showDocumentPage(document.pageNumber.intValue) // Show page
        
        document.lastOpen = Date(); // Update document last opened date
    }
    
    func showDocumentPage(_ page:Int) {
        
        if page != currentPage { // page 不同
            
            guard page > minimumPage || page < maximumPage else { return }
            
            currentPage = page
            document.pageNumber = NSNumber(value: page)
            // 根据 page 获取 scrollView contentOffset
            let contentOffset = self.getScrollContentOffsetWithPage(page)
            if theScrollView.contentOffset.equalTo(contentOffset) {
                self.layoutContentViews(theScrollView)
            }else{
                theScrollView.contentOffset = contentOffset // 直接跳转到指定页的 offset
            }
            
            contentViews.forEach({ (key,value) in
                if Int(key) != page {
                    let contentView = value as! ReaderContentView
                    contentView.zoomReset(animated: false)
                }
            })
            self.setBookMarkState(document.bookmarks.contains(page))
            self.readerMainPagebar.update()
            
        }
    }
    func layoutContentViews(_ scrollView:UIScrollView) {
        
        var viewHW:CGFloat = 0
        var contentOffsetXY:CGFloat = 0
        if (self.displayMode == .vertical) {
            viewHW          = scrollView.bounds.size.height // View Height
            contentOffsetXY = scrollView.contentOffset.y  // Content offset Y
        }else{
            viewHW          = scrollView.bounds.size.width  // View width
            contentOffsetXY = scrollView.contentOffset.x   // Content offset X
        }
        var pageB:Int = Int((contentOffsetXY + viewHW - 1.0) / viewHW); // Pages
        var pageA:Int = Int(contentOffsetXY / viewHW);
        pageB += 2; // Add extra pages
        
        if pageA < minimumPage {
            pageA = minimumPage
        }
        if pageB > maximumPage {
            pageB = maximumPage
        }
        let pageRange = NSMakeRange(pageA, (pageB - pageA + 1)); // Make page range (A to B)
        
        let pageSet = NSMutableIndexSet(indexesIn: pageRange)
        self.contentViews.forEach { (key,value) in
            let page:Int = Int(key)!  // Page number value
            if pageSet.contains(page) == false { // Remove content view
                let contentView = contentViews[key] as! ReaderContentView
                contentView.removeFromSuperview()
                self.contentViews.removeValue(forKey: key)
            }else{
                pageSet.remove(page)
            }
        }
        let pages = pageSet.count
        
        if pages > 0 { // We have pages to add
            
            var options:NSEnumerationOptions = NSEnumerationOptions(rawValue: 0) // default
            
            if pages == 2 { // Handle case of only two content views
                if maximumPage > 2 && pageSet.lastIndex == maximumPage {
                    options = NSEnumerationOptions.reverse
                }
            }else if pages == 3 { // Handle three content views - show the middle one first
                let workSet:NSMutableIndexSet = pageSet.mutableCopy() as! NSMutableIndexSet
                options = NSEnumerationOptions.reverse
                workSet.remove(pageSet.firstIndex)
                workSet.remove(pageSet.lastIndex)
                
                let page = workSet.firstIndex
                pageSet.remove(page)
                self.addContentView(scrollView, page: page)
            }
            // Enumerate page set
            pageSet.enumerate(options: options, using: { (page, stop) in
                self.addContentView(scrollView, page: page)
            })
            
        }
    }
    
    func addContentView(_ scrollView:UIScrollView,page:Int) {
        
        let viewRect = self.getContentViewFrameWithPage(page, scrollView: scrollView)
        let fileURL  = document.fileURL
        let phrase   = document.password
        let guid     = document.guid
        
        let contentView = ReaderContentView(frame: viewRect, fileURL: fileURL, page: UInt(page), password: phrase)!
        contentView.message = self
        
        let key = String(format:"%d",page)
        self.contentViews[key] = contentView
        scrollView.addSubview(contentView)
        // // Request page preview thumb
        contentView.showPageThumb(fileURL, page:  page, password: phrase, guid: guid)
        
    }
    
    // 更改 scrollView contentSize
    func updateContentSize(_ scrollView:UIScrollView) {
        scrollView.contentSize = self.getScrollContentSize(scrollView)
    }
    
    // 滑动结束 ，reset zoom
    func handleScrollViewDidEnd(_ scrollView:UIScrollView) {
        var page = self.getPageWithScrollView(scrollView)
        page += 1
        if page != currentPage {
            currentPage = page
            document.pageNumber = NSNumber(value:page)
            self.contentViews.forEach({ (key,value) in
                if Int(key) != page {
                    let contentView = value as! ReaderContentView
                    contentView.zoomReset(animated: false)
                }
            })
        }
        
        self.setBookMarkState(document.bookmarks.contains(page))
        self.readerMainPagebar.update() // Update page bar
        
    }
    
    
    fileprivate func showBars() {
        UIView.animate(withDuration:CATransaction.animationDuration() , animations: {
            self.customNaviView.alpha = 1
            self.readerMainPagebar.alpha = 1
            self.isStausBarShow = true
        })
        //                self.isStatusBarWhiteStyle = true;
    }
    fileprivate func hideBars() {
        UIView.animate(withDuration:CATransaction.animationDuration() , animations: {
            self.customNaviView.alpha = 0
            self.readerMainPagebar.alpha = 0
            self.isStausBarShow = false
        })
    }
    
    fileprivate func setBookMarkState(_ state:Bool) {
        if state.hashValue != markButton.tag { // Only if different state
            let image = state ? markRedImage : markWhiteImage
            markButton.setImage(image, for: .normal)
            markButton.tag = state.hashValue // Update bookmarked state tag
        }
    }
    
    fileprivate func updateBookMarkState() {
        if self.document.bookmarks.contains(currentPage) {
            self.setBookMarkState(true)
        }else{
            self.setBookMarkState(false)
        }
    }
    
    // MARK: pop & push ViewControllers
    // 弹出 设置 控制器
    fileprivate func popupSettingiewController() {
        let viewController = PDFSettingViewController()
        viewController.modalPresentationStyle = .popover
        viewController.preferredContentSize = CGSize(width: kScreenW, height: 44)  // 弹出视图的大小
        // bar item
        viewController.popoverPresentationController?.barButtonItem = self.settingItem
        // 箭头方向
        viewController.popoverPresentationController?.permittedArrowDirections = .up
        viewController.popoverPresentationController?.delegate = self
        self.present(viewController, animated: false, completion: nil)
    }
    
    fileprivate func presentThumbViewController() {
        
        let thumbsViewController = PDFThumbsViewController(readerDocument: self.document)
        thumbsViewController.delegate = self
        thumbsViewController.title  = self.title
        thumbsViewController.modalTransitionStyle = .crossDissolve
        thumbsViewController.modalPresentationStyle = .fullScreen
        self.present(thumbsViewController, animated: false, completion: nil)
        
        
        //        let thumbsViewController = ThumbsViewController(readerDocument: self.document)!
        //        thumbsViewController.delegate = self
        //        thumbsViewController.title  = self.title
        //        thumbsViewController.modalTransitionStyle = .crossDissolve
        //        thumbsViewController.modalPresentationStyle = .fullScreen
        //        self.present(thumbsViewController, animated: false, completion: nil)
    }
    
    
    // MARK: Events
    @objc func popSelf(){
        self.navigationController?.popViewController(animated: true)
        self.closeDocument()
    }
    
    
    @objc func addOrRemoveBookmark(_ sender: UIButton) {
        
        if document.bookmarks.contains(currentPage) { // remove book mark
            document.bookmarks.remove(currentPage)
            self.setBookMarkState(false)
        }else{
            document.bookmarks.add(currentPage)
            self.setBookMarkState(true)
        }
        // 保存属性
        document.archiveDocumentProperties()
    }
    
    @objc func thumbsAction(_ sender:UIBarButtonItem) {
        self.presentThumbViewController()
    }
    
    @objc func settingAction(_ sender:UIBarButtonItem) {
        self.popupSettingiewController()
//        self.displayMode = .Horizontal
    }
    
}

// MARK: UIScrollViewDelegate
extension PDFReaderViewController:UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.layoutContentViews(scrollView)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.handleScrollViewDidEnd(scrollView)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.handleScrollViewDidEnd(scrollView)
    }
}

// MARK: ReaderContentViewDelegate
extension PDFReaderViewController:ReaderContentViewDelegate {
    func contentView(_ contentView: ReaderContentView!, touchesBegan touches: Set<AnyHashable>!) {
        
        if readerMainPagebar.alpha > 0 || self.customNaviView.alpha > 0 {
            if touches.count == 1 { // Single touches only
                let touch = touches.first as! UITouch
                let point = touch.location(in: self.view)
                let areaRect = self.view.bounds.insetBy(dx: TAP_AREA_SIZE, dy: TAP_AREA_SIZE)
                if areaRect.contains(point) == false { return } // 不包含在 touch 范围内
            }
            self.hideBars()
            self.lastHideTime = Date()
        }
    }
}

// MARK: ReaderMainPagebarDelegate
extension PDFReaderViewController:ReaderMainPagebarDelegate {
    func pagebar(_ pagebar: ReaderMainPagebar!, gotoPage page: Int) {
        self.showDocumentPage(page)
    }
    
}

// MARK: UIGestureRecognizerDelegate
extension PDFReaderViewController:UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (touch.view?.isKind(of: UIScrollView.self))! {
            return true
        }
        return false
    }
}

// MARK: UIPopoverPresentationControllerDelegate
extension PDFReaderViewController:UIPopoverPresentationControllerDelegate {
    
    // 默认返回的是覆盖整个屏幕，需设置成UIModalPresentationNone
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    // 点击蒙版是否消失
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return true
    }
}

// MARK:
extension PDFReaderViewController:PDFThumbsViewControllerDelegate {
    func thumbsViewController(_ viewController: PDFThumbsViewController, gotoPage page: Int) {
        self.showDocumentPage(page)
    }
    func dismissThumbsViewController(_ viewController: PDFThumbsViewController) {
        self.dismiss(animated: true, completion: nil)
        self.updateBookMarkState()
    }
}




