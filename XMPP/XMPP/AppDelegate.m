//
//  AppDelegate.m
//  XMPP
//
//  Created by HJ on 15/3/25.
//  Copyright (c) 2015年 HJ. All rights reserved.
//

#import "AppDelegate.h"
#import "XMPP.h"

@interface AppDelegate ()<XMPPStreamDelegate>
{
    XMPPStream *_XMPPStream;
    XMPPRresultBlock _resultBlock;
}
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
//    [self connentToHost];
    
    return YES;
}

#pragma mark - 私有方法
#pragma mark 初始化XMPPStream
- (void)setupXMPPStream
{
    _XMPPStream = [[XMPPStream alloc] init];
    
    //设置代理
    [_XMPPStream addDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];

}
#pragma mark 开始连接到服务器
- (void)connentToHost
{
    HJLog(@"开始连接到服务器");
    if (!_XMPPStream) {
        [self setupXMPPStream];
    }
    //设置JID
    //resource标实用户的客户端］
    NSString *user = [[NSUserDefaults standardUserDefaults] objectForKey:@"user"];
    
    XMPPJID *myJID = [XMPPJID jidWithUser:user domain:@"CCR.local" resource:@"iPHone"];
    _XMPPStream.myJID = myJID;
    
    //设置服务器的域名
    _XMPPStream.hostName = @"10.82.197.21";
    //端口
    _XMPPStream.hostPort = 5222;
    
    NSError *err = nil;
    if (![_XMPPStream connectWithTimeout:XMPPStreamTimeoutNone error:&err]) {
        HJLog(@"%@",err);
    }
}
#pragma mark 发送密码
- (void)sendPwsToHost
{
    HJLog(@"发送密码给主机");
    NSError *err = nil;
     NSString *pwd = [[NSUserDefaults standardUserDefaults] objectForKey:@"pwd"];
    if (![_XMPPStream authenticateWithPassword:pwd error:&err]) {
        HJLog(@"%@",err);
    }
    
}
#pragma mark 发送在线消息
- (void)sendOnlineToHost
{
    HJLog(@"发送在线消息");
    XMPPPresence *presence = [XMPPPresence presence];
    [_XMPPStream sendElement:presence];
}

#pragma mark - XMPPStream delegate
#pragma mark 与主机连接成功
- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    HJLog(@"与主机连接成功");
    [self sendPwsToHost];
}
#pragma mark 与主机断开连接
- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    if (error && _resultBlock) {
        _resultBlock(XMPPResultTypeNetErr);
    }
    HJLog(@"与主机断开连接:%@",error);
}
#pragma mark 授权成功
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    HJLog(@"授权成功");
    [self sendOnlineToHost];
    
    if (_resultBlock) {
        _resultBlock(XMPPResultTypeLoginSuccess);
    }

}
#pragma mark 授权失败
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error
{
    HJLog(@"授权失败\n%@",error);
    if (_resultBlock) {
        _resultBlock(XMPPResultTypeLoginFailure);
    }
}

#pragma mark - 公共方法
#pragma mark 注销
- (void)logout
{
    //发送离线消息
    XMPPPresence *offline = [XMPPPresence presenceWithType:@"unavailable"];
    [_XMPPStream sendElement:offline];
    //与主机断开连接
    [_XMPPStream disconnect];
}

- (void)xmppUserLogin:(XMPPRresultBlock)resultBlock
{
    _resultBlock = resultBlock;
    //如果以前连接过要断开
    [_XMPPStream disconnect];
    //连接主机
    [self connentToHost];
}
@end
