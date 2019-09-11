//
//  YFContactTableViewController.m
//  XMPPTest2
//
//  Created by 李亚飞 on 2019/9/6.
//  Copyright © 2019 xxxx. All rights reserved.
//

#import "YFContactTableViewController.h"

@interface YFContactTableViewController ()<NSFetchedResultsControllerDelegate,XMPPRosterDelegate>

//查询控制器
@property (nonatomic, strong)NSFetchedResultsController *fetchedResultsController;

//好友列表数组
@property (nonatomic, strong)NSArray *contactArrs;

@end

@implementation YFContactTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [NSFetchedResultsController deleteCacheWithName:@"contacts"];
    //好友代理设置
    [[YFManagerStream shareManager].xmppRoster addDelegate:self
                                             delegateQueue:  dispatch_get_global_queue(0, 0)];
    
    
    
    
    //执行查询操作
    [self.fetchedResultsController performFetch:nil];
    
    //获取数据
    self.contactArrs = self.fetchedResultsController.fetchedObjects;
    [self.tableView reloadData];
    
    
    
    
    
    
    
    
}


- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence
{
    //同意加对方为好友
    [[YFManagerStream shareManager].xmppRoster acceptPresenceSubscriptionRequestFrom:[XMPPJID jidWithUser:@"wangwu" domain:@"127.0.0.1" resource:@"wangwuios"] andAddToRoster:YES];
    
    
    
}





#pragma NSFetchedResultsControllerDelegate
//当CoreData数据发生变化会调用该代理
-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    //获取数据
    self.contactArrs = controller.fetchedObjects;
    //刷新数据
    [self.tableView reloadData];
}

#pragma NSFetchedResultsControllerDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _contactArrs.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //获取数据
    XMPPUserCoreDataStorageObject *contact = self.contactArrs[indexPath.row];
    //创建cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactCell"];
    //给cell赋值
    UILabel *name =  [cell viewWithTag:1002];
    name.text = contact.jidStr;
    
    UIImageView *icon = [cell viewWithTag:1001];
    icon.image = [UIImage imageWithData:[[YFManagerStream shareManager].xmppvCardAvatarModule photoDataForJID:contact.jid]];
//    UILabel *name =  [cell viewWithTag:1002];
//
//    UILabel *name =  [cell viewWithTag:1003];
//
//    UILabel *name =  [cell viewWithTag:1004];
    
    return cell;
    
}




- (IBAction)addFrientd:(id)sender {
    [[YFManagerStream shareManager].xmppRoster addUser:[XMPPJID jidWithUser:@"wangwu" domain:@"127.0.0.1" resource:@"wangwuiOS"] withNickname:@"加好友加好友"];
    [self.tableView reloadData];
}


#pragma 好友删除
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        XMPPUserCoreDataStorageObject *contact = self.contactArrs[indexPath.row];
        [[YFManagerStream shareManager].xmppRoster removeUser:contact.jid];
    }
    
    
}

#pragma 懒加载

- (NSArray *)contactArrs
{
    if (!_contactArrs) {
        _contactArrs = [NSArray array];
    }
    return _contactArrs;
}



- (NSFetchedResultsController *)fetchedResultsController
{
    if (!_fetchedResultsController) {
        //创建一个查询请求
        NSFetchRequest *fetRequest = [[NSFetchRequest alloc]init];
        //实体
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPUserCoreDataStorageObject" inManagedObjectContext:[XMPPRosterCoreDataStorage sharedInstance].mainThreadManagedObjectContext];
        [fetRequest setEntity:entity];
        //谓词,根据条件查找
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"subscription = %@", @"both"];
        [fetRequest setPredicate:predicate];
        //排序
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"jidStr" ascending:YES];
        fetRequest.sortDescriptors = @[sort];
        //创建对象
        _fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetRequest managedObjectContext:[XMPPRosterCoreDataStorage sharedInstance].mainThreadManagedObjectContext sectionNameKeyPath:nil cacheName:@"contacts"];
        //设置代理
        _fetchedResultsController.delegate = self;
    }
    return _fetchedResultsController;
}


@end
