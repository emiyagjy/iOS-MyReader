//
//  JYReaderViewController.m
//  MyReader
//
//  Created by GujyHy on 2018/3/9.
//  Copyright © 2018年 Gujy. All rights reserved.
//


#import "ReaderConstants.h"
#import "JYReaderViewController.h"
#import "ThumbsViewController.h"
#import "ReaderMainToolbar.h"
#import "ReaderMainPagebar.h"
#import "ReaderContentView.h"
#import "ReaderThumbCache.h"
#import "ReaderThumbQueue.h"

#import <MessageUI/MessageUI.h>

@interface JYReaderViewController () <
UIScrollViewDelegate,
UIGestureRecognizerDelegate,
MFMailComposeViewControllerDelegate,
UIDocumentInteractionControllerDelegate,
ReaderMainToolbarDelegate,
ReaderMainPagebarDelegate,
ReaderContentViewDelegate,
ThumbsViewControllerDelegate
>

@property (nonatomic,assign) BOOL isStatusBarWhiteStyle;


@end

@implementation JYReaderViewController
{
    ReaderDocument *document;
    
    UIScrollView *theScrollView;
    ReaderMainToolbar *mainToolbar;
    ReaderMainPagebar *mainPagebar;
    NSMutableDictionary *contentViews;
    UIUserInterfaceIdiom userInterfaceIdiom;
    NSInteger currentPage, minimumPage, maximumPage;
    
    UIDocumentInteractionController *documentInteraction;
    UIPrintInteractionController *printInteraction;
    
    CGFloat scrollViewOutset;
    CGSize lastAppearSize;
    NSDate *lastHideTime;
    
    BOOL ignoreDidScroll;
}

#pragma mark - Constants

#define STATUS_HEIGHT 20.0f

#define TOOLBAR_HEIGHT 44.0f
#define PAGEBAR_HEIGHT 48.0f

#define SCROLLVIEW_OUTSET_SMALL 4.0f
#define SCROLLVIEW_OUTSET_LARGE 8.0f

#define TAP_AREA_SIZE 48.0f

#pragma mark - Properties

@synthesize delegate;


#pragma mark - Setters
- (void) setIsStatusBarWhiteStyle:(BOOL)isStatusBarWhiteStyle{
    _isStatusBarWhiteStyle = isStatusBarWhiteStyle;
    [self setNeedsStatusBarAppearanceUpdate];
}


#pragma mark - Getters
- (CGSize) getScrollContentSize:(UIScrollView *) scrollView {
    
    // 根据参数不同选择不同的方式进行 浏览
    if (self.displayMode == JYReaderDisplayModeVertical) {
        // 上下滚动
        CGFloat contentHeight  = (scrollView.bounds.size.height * maximumPage);
        CGFloat contentWidth   = scrollView.bounds.size.width; // Width
        return CGSizeMake(contentWidth, contentHeight);
    }else{
        // 左右滚动
        CGFloat contentHeight = scrollView.bounds.size.height; // Height
        CGFloat contentWidth = (scrollView.bounds.size.width * maximumPage);
        return CGSizeMake(contentWidth, contentHeight);
    }
}

- (CGPoint) getScrollContentOffsetWithPage:(NSInteger) page {
    CGPoint contentOffset = CGPointZero;
    if (self.displayMode == JYReaderDisplayModeVertical) {
        contentOffset = CGPointMake(0.0f,(theScrollView.bounds.size.height * (page - 1)));
    }else{
        contentOffset = CGPointMake((theScrollView.bounds.size.width * (page - 1)), 0.0f);
    }
    return contentOffset;
}

- (NSUInteger) getPageWithScrollView:(UIScrollView *) scrollView {
    if (self.displayMode == JYReaderDisplayModeVertical) {
        CGFloat viewHeight = scrollView.bounds.size.height; // Scroll view height
        CGFloat contentOffsetY = scrollView.contentOffset.y; // Content offset Y
        NSInteger page = (contentOffsetY / viewHeight);
        return page;
    }else{
        CGFloat viewWidth = scrollView.bounds.size.width;    // Scroll view width
        CGFloat contentOffsetX = scrollView.contentOffset.x; // Content offset X
        NSInteger page = (contentOffsetX / viewWidth);
        return page;
    }
}

