//
//  HJXMPPTool.m
//  XMPP
//
//  Created by HJ on 15/3/27.
//  Copyright (c) 2015年 HJ. All rights reserved.
//

#import "HJXMPPTool.h"

@interface HJXMPPTool()<XMPPStreamDelegate>
{
   
    XMPPResultBlock _resultBlock;
    
    XMPPvCardCoreDataStorage *_vCardStorage;
    XMPPvCardAvatarModule *_avatar;
    XMPPReconnect *_reconnect;
    

}
@end

@implementation HJXMPPTool

singleton_implementation(HJXMPPTool);
#pragma mark - 私有方法
#pragma mark 初始化XMPPStream
- (void)setupXMPPStream
{
    _XMPPStream = [[XMPPStream alloc] init];
#warning 每一个模块创建以后都需要激活
    //自动连接模块
    _reconnect = [[XMPPReconnect alloc] init];
    [_reconnect activate:_XMPPStream];
    
    //创建
    _vCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
    _vCard = [[XMPPvCardTempModule alloc] initWithvCardStorage:_vCardStorage];
    //激活
    [_vCard activate:_XMPPStream];
    //头像模块
    _avatar = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:_vCard];
    [_avatar activate:_XMPPStream];
    //花名册
    _rosterSrorage = [[XMPPRosterCoreDataStorage alloc] init];
    _roster = [[XMPPRoster alloc] initWithRosterStorage:_rosterSrorage];
    [_roster activate:_XMPPStream];
    
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
    NSString *user = nil;
    if (self.isRegisterOperation) {
        user = [HJUserInfo sharedHJUserInfo].regUser;
    }else{
        user = [HJUserInfo sharedHJUserInfo].user;
    }
    
    XMPPJID *myJID = [XMPPJID jidWithUser:user domain:@"CCR.local" resource:@"iPhone"];
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
    NSString *pwd = [HJUserInfo sharedHJUserInfo].pwd;
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
#pragma mark 销毁
- (void)teardownXmpp
{
    //停止模块
    [_XMPPStream removeDelegate:self];
    [_reconnect deactivate];
    [_avatar deactivate];
    [_vCard deactivate];
    [_roster deactivate];
    
    //断块连接
    [_XMPPStream disconnect];
    //清空资源
    _reconnect = nil;
    _vCard = nil;
    _vCardStorage = nil;
    _avatar = nil;
    _XMPPStream = nil;
    _roster = nil;
    _rosterSrorage = nil;
}
#pragma mark - XMPPStream delegate
#pragma mark 与主机连接成功
- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    HJLog(@"与主机连接成功");
    if (self.isRegisterOperation) {
        NSString *pwd = [HJUserInfo sharedHJUserInfo].regPwd;
        [_XMPPStream registerWithPassword:pwd error:nil];
    }else{
        [self sendPwsToHost];
    }
    
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
#pragma mark 注册成功
- (void)xmppStreamDidRegister:(XMPPStream *)sender
{
    HJLog(@"注册成功");
    if(_resultBlock){
        _resultBlock(XMPPResultTypeRegisterSuccess);
    }
}
- (void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error
{
    HJLog(@"注册失败");
    if(_resultBlock){
        _resultBlock(XMPPResultTypeRegisterFailure);
    }
}
#pragma mark - 公共方法
#pragma mark 注销
- (void)xmppUserLogout
{
    //发送离线消息
    XMPPPresence *offline = [XMPPPresence presenceWithType:@"unavailable"];
    [_XMPPStream sendElement:offline];
    //与主机断开连接
    [_XMPPStream disconnect];
    
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
//    self.window.rootViewController = storyboard.instantiateInitialViewController;
    [UIStoryboard showInitialVCWithName:@"Login"];
    
    //登陆状态改为no
    [HJUserInfo sharedHJUserInfo].loginStatus = NO;
    [[HJUserInfo sharedHJUserInfo] saveUserInfoToSanbox];
}
#pragma mark 登陆
- (void)xmppUserLogin:(XMPPResultBlock)resultBlock
{
    _resultBlock = resultBlock;
    //如果以前连接过要断开
    [_XMPPStream disconnect];
    //连接主机
    [self connentToHost];
}
#pragma mark 注册
- (void)xmppUserRegister:(XMPPResultBlock)resultBlock
{
    _resultBlock = resultBlock;
    //如果以前连接过要断开
    [_XMPPStream disconnect];
    //连接主机
    [self connentToHost];
    //发送注册的密码
    
}

- (void)dealloc
{
    [self teardownXmpp];
}

@end
