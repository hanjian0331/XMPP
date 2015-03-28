//
//  HJEditProfileViewController.h
//  XMPP
//
//  Created by HJ on 15/3/28.
//  Copyright (c) 2015年 HJ. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HJEditProfileViewControllerDelegate <NSObject>

- (void)editProfileViewControllerDidSave;

@end


@interface HJEditProfileViewController : UITableViewController

@property (nonatomic, strong)UITableViewCell *myCell;

@property (nonatomic, weak)id<HJEditProfileViewControllerDelegate> delegate;

@end