- (CGRect) getContentViewFrameWithPage:(NSUInteger) page
                            scrollView:(UIScrollView *) scrollView {
    CGRect viewRect = CGRectZero;
    viewRect.size = scrollView.bounds.size;
    if (self.displayMode == JYReaderDisplayModeVertical) {
        viewRect.origin.y = (viewRect.size.height * (page - 1));  // Update Y
        viewRect = CGRectInset(viewRect, scrollViewOutset, 0.0f);
        
    }else{
        viewRect.origin.x = (viewRect.size.width * (page - 1)); // Update X
        viewRect = CGRectInset(viewRect, scrollViewOutset, 0.0f);
    }
    return viewRect;
}

#pragma mark - ReaderViewController methods

- (void)updateContentSize:(UIScrollView *)scrollView{
    scrollView.contentSize = [self getScrollContentSize:scrollView];
}

- (void)updateContentViews:(UIScrollView *)scrollView
{
    // 放到了下一个runloop 中执行 ，就没有抖动了？
    [self performSelector:@selector(updateContentSize:) withObject:scrollView afterDelay:0.1];
    //    [self updateContentSize:scrollView]; // Update content size first
    
    [contentViews enumerateKeysAndObjectsUsingBlock: // Enumerate content views
     ^(NSNumber *key, ReaderContentView *contentView, BOOL *stop)
     {
         NSInteger page = [key integerValue]; // Page number value
         CGRect viewRect =  [self getContentViewFrameWithPage:page scrollView:scrollView];
         contentView.frame = viewRect;
     }
     ];
    
    NSInteger page = currentPage; // Update scroll view offset to current page
    CGPoint contentOffset = [self getScrollContentOffsetWithPage:page];
    
    if (CGPointEqualToPoint(scrollView.contentOffset, contentOffset) == false){ // Update
        scrollView.contentOffset = contentOffset; // Update content offset
    }
    [mainToolbar setBookmarkState:[document.bookmarks containsIndex:page]];
    //
    [mainPagebar updatePagebar]; // Update page bar
}

- (void)addContentView:(UIScrollView *)scrollView page:(NSInteger)page
{
    CGRect viewRect = [self getContentViewFrameWithPage:page scrollView:scrollView];
    NSURL *fileURL = document.fileURL; NSString *phrase = document.password; NSString *guid = document.guid; // Document properties
    
    ReaderContentView *contentView = [[ReaderContentView alloc] initWithFrame:viewRect fileURL:fileURL page:page password:phrase]; // ReaderContentView
    
    contentView.message = self;
    [contentViews setObject:contentView forKey:[NSNumber numberWithInteger:page]];
    [scrollView addSubview:contentView];
    
    [contentView showPageThumb:fileURL page:page password:phrase guid:guid]; // Request page preview thumb
}

