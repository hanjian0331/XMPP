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
    XMPPResultTypeNetErr
}XMPPResultType;

typedef void (^XMPPRresultBlock)(XMPPResultType type);


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)logout;
- (void)xmppUserLogin:(XMPPRresultBlock)resultBlock;
@end

