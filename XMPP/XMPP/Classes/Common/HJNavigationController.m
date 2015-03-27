//
//  HJNavigationController.m
//  XMPP
//
//  Created by HJ on 15/3/26.
//  Copyright (c) 2015年 HJ. All rights reserved.
//

#import "HJNavigationController.h"

@interface HJNavigationController ()

@end

@implementation HJNavigationController

+ (void)initialize
{
    
    
   
}

+ (void)setupNavTheme
{
    UINavigationBar *navBar = [UINavigationBar appearance];
    //NAV的背景
    [navBar setBackgroundImage:[UIImage stretchedImageWithName:@"topbarbg_ios7"] forBarMetrics:UIBarMetricsDefault];
     //字体
    NSMutableDictionary *att = [NSMutableDictionary dictionary];
    att[NSForegroundColorAttributeName] = [UIColor whiteColor];
    att[NSFontAttributeName] = [UIFont systemFontOfSize:20];
    //状态栏的样式
    //xcode5以上，默认的样式由控制器决定
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}
@end
