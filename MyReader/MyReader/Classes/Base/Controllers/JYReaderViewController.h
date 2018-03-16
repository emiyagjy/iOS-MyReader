//
//  JYReaderViewController.h
//  MyReader
//
//  Created by GujyHy on 2018/3/9.
//  Copyright © 2018年 Gujy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReaderDocument.h"

typedef NS_ENUM(NSUInteger,JYReaderDisplayMode){
    JYReaderDisplayModeVertical = 0,
    JYReaderDisplayModeHorizontal
};


@class JYReaderViewController;

@protocol ReaderViewControllerDelegate <NSObject>

@optional // Delegate protocols

- (void)dismissReaderViewController:(JYReaderViewController *)viewController;

@end

@interface JYReaderViewController : UIViewController

@property (nonatomic, weak, readwrite) id <ReaderViewControllerDelegate> delegate;

@property (nonatomic,assign) JYReaderDisplayMode displayMode;
@property (nonatomic,assign) BOOL isSingleContinue;

- (instancetype)initWithReaderDocument:(ReaderDocument *)object;

@end
