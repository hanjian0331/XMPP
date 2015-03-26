//
//  HJLoginViewController.m
//  XMPP
//
//  Created by HJ on 15/3/26.
//  Copyright (c) 2015年 HJ. All rights reserved.
//

#import "HJLoginViewController.h"

@interface HJLoginViewController ()
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
  
}

@end
