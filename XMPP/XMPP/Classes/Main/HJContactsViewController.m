//
//  HJContactsViewController.m
//  XMPP
//
//  Created by HJ on 15/3/29.
//  Copyright (c) 2015年 HJ. All rights reserved.
//

#import "HJContactsViewController.h"
#import "HJChatViewController.h"

@interface HJContactsViewController ()<NSFetchedResultsControllerDelegate>
{
    NSFetchedResultsController *_resultsController;
}
@property (nonatomic, strong) NSArray *friends;

@end

@implementation HJContactsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self loadFriends];
    
}

- (void)loadFriends
{
    //1.上下文关联数据库
    NSManagedObjectContext *context = [HJXMPPTool sharedHJXMPPTool].rosterSrorage.mainThreadManagedObjectContext;
    //2.创建FetchRequest请求
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"XMPPUserCoreDataStorageObject"];
    //3.过滤和排序
    //当年登陆用户的好友
    NSString *jid = [HJUserInfo sharedHJUserInfo].jid;
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"streamBareJidStr = %@",jid];
    fetchRequest.predicate = pre;
    //排序
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
    fetchRequest.sortDescriptors = @[sort];
    
    //4.执行请求
    _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    _resultsController.delegate = self;
    
    NSError *err = nil;
    [_resultsController performFetch:&err];
    HJLog(@"%@",err);
}

#pragma mark - resultsController delegate 数据库内容改变会调用
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    HJLog(@"数据发生改变");
    [self.tableView reloadData];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactCell" forIndexPath:indexPath];
    
//    XMPPUserCoreDataStorageObject *friend = self.friends[indexPath.row];
    XMPPUserCoreDataStorageObject *friend = _resultsController.fetchedObjects[indexPath.row];
    cell.textLabel.text = friend.jidStr;
    switch (friend.section ) {
        case 0:
            cell.detailTextLabel.text = @"在线";
            break;
        case 1:
            cell.detailTextLabel.text = @"离开";
            break;
        case 2:
            cell.detailTextLabel.text = @"离线";
            break;
        default:
            break;
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _resultsController.fetchedObjects.count;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        XMPPUserCoreDataStorageObject *friend = _resultsController.fetchedObjects[indexPath.row];
        XMPPJID *jid = friend.jid;
        [[HJXMPPTool sharedHJXMPPTool].roster removeUser:jid];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    XMPPUserCoreDataStorageObject *friend = _resultsController.fetchedObjects[indexPath.row];
    [self performSegueWithIdentifier:@"ChatSegue" sender:friend.jid];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[HJChatViewController class]]) {
        HJChatViewController *chatVc = segue.destinationViewController;
        chatVc.friendJid = sender;
    }
}
@end
