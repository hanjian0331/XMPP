//
//  HJOtherLoginViewController.m
//  XMPP
//
//  Created by HJ on 15/3/25.
//  Copyright (c) 2015年 HJ. All rights reserved.
//

#import "HJOtherLoginViewController.h"
#import "AppDelegate.h"

@interface HJOtherLoginViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightConstraint;
@property (weak, nonatomic) IBOutlet UITextField *userField;
@property (weak, nonatomic) IBOutlet UITextField *pwdField;
@property (weak, nonatomic) IBOutlet UIButton *loinBtn;

@end

@implementation HJOtherLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //判断当前的设备类型，改变左右两边约束距离
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone){
        self.leftConstraint.constant = 10;
        self.rightConstraint.constant = 10;
    }
    //设置textfiled背景
    self.userField.background = [UIImage stretchedImageWithName:@"operationbox_text"];
    self.pwdField.background = [UIImage stretchedImageWithName:@"operationbox_text"];
    [self.loinBtn setResizeN_BG:@"fts_green_btn" H_BG:@"fts_green_btn_HL"];
}

- (IBAction)loginBtnClick:(UIButton *)sender {
    //把用户名和密码放到沙盒里面
    NSString *user = self.userField.text;
    NSString *pwd = self.pwdField.text;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:user forKey:@"user"];
    [defaults setObject:pwd forKey:@"pwd"];
    [defaults synchronize];
    
    //隐藏键盘
    [self.view endEditing:YES];
    
    //显示正在登录
    [MBProgressHUD showMessage:@"正在登录..." toView:self.view];
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    
    __weak typeof (self) weekSelf = self;
    [delegate xmppUserLogin:^(XMPPResultType type) {
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
    //隐藏模态窗口
    [self dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"登录成功");
    //登录成功后到主界面
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    //                self.window.rootViewController = storyboard.instantiateInitialViewController;
    self.view.window.rootViewController = storyboard.instantiateInitialViewController;
}

- (void)dealloc
{
    NSLog(@"%s",__func__);
}
@end
