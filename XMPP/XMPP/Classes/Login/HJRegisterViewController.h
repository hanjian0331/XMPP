//
//  HJRegisterViewController.h
//  XMPP
//
//  Created by HJ on 15/3/27.
//  Copyright (c) 2015年 HJ. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HJRegisterViewControllerDelegate <NSObject>
- (void)HJRegisterViewControllerDidFinishRegister;
@end


@interface HJRegisterViewController : UIViewController
@property (nonatomic, weak) id<HJRegisterViewControllerDelegate> delegate;
@end
