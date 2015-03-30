//
//  HJInputView.m
//  XMPP
//
//  Created by HJ on 15/3/29.
//  Copyright (c) 2015年 HJ. All rights reserved.
//

#import "HJInputView.h"

@implementation HJInputView

+ (instancetype)inputView
{
    return [[[NSBundle mainBundle] loadNibNamed:@"HJInputView" owner:nil options:nil] lastObject];
}

@end