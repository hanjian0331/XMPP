//
//  HJUserInfo.m
//  XMPP
//
//  Created by HJ on 15/3/26.
//  Copyright (c) 2015年 HJ. All rights reserved.
//

#import "HJUserInfo.h"

#define UserKey @"user"
#define PwdKey @"pwd"
#define LoginStatusKey @"LoginStatus"


@implementation HJUserInfo

singleton_implementation(HJUserInfo);

- (void)saveUserInfoToSanbox
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.user forKey:UserKey];
    [defaults setObject:self.pwd forKey:PwdKey];
    [defaults setBool:self.loginStatus forKey:LoginStatusKey];
    [defaults synchronize];
}

- (void)loadUserInfoFromSanbox
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.user = [defaults objectForKey:UserKey];
    self.pwd = [defaults objectForKey:PwdKey];
    self.loginStatus = [defaults boolForKey:LoginStatusKey];
}

- (NSString *)jid
{
    return [NSString stringWithFormat:@"%@%@",self.user,DomainKey];
}
@end