- (void)layoutContentViews:(UIScrollView *)scrollView
{
    CGFloat viewHW = 0;
    CGFloat contentOffsetXY = 0;
    if (self.displayMode == JYReaderDisplayModeVertical) {
        viewHW          = scrollView.bounds.size.height; // View Height
        contentOffsetXY = scrollView.contentOffset.y;   // Content offset Y
    }else{
        viewHW          = scrollView.bounds.size.width;  // View width
        contentOffsetXY = scrollView.contentOffset.x;    // Content offset X
    }
    NSInteger pageB = ((contentOffsetXY + viewHW - 1.0f) / viewHW); // Pages
    NSInteger pageA = (contentOffsetXY / viewHW);
    pageB += 2; // Add extra pages
    
    if (pageA < minimumPage) pageA = minimumPage;
    if (pageB > maximumPage) pageB = maximumPage;
    
    NSRange pageRange = NSMakeRange(pageA, (pageB - pageA + 1)); // Make page range (A to B)
    
    NSMutableIndexSet *pageSet = [NSMutableIndexSet indexSetWithIndexesInRange:pageRange];
    
    for (NSNumber *key in [contentViews allKeys]) // Enumerate content views
    {
        NSInteger page = [key integerValue]; // Page number value
        
        if ([pageSet containsIndex:page] == NO) // Remove content view
        {
            ReaderContentView *contentView = [contentViews objectForKey:key];
            
            [contentView removeFromSuperview];
            [contentViews removeObjectForKey:key];
        }
        else // Visible content view - so remove it from page set
        {
            [pageSet removeIndex:page];
        }
    }
    
    NSInteger pages = pageSet.count;
    
    if (pages > 0) // We have pages to add
    {
        NSEnumerationOptions options = 0; // Default
        
        if (pages == 2) // Handle case of only two content views
        {
            if ((maximumPage > 2) && ([pageSet lastIndex] == maximumPage))
                options = NSEnumerationReverse;
        }
        else if (pages == 3) // Handle three content views - show the middle one first
        {
            NSMutableIndexSet *workSet = [pageSet mutableCopy];
            options = NSEnumerationReverse;
            
            [workSet removeIndex:[pageSet firstIndex]];
            [workSet removeIndex:[pageSet lastIndex]];
            
            NSInteger page = [workSet firstIndex];
            [pageSet removeIndex:page];
            
            [self addContentView:scrollView page:page];
        }
        
        [pageSet enumerateIndexesWithOptions:options usingBlock: // Enumerate page set
         ^(NSUInteger page, BOOL *stop)
         {
             [self addContentView:scrollView page:page];
         }
         ];
    }
}

- (void)handleScrollViewDidEnd:(UIScrollView *)scrollView
{
    NSInteger page = [self getPageWithScrollView:scrollView];
    page++; // Page number
    
    if (page != currentPage) // Only if on different page
    {
        currentPage = page;
        document.pageNumber = [NSNumber numberWithInteger:page];
        
        [contentViews enumerateKeysAndObjectsUsingBlock: // Enumerate content views
         ^(NSNumber *key, ReaderContentView *contentView, BOOL *stop)
         {
             if ([key integerValue] != page) [contentView zoomResetAnimated:NO];
         }
         ];
        
        [mainToolbar setBookmarkState:[document.bookmarks containsIndex:page]];
        
        [mainPagebar updatePagebar]; // Update page bar
    }
}

- (void)showDocumentPage:(NSInteger)page
{
    if (page != currentPage) // Only if on different page
    {
        if ((page < minimumPage) || (page > maximumPage)) return;
        
        currentPage = page;
        document.pageNumber = [NSNumber numberWithInteger:page];
        CGPoint contentOffset = [self getScrollContentOffsetWithPage:page];
        
        if (CGPointEqualToPoint(theScrollView.contentOffset, contentOffset) == true){
            [self layoutContentViews:theScrollView];
        }else {
            [theScrollView setContentOffset:contentOffset]; // 直接跳转到指定页的 offset
        }
        [contentViews enumerateKeysAndObjectsUsingBlock:    // Enumerate content views
         ^(NSNumber *key, ReaderContentView *contentView, BOOL *stop)
         {
             if ([key integerValue] != page)
                 [contentView zoomResetAnimated:NO];
         }
         ];
        
        [mainToolbar setBookmarkState:[document.bookmarks containsIndex:page]];
        
        [mainPagebar updatePagebar]; // Update page bar
    }
}

- (void)showDocument
{
    [self updateContentSize:theScrollView]; // Update content size first
    
    [self showDocumentPage:[document.pageNumber integerValue]]; // Show page
    
    document.lastOpen = [NSDate date]; // Update document last opened date
}

- (void)closeDocument
{
    if (printInteraction != nil) [printInteraction dismissAnimated:NO];
    
    [document archiveDocumentProperties]; // Save any ReaderDocument changes
    
    [[ReaderThumbQueue sharedInstance] cancelOperationsWithGUID:document.guid];
    
    [[ReaderThumbCache sharedInstance] removeAllObjects]; // Empty the thumb cache
    
//    if ([delegate respondsToSelector:@selector(dismissReaderViewController:)] == YES)
//    {
//        [delegate dismissReaderViewController:self]; // Dismiss the ReaderViewController
//    }
//    else // We have a "Delegate must respond to -dismissReaderViewController:" error
//    {
//        NSAssert(NO, @"Delegate must respond to -dismissReaderViewController:");
//    }
}

