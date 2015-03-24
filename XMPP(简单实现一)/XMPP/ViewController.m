//
//  ViewController.m
//  XMPP
//
//  Created by HJ on 15/3/24.
//  Copyright (c) 2015年 HJ. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<NSStreamDelegate,UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong)NSInputStream *inputStream;
@property (nonatomic, strong)NSOutputStream *outputStream;
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

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
//    NSLog(@"%@",[NSThread currentThread]);
    switch (eventCode) {
        case NSStreamEventOpenCompleted:
            NSLog(@"stream事件打开完成");
            break;
        case NSStreamEventHasBytesAvailable:
            [self readData];
            break;
        case NSStreamEventHasSpaceAvailable:
            NSLog(@"可以发送字节");
            break;
        case NSStreamEventErrorOccurred:
            NSLog(@"error");
            break;
        case NSStreamEventEndEncountered:
            NSLog(@"end");
            [_inputStream close];
            [_outputStream close];
            [_inputStream removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
            [_outputStream removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
            break;
        default:
            break;
    }
}

- (void)readData
{
    uint8_t buf[1024];
    NSInteger len = [_inputStream read:buf maxLength:sizeof(buf)];
    NSData *data = [NSData dataWithBytes:buf length:len];
    NSString *recerveStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    [self reloadData:recerveStr];
    
    NSLog(@"%@",recerveStr);
}

- (IBAction)connentToHost:(UIBarButtonItem *)sender
{
    NSString *host = @"10.82.197.21";
    int port = 12345;
    
    CFReadStreamRef redStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)host, port, &redStream, &writeStream);
    
    _inputStream = (__bridge NSInputStream *)(redStream);
    _outputStream = (__bridge NSOutputStream *)(writeStream);
    
    _inputStream.delegate = self;
    _outputStream.delegate = self;
    
    [_inputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [_outputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    
    [_inputStream open];
    [_outputStream open];
}

- (IBAction)loginBtnClick:(UIBarButtonItem *)sender
{
    //登陆发送数据格式为“iam:username”
    //发送消息数据格式为“msg：message”
    NSString *loginStr = @"iam:HJ";
    NSData *data = [loginStr dataUsingEncoding:NSUTF8StringEncoding];

    [_outputStream write:data.bytes maxLength:data.length];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSString *msgStr = [NSString stringWithFormat:@"msg:%@",textField.text];
    NSData *data = [msgStr dataUsingEncoding:NSUTF8StringEncoding];
    [_outputStream write:data.bytes maxLength:data.length];
    
    [self reloadData:msgStr];
    textField.text = nil;
    return YES;
}

- (void)reloadData:(NSString *)text
{
    [self.chatMessages addObject:text];
    [self.tableVIew reloadData];
    //数据多应该晚上滚
    NSIndexPath *path = [NSIndexPath indexPathForItem:self.chatMessages.count - 1 inSection:0];
    [self.tableVIew scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

#pragma mark tabke data sourse
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
