//
//  AppDelegate.m
//  XMPP
//
//  Created by HJ on 15/3/25.
//  Copyright (c) 2015年 HJ. All rights reserved.
//

#import "AppDelegate.h"
#import "XMPP.h"
#import "HJNavigationController.h"
#import "DDLog.h"
#import "DDTTYLogger.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //沙盒
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
    HJLog(@"%@",path);
    //打开xmpp日志
//    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    
    //设置导航栏的背景
    [HJNavigationController setupNavTheme];
    
    [[HJUserInfo sharedHJUserInfo] loadUserInfoFromSanbox];
    
    //判断用户的登陆状态
    if ([HJUserInfo sharedHJUserInfo].loginStatus) {
        self.window.rootViewController = [UIStoryboard storyboardWithName:@"Main" bundle:nil].instantiateInitialViewController;
        //自动登录服务器
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[HJXMPPTool sharedHJXMPPTool] xmppUserLogin:nil];
        });
        
    }
    
    //注册应用接受通知
    if([[UIDevice currentDevice].systemVersion doubleValue] > 8.0){
        UIUserNotificationSettings *setting = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil];
        [application registerUserNotificationSettings:setting];
    }
    
    return YES;
}


@end
