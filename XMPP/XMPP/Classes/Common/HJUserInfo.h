//
//  HJUserInfo.h
//  XMPP
//
//  Created by HJ on 15/3/26.
//  Copyright (c) 2015年 HJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singleton.h"

@interface HJUserInfo : NSObject

singleton_interface(HJUserInfo);

@property (nonatomic, copy) NSString *user;
@property (nonatomic, copy) NSString *pwd;

//登录状态，登录成功为YES
@property (nonatomic, assign) BOOL loginStatus;

- (void)saveUserInfoToSanbox;
- (void)loadUserInfoFromSanbox;
@end
