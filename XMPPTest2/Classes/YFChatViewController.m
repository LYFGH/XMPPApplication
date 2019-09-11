//
//  YFChatViewController.m
//  XMPPTest2
//
//  Created by 李亚飞 on 2019/9/6.
//  Copyright © 2019 xxxx. All rights reserved.
//

#import "YFChatViewController.h"

@interface YFChatViewController ()<NSFetchedResultsControllerDelegate,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,XMPPvCardAvatarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *chatTableView;
@property (weak, nonatomic) IBOutlet UIView *messageView;
@property (weak, nonatomic) IBOutlet UITextField *messageTF;



//查询控制器
@property (nonatomic, strong)NSFetchedResultsController *fetchedResultsController;

//好友聊天数据
@property (nonatomic, strong)NSArray *chatArrs;


@end

@implementation YFChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置代理
    [[YFManagerStream shareManager].xmppvCardAvatarModule addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    
    [NSFetchedResultsController deleteCacheWithName:@"messages"];
    //执行查询操作
    [self.fetchedResultsController performFetch:nil];
    
    //获取数据
    self.chatArrs = self.fetchedResultsController.fetchedObjects;
    [self.chatTableView reloadData];
    if (_chatArrs.count > 5) {
        NSIndexPath *indexpath = [NSIndexPath indexPathForRow:self.chatArrs.count - 1 inSection:0];
        [self.chatTableView scrollToRowAtIndexPath:indexpath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        
    }
    
    _messageTF.delegate = self;
    
}

#pragma fetchedResultsControllerDelegate
-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    
    //排序
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
    self.chatArrs = [self.fetchedResultsController.fetchedObjects sortedArrayUsingDescriptors:@[sort]];
    
    [self.chatTableView reloadData];
    
    if (_chatArrs.count > 5) {
        NSIndexPath *indexpath = [NSIndexPath indexPathForRow:self.chatArrs.count - 1 inSection:0];
        [self.chatTableView scrollToRowAtIndexPath:indexpath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        
    }
    
    
    
}
#pragma fetchedResultsControllerDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _chatArrs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //获取数据
    XMPPMessageArchiving_Message_CoreDataObject *msg = self.chatArrs[indexPath.row];
    //创建cell
    UITableView *cell = [tableView dequeueReusableCellWithIdentifier:msg.isOutgoing? @"Right_Cell": @"Left_Cell"];
    //给cell赋值
    UILabel *name =  [cell viewWithTag:1002];
    name.text = msg.body;
    
    //头像设置
    UIImageView *icon = [cell viewWithTag:1001];
    
    if (msg.isOutgoing){
       icon.image = [UIImage imageWithData:[YFManagerStream shareManager].xmppvCardTempModule.myvCardTemp.photo];
    }else{
       icon.image = [UIImage imageWithData:[[YFManagerStream shareManager].xmppvCardAvatarModule photoDataForJID:msg.bareJid]];
    }
    
    return cell;
}


- (IBAction)sentMessageClick:(UIButton *)sender {
    
    
    
}



-(void)xmppvCardAvatarModule:(XMPPvCardAvatarModule *)vCardTempModule didReceivePhoto:(UIImage *)photo forJID:(XMPPJID *)jid
{
    
}


-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

#pragma 发消息
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //发消息
    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:_userJid];
    [message addBody:self.messageTF.text];
    [[YFManagerStream shareManager].xmppStream sendElement:message
      ];
    self.messageTF.text = @"";
    
    return YES;
}


#pragma 懒加载

- (NSArray *)chatArrs
{
    if (!_chatArrs) {
        _chatArrs = [NSArray array];
    }
    return _chatArrs;
}


- (NSFetchedResultsController *)fetchedResultsController
{
    if (!_fetchedResultsController) {
        //创建一个查询请求
        NSFetchRequest *fetRequest = [[NSFetchRequest alloc]init];
        //实体
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Message_CoreDataObject" inManagedObjectContext:[XMPPMessageArchivingCoreDataStorage sharedInstance].mainThreadManagedObjectContext];
        [fetRequest setEntity:entity];
        //谓词
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bareJidStr = %@", self.userJid.bare];
        [fetRequest setPredicate:predicate];
        //排序
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
        fetRequest.sortDescriptors = @[sort];
        //创建对象
        _fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetRequest managedObjectContext:[XMPPMessageArchivingCoreDataStorage sharedInstance].mainThreadManagedObjectContext sectionNameKeyPath:nil cacheName:@"messages"];
        //设置代理
        _fetchedResultsController.delegate = self;
    }
    return _fetchedResultsController;
}

@end
