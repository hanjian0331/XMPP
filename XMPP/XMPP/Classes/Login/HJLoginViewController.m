//
//  HJLoginViewController.m
//  XMPP
//
//  Created by HJ on 15/3/26.
//  Copyright (c) 2015年 HJ. All rights reserved.
//

#import "HJLoginViewController.h"
#import "HJRegisterViewController.h"

@interface HJLoginViewController ()<HJRegisterViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *userLable;
@property (weak, nonatomic) IBOutlet UITextField *pwdField;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;

@end

@implementation HJLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //设置textfield和button的样式
    self.pwdField.background = [UIImage stretchedImageWithName:@"operationbox_text"];
    
//    UIImageView *lockView = [[UIImageView alloc] init];
//    lockView.image = [UIImage imageNamed:@"Card_Lock"];
//    lockView.bounds = CGRectMake(0, 0, 20, 20);
//    self.pwdField.leftViewMode = UITextFieldViewModeAlways;
    [self.pwdField addLeftViewWithImage:@"Card_Lock"];
    
    //设置用户名为上次登录用户名
    NSString *user = [HJUserInfo sharedHJUserInfo].user;
    self.userLable.text = user;
    
    [self.loginBtn setResizeN_BG:@"fts_green_btn" H_BG:@"fts_green_btn_HL"];
}

- (IBAction)loginBtnClickj:(UIButton *)sender {
    //把用户名和密码放到沙盒里面
    HJUserInfo *userInfo = [HJUserInfo sharedHJUserInfo];
    userInfo.user = self.userLable.text;
    userInfo.pwd = self.pwdField.text;
    
    [super login];

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //获取注册控制器
    id destVc = segue.destinationViewController;
    if ([destVc isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = destVc;
        
        HJRegisterViewController *top = (HJRegisterViewController *)nav.topViewController;
        if ([top isKindOfClass:[HJRegisterViewController class]]) {
            top.delegate = self;
        }
    }
}
#pragma mark - RegisterViewController delegate
- (void)HJRegisterViewControllerDidFinishRegister
{
    [MBProgressHUD showSuccess:@"注册成功" toView:self.view];
    self.userLable.text = [HJUserInfo sharedHJUserInfo].regUser;
    
}
@end
