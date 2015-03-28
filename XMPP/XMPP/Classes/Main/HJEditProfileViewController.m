//
//  HJEditProfileViewController.m
//  XMPP
//
//  Created by HJ on 15/3/28.
//  Copyright (c) 2015年 HJ. All rights reserved.
//

#import "HJEditProfileViewController.h"

@interface HJEditProfileViewController ()
@property (weak, nonatomic) IBOutlet UITextField *textfield;

@end

@implementation HJEditProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //右边按钮
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveBtnClick)];
    
    self.title = self.myCell.textLabel.text;
    self.textfield.text = self.myCell.detailTextLabel.text;
}

- (void)saveBtnClick
{
    self.myCell.detailTextLabel.text = self.textfield.text;
    
    [self.myCell layoutSubviews];
    
    [self.navigationController popViewControllerAnimated:YES];
    
    if ([self.delegate respondsToSelector:@selector(editProfileViewControllerDidSave)]) {
        [self.delegate editProfileViewControllerDidSave];
    }
}

@end
