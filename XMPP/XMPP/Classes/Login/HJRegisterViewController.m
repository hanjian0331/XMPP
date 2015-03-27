//
//  HJRegisterViewController.m
//  XMPP
//
//  Created by HJ on 15/3/27.
//  Copyright (c) 2015年 HJ. All rights reserved.
//

#import "HJRegisterViewController.h"
#import "AppDelegate.h"

@interface HJRegisterViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightConstraint;
@property (weak, nonatomic) IBOutlet UITextField *userField;
@property (weak, nonatomic) IBOutlet UITextField *pwdField;
@property (weak, nonatomic) IBOutlet UIButton *registerBtn;

@end

@implementation HJRegisterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"注册";
    
    //判断当前的设备类型，改变左右两边约束距离
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone){
        self.leftConstraint.constant = 10;
        self.rightConstraint.constant = 10;
    }
    //设置textfiled背景
    self.userField.background = [UIImage stretchedImageWithName:@"operationbox_text"];
    self.pwdField.background = [UIImage stretchedImageWithName:@"operationbox_text"];
    [self.registerBtn setResizeN_BG:@"fts_green_btn" H_BG:@"fts_green_btn_HL"];
}


- (IBAction)registerBtnClick
{
    //隐藏密码
    [self.view endEditing:YES];
    
    //判断用户输入的是否为手机号码
    if (![self.userField isTelphoneNum]) {
        [MBProgressHUD showError:@"请输入正确的手机号码" toView:self.view];
        return;
    }
    
    HJUserInfo *userinfo = [HJUserInfo sharedHJUserInfo];
    userinfo.regUser = self.userField.text;
    userinfo.regPwd = self.pwdField.text;

    AppDelegate *app = [UIApplication sharedApplication].delegate;
    app.registerOperation = YES;
    
    //提示
    [MBProgressHUD showMessage:@"正在注册" toView:self.view];
    
    __weak typeof(self) weakSelf = self;
    [app xmppUserRegister:^(XMPPResultType type) {
        [weakSelf handleResultTye:type];
    }];
}

- (void)handleResultTye:(XMPPResultType)type
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        switch (type) {
            case XMPPResultTypeRegisterSuccess:
                //回到上个控制器
                [self dismissViewControllerAnimated:YES completion:nil];
                if ([self.delegate respondsToSelector:@selector(HJRegisterViewControllerDidFinishRegister)]) {
                    [self.delegate HJRegisterViewControllerDidFinishRegister];
                }
                break;
            case XMPPResultTypeRegisterFailure:
                [MBProgressHUD showError:@"注册失败,已有此用户名" toView:self.view];
                break;
            case XMPPResultTypeNetErr:
                [MBProgressHUD showError:@"网络不给力" toView:self.view];
                break;
            default:
                break;
        }
    });
}
- (IBAction)textChange:(UITextField *)sender {
    BOOL enable = (self.userField.text.length != 0 && self.pwdField.text.length != 0);
    self.registerBtn.enabled = enable;
}

- (IBAction)cancel:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
