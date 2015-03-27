//
//  AppDelegate.h
//  XMPP
//
//  Created by HJ on 15/3/25.
//  Copyright (c) 2015年 HJ. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    XMPPResultTypeLoginSuccess,
    XMPPResultTypeLoginFailure,
    XMPPResultTypeNetErr,
    XMPPResultTypeRegisterSuccess,
    XMPPResultTypeRegisterFailure
}XMPPResultType;

typedef void (^XMPPResultBlock)(XMPPResultType type);


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

//注册操作：YES
@property (nonatomic, assign, getter=isRegisterOperation) BOOL registerOperation;


- (void)xmppUserLogout;
- (void)xmppUserLogin:(XMPPResultBlock)resultBlock;
- (void)xmppUserRegister:(XMPPResultBlock)resultBlock;
@end