#pragma mark - UIViewController methods

- (instancetype)initWithReaderDocument:(ReaderDocument *)object
{
    if ((self = [super initWithNibName:nil bundle:nil])) // Initialize superclass
    {
        if ((object != nil) && ([object isKindOfClass:[ReaderDocument class]])) // Valid object
        {
            userInterfaceIdiom = [UIDevice currentDevice].userInterfaceIdiom; // User interface idiom
            
            NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter]; // Default notification center
            
            [notificationCenter addObserver:self selector:@selector(applicationWillResign:) name:UIApplicationWillTerminateNotification object:nil];
            
            [notificationCenter addObserver:self selector:@selector(applicationWillResign:) name:UIApplicationWillResignActiveNotification object:nil];
            
            scrollViewOutset = ((userInterfaceIdiom == UIUserInterfaceIdiomPad) ? SCROLLVIEW_OUTSET_LARGE : SCROLLVIEW_OUTSET_SMALL);
            //
            [object updateDocumentProperties];
            document = object; // Retain the supplied ReaderDocument object for our use
            
            [ReaderThumbCache touchThumbCacheWithGUID:object.guid]; // Touch the document thumb cache directory
        }
        else // Invalid ReaderDocument object
        {
            self = nil;
        }
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Private

- (void) initData {
    
    contentViews = [NSMutableDictionary new];
    lastHideTime = [NSDate date];
    
    minimumPage = 1;
    maximumPage = [document.pageCount integerValue];
}

//- (void) setNaviItems {
//    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_test_Share"] style:UIBarButtonItemStyleDone target:self action:@selector(itemAction:)];
//    item1.tintColor = [UIColor whiteColor];
//
//    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_test_Share"] style:UIBarButtonItemStyleDone target:self action:@selector(item2Action:)];
//    item2.tintColor = [UIColor whiteColor];
//
//    self.navigationItem.rightBarButtonItems = @[item1,item2];
//
//}
- (void) configureScrollView {
    CGRect viewRect = self.view.bounds;
    CGRect scrollViewRect = CGRectInset(viewRect, -scrollViewOutset, 0.0f);
    theScrollView = [[UIScrollView alloc] initWithFrame:scrollViewRect]; // All
    [self.view addSubview:theScrollView];
    if (@available(iOS 11.0, *)){
        theScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    theScrollView.autoresizesSubviews = NO;
    theScrollView.contentMode = UIViewContentModeRedraw;
    theScrollView.showsHorizontalScrollIndicator = NO;
    theScrollView.showsVerticalScrollIndicator = NO;
    theScrollView.scrollsToTop = NO;
    theScrollView.delaysContentTouches = NO;
    theScrollView.pagingEnabled = YES;
    theScrollView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    theScrollView.backgroundColor = [UIColor blackColor];
    theScrollView.delegate = self;
    
    if(_isSingleContinue) {
        theScrollView.pagingEnabled = NO;
    }else{
        theScrollView.pagingEnabled = YES;
    }
}

- (void) configurePageBar {
    CGRect pagebarRect = self.view.bounds;
    pagebarRect.size.height = PAGEBAR_HEIGHT;
    pagebarRect.origin.y = (self.view.bounds.size.height - pagebarRect.size.height);
    mainPagebar = [[ReaderMainPagebar alloc] initWithFrame:pagebarRect document:document];
    // ReaderMainPagebar
    mainPagebar.delegate = self; // ReaderMainPagebarDelegate
    [self.view addSubview:mainPagebar];
}

// 考虑要不要自定义
- (void) configureToolBar {
    CGRect toolbarRect      = self.view.bounds;
    toolbarRect.origin.y    = STATUS_HEIGHT;
    toolbarRect.size.height = TOOLBAR_HEIGHT;
     // ReaderMainToolbar
    mainToolbar = [[ReaderMainToolbar alloc] initWithFrame:toolbarRect document:document];
    mainToolbar.delegate = self; // ReaderMainToolbarDelegate
    [self.view addSubview:mainToolbar];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    assert(document != nil); // Must have a valid ReaderDocument
    
    self.view.backgroundColor  = [UIColor clearColor]; // Neutral gray
    self.isStatusBarWhiteStyle = true;
    self.automaticallyAdjustsScrollViewInsets = false;
    [self initData];
    [self configureScrollView];
    [self configurePageBar];
    [self configureToolBar];
    
    // 手势
    UITapGestureRecognizer *singleTapOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    singleTapOne.numberOfTouchesRequired = 1;
    singleTapOne.numberOfTapsRequired = 1;
    singleTapOne.delegate = self;
    [self.view addGestureRecognizer:singleTapOne];
    
    UITapGestureRecognizer *doubleTapOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTapOne.numberOfTouchesRequired = 1;
    doubleTapOne.numberOfTapsRequired = 2;
    doubleTapOne.delegate = self;
    [self.view addGestureRecognizer:doubleTapOne];
    
    UITapGestureRecognizer *doubleTapTwo = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTapTwo.numberOfTouchesRequired = 2;
    doubleTapTwo.numberOfTapsRequired = 2;
    doubleTapTwo.delegate = self;
    [self.view addGestureRecognizer:doubleTapTwo];
    
    [singleTapOne requireGestureRecognizerToFail:doubleTapOne];
    // Single tap requires double tap to fail
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (CGSizeEqualToSize(lastAppearSize, CGSizeZero) == false)
    {
        if (CGSizeEqualToSize(lastAppearSize, self.view.bounds.size) == false)
        {
            [self updateContentViews:theScrollView]; // Update content views
        }
        
        lastAppearSize = CGSizeZero; // Reset view size tracking
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (CGSizeEqualToSize(theScrollView.contentSize, CGSizeZero) == true)
    {
        [self performSelector:@selector(showDocument) withObject:nil afterDelay:0.0];
    }
    
#if (READER_DISABLE_IDLE == TRUE) // Option
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
#endif // end of READER_DISABLE_IDLE Option
    //
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    lastAppearSize = self.view.bounds.size; // Track view size
    
#if (READER_DISABLE_IDLE == TRUE) // Option
    
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
#endif // end of READER_DISABLE_IDLE Option
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)viewDidUnload
{
#ifdef DEBUG
    NSLog(@"%s", __FUNCTION__);
#endif
    
    mainToolbar = nil; mainPagebar = nil;
    
    theScrollView = nil; contentViews = nil; lastHideTime = nil;
    
    documentInteraction = nil; printInteraction = nil;
    
    lastAppearSize = CGSizeZero; currentPage = 0;
    
    [super viewDidUnload];
}

- (BOOL)prefersStatusBarHidden
{
    if(_isStatusBarWhiteStyle){
        return NO;
    }else{
        return YES;
    }
}
- (UIStatusBarStyle)preferredStatusBarStyle
{
    if(_isStatusBarWhiteStyle){
        return UIStatusBarStyleLightContent;
    }else{
        return UIStatusBarStyleDefault;
    }
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (userInterfaceIdiom == UIUserInterfaceIdiomPad) if (printInteraction != nil) [printInteraction dismissAnimated:NO];
    
    ignoreDidScroll = YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    if (CGSizeEqualToSize(theScrollView.contentSize, CGSizeZero) == false)
    {
        [self updateContentViews:theScrollView]; lastAppearSize = CGSizeZero;
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    ignoreDidScroll = NO;
}


#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (ignoreDidScroll == NO){
        [self layoutContentViews:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self handleScrollViewDidEnd:scrollView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self handleScrollViewDidEnd:scrollView];
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)recognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[UIScrollView class]]) return YES;
    
    return NO;
}

