//
//  HJInputView.h
//  XMPP
//
//  Created by HJ on 15/3/29.
//  Copyright (c) 2015年 HJ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HJInputView : UIView
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;

+ (instancetype)inputView;

@end
