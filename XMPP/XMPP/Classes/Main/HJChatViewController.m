//
//  HJChatViewController.m
//  XMPP
//
//  Created by HJ on 15/3/29.
//  Copyright (c) 2015年 HJ. All rights reserved.
//

#import "HJChatViewController.h"
#import "HJInputView.h"
#import "HttpTool.h"
#import "UIImageView+WebCache.h"

@interface HJChatViewController ()<UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate,UITextViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    NSFetchedResultsController *_resultController;
}
@property(nonatomic, strong)NSLayoutConstraint *inputViewBottomConstraint;
@property(nonatomic, strong)NSLayoutConstraint *inputViewHeightConstraint;
@property(nonatomic, weak) UITableView *tableView;
@property(nonatomic, strong) HttpTool *httpTool;
@end

@implementation HJChatViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupView];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kbFrmWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self lodMsgs];
}

- (HttpTool *)httpTool
{
    if (!_httpTool) {
        _httpTool = [[HttpTool alloc] init];
    }
    return _httpTool;
}

//- (void)kbFrmWillChange:(NSNotification *)noti
//{
//    NSLog(@"%@",noti);
//    //获取窗口高度
//    CGFloat windowsH = [UIScreen mainScreen].bounds.size.height;
//    //键盘结束的y
//    CGRect kbEnfFrm = [noti.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
//    
//    self.inputViewBottomConstraint.constant = windowsH - kbEnfFrm.origin.y;
//    
//}

- (void)keyboardWillShow:(NSNotification *)noti
{//获取键盘的高度
    CGRect kbEndFrm = [noti.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat kbHeight = kbEndFrm.size.height;
    
    if ([[UIDevice currentDevice].systemVersion doubleValue] < 8.0 && UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        kbHeight = kbEndFrm.size.width;
    }
    
    self.inputViewBottomConstraint.constant = kbHeight;
    
    [self scrollToTableViewBotton];
}
- (void)keyboardWillHide:(NSNotification *)noti
{//隐藏离底部约束为0
    self.inputViewBottomConstraint.constant = 0;
}

- (void)setupView
{
    UITableView *tableView = [[UITableView alloc] init];
#warning 代码实现自动布局，要设置下面为NO
    tableView.translatesAutoresizingMaskIntoConstraints = NO;
    tableView.delegate = self;
    tableView.dataSource = self;
    self.tableView = tableView;
    [self.view addSubview:tableView];
    
    HJInputView *inputView = [HJInputView inputView];
    inputView.translatesAutoresizingMaskIntoConstraints = NO;
    inputView.textView.delegate = self;
    
    //添加按钮事件
    [inputView.addBtn addTarget:self action:@selector(addBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:inputView];
    
    //自动布局 VFL
    NSDictionary *views = @{@"tableView":tableView, @"inputView":inputView};
    
    NSArray *tableHConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[tableView]-0-|" options:0 metrics:nil views:views];
    [self.view addConstraints:tableHConstraints];
    
    NSArray *inputHConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[inputView]-0-|" options:0 metrics:nil views:views];
    [self.view addConstraints:inputHConstraints];
    
    NSArray *vConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[tableView]-0-[inputView(50)]-0-|" options:0 metrics:nil views:views];
    [self.view addConstraints:vConstraints];
    
    self.inputViewBottomConstraint = [vConstraints lastObject];
    
    //inputView的高度约束
    self.inputViewHeightConstraint = vConstraints[2];
}

#pragma mark 加载数据库显示在表格里
- (void)lodMsgs
{
    NSManagedObjectContext *context = [HJXMPPTool sharedHJXMPPTool].messageCoreDataStorage.mainThreadManagedObjectContext;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPMessageArchiving_Message_CoreDataObject"];
    
    //当前登陆用户jid   好友jid
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"streamBareJidStr = %@ AND bareJidStr = %@", [HJUserInfo sharedHJUserInfo].jid, self.friendJid.bare];

    request.predicate = pre;
    
    //排序
    NSSortDescriptor *timeSort = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
    request.sortDescriptors = @[timeSort];
    
    _resultController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    NSError *err;
    [_resultController performFetch:&err];
    _resultController.delegate = self;
    if (err) {
        HJLog(@"%@",err);
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _resultController.fetchedObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"ChatCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }

    XMPPMessageArchiving_Message_CoreDataObject *msg = _resultController.fetchedObjects[indexPath.row];
    
    NSString *chattye = [msg.message attributeStringValueForName:@"chatType"];
    if ([chattye isEqualToString:@"image"])
    {
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:msg.body] placeholderImage:[UIImage imageNamed:@"DefaultProfileHead_qq"]];
        cell.textLabel.text = nil;
    }else {//if ([chattye isEqualToString:@"text"]){
        
        if ([msg.outgoing boolValue]) {//自己发的
            cell.textLabel.text = [NSString stringWithFormat:@"me:%@",msg.body];
        }else{//没收到的
            cell.textLabel.text = [NSString stringWithFormat:@"%@:%@", self.friendJid.user, msg.body];
        }
        cell.imageView.image = nil;
    }
    
    return cell;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView reloadData];
    [self scrollToTableViewBotton];
}
#pragma mark - textView delegate
- (void)textViewDidChange:(UITextView *)textView
{
    CGFloat contentH = textView.contentSize.height;
//    NSLog(@"%f",size.height);
    if (contentH > 33 && contentH < 67) {
        self.inputViewHeightConstraint.constant = contentH + 18;
    }
    NSString *text = textView.text;
    if([text rangeOfString:@"\n"].length != 0){
        //去除换行字符
        text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [self shendMessage:text bodyType:@"text"];
        textView.text = nil;
        self.inputViewHeightConstraint.constant = 50;
    }
}

- (void)shendMessage:(NSString *)text bodyType:(NSString *)bodyType
{
    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:self.friendJid];
    
    [message addAttributeWithName:@"chatType" stringValue:bodyType];
    
    
    [message addBody:text];
    [[HJXMPPTool sharedHJXMPPTool].XMPPStream sendElement:message];
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}
#pragma mark - 滚动到底部
- (void)scrollToTableViewBotton
{
    NSInteger lastRow = _resultController.fetchedObjects.count - 1;
    if (lastRow < 0) {
        return;
    }
    NSIndexPath *path = [NSIndexPath indexPathForRow:lastRow inSection:0];
    [self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}
#pragma mark - 选择图片
- (void)addBtnClick
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    //1.文件名
    NSString *user = [HJUserInfo sharedHJUserInfo].user;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *timeStr = [dateFormatter stringFromDate:[NSDate date]];
    NSString *fileName = [NSString stringWithFormat:@"%@%@", user, timeStr];
    //2.url
    NSString *uploadUrl = [@"http://10.82.197.21:8080/imfileserver/Upload/Image/" stringByAppendingString:fileName];
    //3.http put
#warning 图片上传请使用jpg格式
    [self.httpTool uploadData:UIImageJPEGRepresentation(image, 0.75) url:[NSURL URLWithString:uploadUrl] progressBlock:nil completion:^(NSError *error) {
        
        if (!error) {
            HJLog(@"图片上传成功");
            [self shendMessage:uploadUrl bodyType:@"image"];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

@end
