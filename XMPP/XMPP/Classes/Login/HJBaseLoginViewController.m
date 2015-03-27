//
//  BaseLoginViewController.m
//  XMPP
//
//  Created by HJ on 15/3/26.
//  Copyright (c) 2015年 HJ. All rights reserved.
//

#import "HJBaseLoginViewController.h"
#import "AppDelegate.h"

@interface HJBaseLoginViewController ()

@end

@implementation HJBaseLoginViewController

- (void)login
{

    //隐藏键盘
    [self.view endEditing:YES];
    
    //显示正在登录
    [MBProgressHUD showMessage:@"正在登录..." toView:self.view];
    
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    
    app.registerOperation = NO;
    __weak typeof (self) weekSelf = self;
    
    [app xmppUserLogin:^(XMPPResultType type) {
        [weekSelf handleResultTye:type];
    }];
}

- (void)handleResultTye:(XMPPResultType)type
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        switch (type) {
            case XMPPResultTypeLoginSuccess:
                [self enterToMainPage];
                break;
            case XMPPResultTypeLoginFailure:
                NSLog(@"登录失败");
                [MBProgressHUD showError:@"用户名或密码错误" toView:self.view];
                break;
            case XMPPResultTypeNetErr:
                [MBProgressHUD showError:@"网络不给力" toView:self.view];
                break;
            default:
                break;
        }
    });
}
- (void)enterToMainPage
{
    //更改为登录状态
    [HJUserInfo sharedHJUserInfo].loginStatus = YES;
    //把用户数据保存到沙盒
    [[HJUserInfo sharedHJUserInfo] saveUserInfoToSanbox];
    //隐藏模态窗口
    [self dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"登录成功");
    //登录成功后到主界面
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    //                self.window.rootViewController = storyboard.instantiateInitialViewController;
    self.view.window.rootViewController = storyboard.instantiateInitialViewController;
}
@end
