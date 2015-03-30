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
extern NSString *const HJLoginStatusChangeNotification;

typedef enum {
    XMPPResultTypeConnecting,
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

@property (nonatomic, strong, readonly) XMPPvCardTempModule *vCard;
@property (nonatomic, strong, readonly) XMPPRosterCoreDataStorage *rosterSrorage;
@property (nonatomic, strong, readonly) XMPPRoster *roster;
@property (nonatomic, strong, readonly) XMPPStream *XMPPStream;
@property (nonatomic, strong, readonly) XMPPMessageArchivingCoreDataStorage *messageCoreDataStorage;
- (void)xmppUserLogout;
- (void)xmppUserLogin:(XMPPResultBlock)resultBlock;
- (void)xmppUserRegister:(XMPPResultBlock)resultBlock;

@end
