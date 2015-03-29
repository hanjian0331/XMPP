//
//  HJMeViewController.m
//  XMPP
//
//  Created by HJ on 15/3/26.
//  Copyright (c) 2015年 HJ. All rights reserved.
//

#import "HJMeViewController.h"
#import "AppDelegate.h"
#import "XMPPvCardTemp.h"

@interface HJMeViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *headView;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLable;
@property (weak, nonatomic) IBOutlet UILabel *numberLable;

@end

@implementation HJMeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //使用coreData获取数据
    //1.上下文关联数据库
    //2.创建FetchRequest请求
    //3.过滤和排序
    //4.执行请求
    //xmpp有方法可以直接获取个人信息
    
    XMPPvCardTemp *myvCardTemp = [HJXMPPTool sharedHJXMPPTool].vCard.myvCardTemp;
    if (myvCardTemp.photo) {
        self.headView.image = [UIImage imageWithData: myvCardTemp.photo];
    }
    self.nickNameLable.text = myvCardTemp.nickname;
    NSString *user = [HJUserInfo sharedHJUserInfo].user;
    self.numberLable.text = [NSString stringWithFormat:@"账号:%@",user];
}


- (IBAction)logoutBtnClick:(UIBarButtonItem *)sender {
//    AppDelegate *app = [UIApplication sharedApplication].delegate;
//    [app xmppUserLogout];
    [[HJXMPPTool sharedHJXMPPTool] xmppUserLogout];
}

@end
