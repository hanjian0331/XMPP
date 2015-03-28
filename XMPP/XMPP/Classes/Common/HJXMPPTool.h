//
//  HJXMPPTool.h
//  XMPP
//
//  Created by HJ on 15/3/27.
//  Copyright (c) 2015年 HJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singleton.h"
#import "XMPP.h"

typedef enum {
    XMPPResultTypeLoginSuccess,
    XMPPResultTypeLoginFailure,
    XMPPResultTypeNetErr,
    XMPPResultTypeRegisterSuccess,
    XMPPResultTypeRegisterFailure
}XMPPResultType;

typedef void (^XMPPResultBlock)(XMPPResultType type);

@interface HJXMPPTool : NSObject

singleton_interface(HJXMPPTool)

//注册操作：YES
@property (nonatomic, assign, getter=isRegisterOperation) BOOL registerOperation;

@property (nonatomic, strong) XMPPvCardTempModule *vCard;

- (void)xmppUserLogout;
- (void)xmppUserLogin:(XMPPResultBlock)resultBlock;
- (void)xmppUserRegister:(XMPPResultBlock)resultBlock;
@end
