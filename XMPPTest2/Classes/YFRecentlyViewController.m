//
//  YFRecentlyViewController.m
//  XMPPTest2
//
//  Created by 李亚飞 on 2019/9/9.
//  Copyright © 2019 xxxx. All rights reserved.
//

#import "YFRecentlyViewController.h"
#import "YFChatViewController.h"

@interface YFRecentlyViewController ()<NSFetchedResultsControllerDelegate,XMPPvCardAvatarDelegate>

//查询控制器
@property (nonatomic, strong)NSFetchedResultsController *fetchedResultsController;

//好友聊天数据
@property (nonatomic, strong)NSArray *recentlyArrs;



@end

@implementation YFRecentlyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [NSFetchedResultsController deleteCacheWithName:@"Recently"];
    
    //
    [[YFManagerStream shareManager].xmppvCardAvatarModule addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    
    
    [self.fetchedResultsController performSelector:nil];
    self.recentlyArrs = self.fetchedResultsController.fetchedObjects;
    [self.tableView reloadData];
}

#pragma mark - NSFetchedResultsControllerDelegate
-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    //获取数据
    self.recentlyArrs = self.fetchedResultsController.fetchedObjects;
    //数据刷新
    [self.tableView reloadData];
}








#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.recentlyArrs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //获取数据
    XMPPMessageArchiving_Contact_CoreDataObject * msg = self.recentlyArrs[indexPath.row];
    //创建cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Rrcently_Cell"];
    
    UILabel *nameLabel = [cell viewWithTag:1002];
    UILabel *lastmessage = [cell viewWithTag:1003];
    nameLabel.text  = msg.bareJidStr;
    
    lastmessage.text = msg.mostRecentMessageBody;
    
    UIImageView *icon = [cell viewWithTag:1001];
    icon.image = [UIImage imageWithData:[[YFManagerStream shareManager].xmppvCardAvatarModule photoDataForJID:msg.bareJid]];
    
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0;
}

#pragma 点击跳转
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UITableViewCell *)sender
{
    XMPPMessageArchiving_Contact_CoreDataObject * msg = self.recentlyArrs[[self.tableView indexPathForCell:sender].row];
    YFChatViewController *chatVC = segue.destinationViewController;
    chatVC.userJid = msg.bareJid;
}



#pragma 头像更新
- (void)xmppvCardAvatarModule:(XMPPvCardAvatarModule *)vCardTempModule didReceivePhoto:(UIImage *)photo forJID:(XMPPJID *)jid
{
    [self.tableView reloadData];
}


#pragma 懒加载

- (NSArray *)recentlyArrs
{
    if (!_recentlyArrs) {
        _recentlyArrs = [NSArray array];
    }
    return _recentlyArrs;
}


- (NSFetchedResultsController *)fetchedResultsController
{
    if (!_fetchedResultsController) {
        //创建一个查询请求
        NSFetchRequest *fetRequest = [[NSFetchRequest alloc]init];
        //实体
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Contact_CoreDataObject" inManagedObjectContext:[XMPPMessageArchivingCoreDataStorage sharedInstance].mainThreadManagedObjectContext];
        [fetRequest setEntity:entity];
        //谓词
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bareJidStr = %@", self.userJid.bare];
//        [fetRequest setPredicate:predicate];
        //排序,根据时间戳排序,降序排列
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"mostRecentMessageTimestamp" ascending: NO];
        fetRequest.sortDescriptors = @[sort];
        //创建对象
        _fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetRequest managedObjectContext:[XMPPMessageArchivingCoreDataStorage sharedInstance].mainThreadManagedObjectContext sectionNameKeyPath:nil cacheName:@"Recently"];
        //设置代理
        _fetchedResultsController.delegate = self;
    }
    return _fetchedResultsController;
}

@end
