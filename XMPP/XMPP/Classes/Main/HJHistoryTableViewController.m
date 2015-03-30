//
//  HJHistoryTableViewController.m
//  XMPP
//
//  Created by HJ on 15/3/30.
//  Copyright (c) 2015年 HJ. All rights reserved.
//

#import "HJHistoryTableViewController.h"

@interface HJHistoryTableViewController ()
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;

@end

@implementation HJHistoryTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginStatusChange:)
                                                 name:HJLoginStatusChangeNotification object:nil];
    
}

- (void)loginStatusChange:(NSNotification *)noti
{
    dispatch_async(dispatch_get_main_queue(), ^{
        HJLog(@"%@",noti.userInfo);
        NSInteger status = [noti.userInfo[@"resultType"] integerValue];
        
        switch (status) {
            case XMPPResultTypeConnecting:
                [self.indicatorView startAnimating];
                break;
            case XMPPResultTypeNetErr:
                [self.indicatorView stopAnimating];
                break;
            case XMPPResultTypeLoginSuccess:
                [self.indicatorView stopAnimating];
                break;
            case XMPPResultTypeLoginFailure:
                [self.indicatorView stopAnimating];
                break;
            default:
                break;
        }
    });

}


@end
