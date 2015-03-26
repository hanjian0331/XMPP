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
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;

@end

@implementation HJOtherLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"其他方式登陆";
    
    //判断当前的设备类型，改变左右两边约束距离
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone){
        self.leftConstraint.constant = 10;
        self.rightConstraint.constant = 10;
    }
    //设置textfiled背景
    self.userField.background = [UIImage stretchedImageWithName:@"operationbox_text"];
    self.pwdField.background = [UIImage stretchedImageWithName:@"operationbox_text"];
    [self.loginBtn setResizeN_BG:@"fts_green_btn" H_BG:@"fts_green_btn_HL"];
}

- (IBAction)loginBtnClick:(UIButton *)sender
{
    //把用户名和密码放到沙盒里面
    HJUserInfo *userInfo = [HJUserInfo sharedHJUserInfo];
    userInfo.user = self.userField.text;
    userInfo.pwd = self.pwdField.text;
    
    [self login];
}


- (IBAction)cancel:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc
{
    NSLog(@"%s",__func__);
}
@end