#pragma mark - UIGestureRecognizer action methods

- (void)decrementPageNumber
{
    if ((maximumPage > minimumPage) && (currentPage != minimumPage))
    {
        CGPoint contentOffset = theScrollView.contentOffset; // Offset
        
        contentOffset.x -= theScrollView.bounds.size.width; // View X--
        
        [theScrollView setContentOffset:contentOffset animated:YES];
    }
}

- (void)incrementPageNumber
{
    if ((maximumPage > minimumPage) && (currentPage != maximumPage))
    {
        CGPoint contentOffset = theScrollView.contentOffset; // Offset
        
        contentOffset.x += theScrollView.bounds.size.width; // View X++
        
        [theScrollView setContentOffset:contentOffset animated:YES];
    }
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateRecognized)
    {
        
        CGRect viewRect = recognizer.view.bounds; // View bounds
        
        CGPoint point = [recognizer locationInView:recognizer.view]; // Point
        
        CGRect areaRect = CGRectInset(viewRect, TAP_AREA_SIZE, 0.0f); // Area rect
        
        if (CGRectContainsPoint(areaRect, point) == true) // Single tap is inside area
        {
            NSNumber *key = [NSNumber numberWithInteger:currentPage]; // Page number key
            
            ReaderContentView *targetView = [contentViews objectForKey:key]; // View
            
            id target = [targetView processSingleTap:recognizer]; // Target object
            
            if (target != nil) // Handle the returned target object
            {
                if ([target isKindOfClass:[NSURL class]]) // Open a URL
                {
                    NSURL *url = (NSURL *)target; // Cast to a NSURL object
                    
                    if (url.scheme == nil) // Handle a missing URL scheme
                    {
                        NSString *www = url.absoluteString; // Get URL string
                        
                        if ([www hasPrefix:@"www"] == YES) // Check for 'www' prefix
                        {
                            NSString *http = [[NSString alloc] initWithFormat:@"http://%@", www];
                            
                            url = [NSURL URLWithString:http]; // Proper http-based URL
                        }
                    }
                    
                    if ([[UIApplication sharedApplication] openURL:url] == NO)
                    {
#ifdef DEBUG
                        NSLog(@"%s '%@'", __FUNCTION__, url); // Bad or unknown URL
#endif
                    }
                }
                else // Not a URL, so check for another possible object type
                {
                    if ([target isKindOfClass:[NSNumber class]]) // Goto page
                    {
                        NSInteger number = [target integerValue]; // Number
                        
                        [self showDocumentPage:number]; // Show the page
                    }
                }
            }
            else // Nothing active tapped in the target content view
            {
                if ([lastHideTime timeIntervalSinceNow] < -0.75) // Delay since hide
                {
                    if ((mainToolbar.alpha < 1.0f) || (mainPagebar.alpha < 1.0f)) // Hidden
                    {
                        [mainToolbar showToolbar];
                        [mainPagebar showPagebar]; // Show
                        self.isStatusBarWhiteStyle = true;
                    }
                    
                    else{
                        
                        
                    }
                }
            }
            
            return;
        }
        
        CGRect nextPageRect = viewRect;
        nextPageRect.size.width = TAP_AREA_SIZE;
        nextPageRect.origin.x = (viewRect.size.width - TAP_AREA_SIZE);
        
        if (CGRectContainsPoint(nextPageRect, point) == true) // page++
        {
            [self incrementPageNumber]; return;
        }
        
        CGRect prevPageRect = viewRect;
        prevPageRect.size.width = TAP_AREA_SIZE;
        
        if (CGRectContainsPoint(prevPageRect, point) == true) // page--
        {
            [self decrementPageNumber]; return;
        }
    }
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateRecognized)
    {
        CGRect viewRect = recognizer.view.bounds; // View bounds
        
        CGPoint point = [recognizer locationInView:recognizer.view]; // Point
        
        CGRect zoomArea = CGRectInset(viewRect, TAP_AREA_SIZE, TAP_AREA_SIZE); // Area
        
        if (CGRectContainsPoint(zoomArea, point) == true) // Double tap is inside zoom area
        {
            NSNumber *key = [NSNumber numberWithInteger:currentPage]; // Page number key
            
            ReaderContentView *targetView = [contentViews objectForKey:key]; // View
            
            switch (recognizer.numberOfTouchesRequired) // Touches count
            {
                    case 1: // One finger double tap: zoom++
                {
                    [targetView zoomIncrement:recognizer]; break;
                }
                    
                    case 2: // Two finger double tap: zoom--
                {
                    [targetView zoomDecrement:recognizer]; break;
                }
            }
            
            return;
        }
        
        CGRect nextPageRect = viewRect;
        nextPageRect.size.width = TAP_AREA_SIZE;
        nextPageRect.origin.x = (viewRect.size.width - TAP_AREA_SIZE);
        
        if (CGRectContainsPoint(nextPageRect, point) == true) // page++
        {
            [self incrementPageNumber]; return;
        }
        
        CGRect prevPageRect = viewRect;
        prevPageRect.size.width = TAP_AREA_SIZE;
        
        if (CGRectContainsPoint(prevPageRect, point) == true) // page--
        {
            [self decrementPageNumber]; return;
        }
    }
}

