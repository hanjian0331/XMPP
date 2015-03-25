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
}
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self connentToHost];
    
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
#pragma mark 连接到服务器
- (void)connentToHost
{
    if (!_XMPPStream) {
        [self setupXMPPStream];
    }
    //设置JID
    //resource标实用户的客户端
    XMPPJID *myJID = [XMPPJID jidWithUser:@"lisi" domain:@"CCR.local" resource:@"iPHone"];
    _XMPPStream.myJID = myJID;
    
    //设置服务器的域名
    _XMPPStream.hostName = @"10.82.197.21";
    //端口
    _XMPPStream.hostPort = 5222;
    
    NSError *err = nil;
    if (![_XMPPStream connectWithTimeout:XMPPStreamTimeoutNone error:&err]) {
        NSLog(@"%@",err);
    }
}
#pragma mark 发送密码
- (void)sendPwsToHost
{
    NSError *err = nil;
    if (![_XMPPStream authenticateWithPassword:@"lisi" error:&err]) {
        NSLog(@"%@",err);
    }
    
}
#pragma mark 发送在线消息
- (void)sendOnlineToHost
{
    XMPPPresence *presence = [XMPPPresence presence];
    [_XMPPStream sendElement:presence];
}

#pragma mark - XMPPStream delegate
#pragma mark 与主机连接成功
- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    NSLog(@"与主机连接成功");
    [self sendPwsToHost];
}
#pragma mark 断开连接
- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    NSLog(@"与主机断开连接\n%@",error);
}
#pragma mark 授权成功
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    NSLog(@"授权成功");
    [self sendOnlineToHost];
}
#pragma mark 授权失败
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error
{
    NSLog(@"授权失败\n%@",error);
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
@end
