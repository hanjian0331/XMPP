//
//  HJAddContactViewController.m
//  XMPP
//
//  Created by HJ on 15/3/29.
//  Copyright (c) 2015年 HJ. All rights reserved.
//

#import "HJAddContactViewController.h"

@interface HJAddContactViewController ()<UITextFieldDelegate>

@end

@implementation HJAddContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSString *user = textField.text;
    if (![textField isTelphoneNum]) {
        [self showAlert:@"请输入正确的手机号码"];
        return YES;
    }
    //判断是否自己或者好友已经存在
    if ([user isEqualToString:[HJUserInfo sharedHJUserInfo].user]) {
        [self showAlert:@"不能添加自己"];
    }
     XMPPJID *friendJid = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@%@", user, DomainKey]];
        if([[HJXMPPTool sharedHJXMPPTool].rosterSrorage userExistsWithJID:friendJid xmppStream:[HJXMPPTool sharedHJXMPPTool].XMPPStream]){
            [self showAlert:@"已经是你的好友了"];
    }
   
    [[HJXMPPTool sharedHJXMPPTool].roster subscribePresenceToUser:friendJid];
    return YES;
}

- (void)showAlert:(NSString *)msg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:msg delegate:self cancelButtonTitle:@"谢谢" otherButtonTitles:nil, nil];
    [alert show];
}


@end