#pragma mark - ReaderContentViewDelegate methods

- (void)contentView:(ReaderContentView *)contentView touchesBegan:(NSSet *)touches
{
    if ((mainToolbar.alpha > 0.0f) || (mainPagebar.alpha > 0.0f))
    {
        if (touches.count == 1) // Single touches only
        {
            UITouch *touch = [touches anyObject]; // Touch info
            
            CGPoint point = [touch locationInView:self.view]; // Touch location
            
            CGRect areaRect = CGRectInset(self.view.bounds, TAP_AREA_SIZE, TAP_AREA_SIZE);
            
            if (CGRectContainsPoint(areaRect, point) == false) return;
        }
        
        [mainToolbar hideToolbar];
        [mainPagebar hidePagebar]; // Hide
        self.isStatusBarWhiteStyle = false;
        lastHideTime = [NSDate date]; // Set last hide time
    }
}

#pragma mark - ReaderMainToolbarDelegate methods

- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar doneButton:(UIButton *)button{
    
 
    
//    [self closeDocument]; // Close ReaderViewController
 
    
    // 点击按钮横向滚动
    self.displayMode = JYReaderDisplayModeHorizontal;
    [self updateContentViews:theScrollView];
    

    
    
}

- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar thumbsButton:(UIButton *)button
{
#if (READER_ENABLE_THUMBS == TRUE) // Option
    
    if (printInteraction != nil) [printInteraction dismissAnimated:NO];
    
    ThumbsViewController *thumbsViewController = [[ThumbsViewController alloc] initWithReaderDocument:document];
    
    thumbsViewController.title = self.title;
    thumbsViewController.delegate = self; // ThumbsViewControllerDelegate
    
    thumbsViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    thumbsViewController.modalPresentationStyle = UIModalPresentationFullScreen;
        
    [self presentViewController:thumbsViewController animated:NO completion:NULL];
    
#endif // end of READER_ENABLE_THUMBS Option
}

- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar exportButton:(UIButton *)button
{
    if (printInteraction != nil) [printInteraction dismissAnimated:YES];
    
    NSURL *fileURL = document.fileURL; // Document file URL
    
    documentInteraction = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
    
    documentInteraction.delegate = self; // UIDocumentInteractionControllerDelegate
    
    [documentInteraction presentOpenInMenuFromRect:button.bounds inView:button animated:YES];
}

- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar printButton:(UIButton *)button
{
    if ([UIPrintInteractionController isPrintingAvailable] == YES)
    {
        NSURL *fileURL = document.fileURL; // Document file URL
        
        if ([UIPrintInteractionController canPrintURL:fileURL] == YES)
        {
            printInteraction = [UIPrintInteractionController sharedPrintController];
            
            UIPrintInfo *printInfo = [UIPrintInfo printInfo];
            printInfo.duplex = UIPrintInfoDuplexLongEdge;
            printInfo.outputType = UIPrintInfoOutputGeneral;
            printInfo.jobName = document.fileName;
            
            printInteraction.printInfo = printInfo;
            printInteraction.printingItem = fileURL;
            printInteraction.showsPageRange = YES;
            
            if (userInterfaceIdiom == UIUserInterfaceIdiomPad) // Large device printing
            {
                [printInteraction presentFromRect:button.bounds inView:button animated:YES completionHandler:
                 ^(UIPrintInteractionController *pic, BOOL completed, NSError *error)
                 {
#ifdef DEBUG
                     if ((completed == NO) && (error != nil)) NSLog(@"%s %@", __FUNCTION__, error);
#endif
                 }
                 ];
            }
            else // Handle printing on small device
            {
                [printInteraction presentAnimated:YES completionHandler:
                 ^(UIPrintInteractionController *pic, BOOL completed, NSError *error)
                 {
#ifdef DEBUG
                     if ((completed == NO) && (error != nil)) NSLog(@"%s %@", __FUNCTION__, error);
#endif
                 }
                 ];
            }
        }
    }
}

- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar emailButton:(UIButton *)button
{
    if ([MFMailComposeViewController canSendMail] == NO) return;
    
    if (printInteraction != nil) [printInteraction dismissAnimated:YES];
    
    unsigned long long fileSize = [document.fileSize unsignedLongLongValue];
    
    if (fileSize < 15728640ull) // Check attachment size limit (15MB)
    {
        NSURL *fileURL = document.fileURL; NSString *fileName = document.fileName;
        
        NSData *attachment = [NSData dataWithContentsOfURL:fileURL options:(NSDataReadingMapped|NSDataReadingUncached) error:nil];
        
        if (attachment != nil) // Ensure that we have valid document file attachment data available
        {
            MFMailComposeViewController *mailComposer = [MFMailComposeViewController new];
            
            [mailComposer addAttachmentData:attachment mimeType:@"application/pdf" fileName:fileName];
            
            [mailComposer setSubject:fileName]; // Use the document file name for the subject
            
            mailComposer.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            mailComposer.modalPresentationStyle = UIModalPresentationFormSheet;
            
            mailComposer.mailComposeDelegate = self; // MFMailComposeViewControllerDelegate
            
            [self presentViewController:mailComposer animated:YES completion:NULL];
        }
    }
}

// 添加标注
- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar markButton:(UIButton *)button
{
#if (READER_BOOKMARKS == TRUE) // Option
    
        if (printInteraction != nil) [printInteraction dismissAnimated:YES];
    
    if ([document.bookmarks containsIndex:currentPage]) // Remove bookmark
    {
        [document.bookmarks removeIndex:currentPage];
        [mainToolbar setBookmarkState:NO];
    }
    else // Add the bookmarked page number to the bookmark index set
    {
        [document.bookmarks addIndex:currentPage];
        [mainToolbar setBookmarkState:YES];
    }
    // 标注没有存档啊？ 下次运行就没了
            [document archiveDocumentProperties];
    
#endif // end of READER_BOOKMARKS Option
}

#pragma mark - MFMailComposeViewControllerDelegate methods

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
#ifdef DEBUG
    if ((result == MFMailComposeResultFailed) && (error != NULL)) NSLog(@"%@", error);
#endif
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - UIDocumentInteractionControllerDelegate methods

- (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller
{
    documentInteraction = nil;
}

#pragma mark - ThumbsViewControllerDelegate methods

- (void)thumbsViewController:(ThumbsViewController *)viewController gotoPage:(NSInteger)page
{
#if (READER_ENABLE_THUMBS == TRUE) // Option
    
    [self showDocumentPage:page];
    
#endif // end of READER_ENABLE_THUMBS Option
}

- (void)dismissThumbsViewController:(ThumbsViewController *)viewController
{
#if (READER_ENABLE_THUMBS == TRUE) // Option
    
    [self dismissViewControllerAnimated:NO completion:NULL];
    
#endif // end of READER_ENABLE_THUMBS Option
}

#pragma mark - ReaderMainPagebarDelegate methods

- (void)pagebar:(ReaderMainPagebar *)pagebar gotoPage:(NSInteger)page
{
    [self showDocumentPage:page];
}

#pragma mark - UIApplication notification methods

- (void)applicationWillResign:(NSNotification *)notification
{
    [document archiveDocumentProperties]; // Save any ReaderDocument changes
    
    if (userInterfaceIdiom == UIUserInterfaceIdiomPad) if (printInteraction != nil) [printInteraction dismissAnimated:NO];
}
@end
