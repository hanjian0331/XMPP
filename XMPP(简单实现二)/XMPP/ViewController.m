//
//  ViewController.m
//  XMPP
//
//  Created by HJ on 15/3/24.
//  Copyright (c) 2015年 HJ. All rights reserved.
//

#import "ViewController.h"
#import "GCDAsyncSocket.h"

@interface ViewController ()<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,GCDAsyncSocketDelegate>
{
    GCDAsyncSocket *_asyncSocket;
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputViewConstraint;
@property (weak, nonatomic) IBOutlet UITableView *tableVIew;
@property (nonatomic, strong) NSMutableArray *chatMessages;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //监听键盘
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kbFrmWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (NSMutableArray *)chatMessages
{
    if (!_chatMessages) {
        _chatMessages = [NSMutableArray array];
    }
    return _chatMessages;
}

- (void)kbFrmWillChange:(NSNotification *)noti
{
    //获取窗口高度
    CGFloat windowsH = [UIScreen mainScreen].bounds.size.height;
    //键盘结束的y
    CGRect kbEnfFrm = [noti.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    self.inputViewConstraint.constant = windowsH - kbEnfFrm.origin.y;
}

- (IBAction)connentToHost:(UIBarButtonItem *)sender
{
    NSString *host = @"10.82.197.21";
    int port = 12345;
    
    //创建一个socket对象
    _asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    //连接
    NSError *error;
    [_asyncSocket connectToHost:host onPort:port error:&error];
    if (error) {
        NSLog(@"%@",error);
    }
}

#pragma mark - asyncSocket delegate
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    NSLog(@"连接主机成功");
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    if (err) {
        NSLog(@"与主机断开连接:%@",err);
    }
}

- (IBAction)loginBtnClick:(UIBarButtonItem *)sender
{
    //登陆发送数据格式为“iam:username”
    //发送消息数据格式为“msg：message”
    NSString *loginStr = @"iam:HJ";
    NSData *data = [loginStr dataUsingEncoding:NSUTF8StringEncoding];

//    [_outputStream write:data.bytes maxLength:data.length];
    [_asyncSocket writeData:data withTimeout:-1 tag:101];
}

#pragma mark 数据成功发送到服务器
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    NSLog(@"数据成功发送到服务器");
    [_asyncSocket readDataWithTimeout:-1 tag:tag];
}

#pragma mark 服务器有数据返回
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSString *recerveStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (tag != 101) {
        [self reloadData:recerveStr];
    }
    NSLog(@"%@",recerveStr);
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSString *msgStr = [NSString stringWithFormat:@"msg:%@",textField.text];
    NSData *data = [msgStr dataUsingEncoding:NSUTF8StringEncoding];
//    [_outputStream write:data.bytes maxLength:data.length];
    [_asyncSocket writeData:data withTimeout:-1 tag:102];
    
    [self reloadData:msgStr];
    textField.text = nil;
    return YES;
}

- (void)reloadData:(NSString *)text
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.chatMessages addObject:text];
        [self.tableVIew reloadData];
        //数据多应该往上滚
        NSIndexPath *path = [NSIndexPath indexPathForItem:self.chatMessages.count - 1 inSection:0];
        [self.tableVIew scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    });
    
}

#pragma mark - tableView data sourse
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.chatMessages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    cell.textLabel.text = self.chatMessages[indexPath.row];
    
    return cell;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}
@end
