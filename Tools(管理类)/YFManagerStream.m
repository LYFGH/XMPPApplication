//
//  YFManagerStream.m
//  XMPPTest2
//
//  Created by 李亚飞 on 2019/9/5.
//  Copyright © 2019 xxxx. All rights reserved.
//

#import "YFManagerStream.h"


//导入打印日志
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "XMPPLogging.h"



@interface YFManagerStream () <XMPPStreamDelegate>

@end

@implementation YFManagerStream

static YFManagerStream * share;

+(instancetype)shareManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        share = [YFManagerStream new];
        
        //设置打印日志,打印的是发送与接收的日志信息
        [DDLog addLogger:[DDTTYLogger sharedInstance] withLogLevel:XMPP_LOG_FLAG_SEND_RECV];
    });
    return share;
}
#pragma mark -----功能模块----
#pragma mark -----懒加载Stream对象----
- (XMPPStream *)xmppStream
{
    if (!_xmppStream) {
        //创建对象
        _xmppStream = [[XMPPStream alloc] init];
        //设置属性
        _xmppStream.hostName = @"127.0.0.1";
        _xmppStream.hostPort = 5222;
        //设置代理,是多播代理,
        [_xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        //连接到服务器
        [_xmppStream connectWithTimeout: XMPPStreamTimeoutNone error: nil];
        
        
    }
    return  _xmppStream;
}
#pragma mark -----懒加载自动重连对象----
- (XMPPReconnect *)xmppReconnect
{
    if (!_xmppReconnect) {
        //创建对象
        _xmppReconnect = [[XMPPReconnect alloc]initWithDispatchQueue:dispatch_get_main_queue()];
        //设置参数
        _xmppReconnect.reconnectTimerInterval = 2;
        
        //设置代理
        
    }
    return _xmppReconnect;
}
#pragma mark -----懒加载心跳检测对象----
-(XMPPAutoPing *)xmppAutoPing
{
    if (!_xmppAutoPing) {
        //创建对象
        _xmppAutoPing = [[XMPPAutoPing alloc]initWithDispatchQueue:dispatch_get_main_queue()];
        //设置参数
        _xmppAutoPing.pingInterval = 3;
        
        
    }
    return _xmppAutoPing;
}
#pragma mark -----懒加载好友功能对象----
- (XMPPRoster *)xmppRoster
{
    if (!_xmppRoster) {
        _xmppRoster = [[XMPPRoster alloc]initWithRosterStorage:[XMPPRosterCoreDataStorage sharedInstance] dispatchQueue:dispatch_get_global_queue(0, 0)];
        
        //设置参数
        //是否自动查找新的好友数据
        _xmppRoster.autoFetchRoster = YES;
        //是否自动删除用户存储的数据,不需要
        _xmppRoster.autoClearAllUsersAndResources = NO;
        //如果自动接收XMPP 会帮我们做一个加好友的操作,代理方法也不会被调用
        //不需要自动加好友
        _xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = NO;
    
        //设置代理
        [_xmppRoster addDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
    
    
    }
    return _xmppRoster;
}

- (XMPPMessageArchiving *)xmppMessageArchiving
{
    if (!_xmppMessageArchiving) {
        //创建实体
        _xmppMessageArchiving = [[XMPPMessageArchiving alloc]initWithMessageArchivingStorage:[XMPPMessageArchivingCoreDataStorage sharedInstance] dispatchQueue:dispatch_get_main_queue()];
        //设置参数和代理
        
    }
    return _xmppMessageArchiving;
}

- (XMPPvCardTempModule *)xmppvCardTempModule
{
    if (!_xmppvCardTempModule) {
        //创建对象
        _xmppvCardTempModule = [[XMPPvCardTempModule alloc]initWithvCardStorage:[XMPPvCardCoreDataStorage sharedInstance] dispatchQueue:dispatch_get_main_queue()];
        
        //设置参数
        
        
        //设置代理,需要在其他界面更新代理
        
        
    }
    return _xmppvCardTempModule;
}

- (XMPPvCardAvatarModule *)xmppvCardAvatarModule
{
    if (!_xmppvCardAvatarModule) {
        _xmppvCardAvatarModule = [[XMPPvCardAvatarModule alloc]initWithvCardTempModule:_xmppvCardTempModule dispatchQueue:dispatch_get_main_queue()];
    }
    return _xmppvCardAvatarModule;
}


#pragma mark -----登录方法----
-(void)loginToServer:(XMPPJID *)myJid andPassWord:(NSString *)password
{
    //设置myJID
    [self.xmppStream setMyJID:myJid];
    _password = password;
    //连接
    [_xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:nil];
    
    //激活所有的功能模块
    [self xmppActivity];
    
    
}

#pragma mark -----XMPP激活----
-(void)xmppActivity
{
    //1,自动重连激活
    [self.xmppReconnect activate:_xmppStream];
    //2,心跳检测激活
    [self.xmppAutoPing activate:_xmppStream];
    //3,好友列表激活
    [self.xmppRoster activate:_xmppStream];
    //4,消息模块的激活
    [self.xmppMessageArchiving activate:_xmppStream];
    //5,自己个人资料的激活
    [self.xmppvCardTempModule activate:_xmppStream];
    //6,别人个人资料的激活
    [self.xmppvCardAvatarModule activate:_xmppStream];
}


#pragma mark -----XMPPStream代理⤵️----
/** 通过代理方法,告知是否连接成功 */
-(void)xmppStreamDidConnect:(XMPPStream *)sender
{
    //认证
    [self.xmppStream authenticateWithPassword:_password error:nil];
    //注册匿名登录
//    [self.xmppStream authenticateAnonymously:nil];
//    [self.xmppStream registerWithPassword:nil error:nil];
}

/** 通过代理方法,告知是否认证成功 */
-(void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    //如果成功,则可以出席
    XMPPPresence *persence = [XMPPPresence presence];
    //添加出席状态,脱机状态是因为要把状态告诉服务器
    [persence addChild:[DDXMLElement elementWithName:@"show" xmlns:@"dnd"]];
    [persence addChild:[DDXMLElement elementWithName:@"status" xmlns:@"别来烦我!!"]];
    
    //通过stream告诉服务器需要出席
    [self.xmppStream sendElement:persence];
    
}

/** 通过代理方法, 接收数据*/
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    NSLog(@"接收的消息时候 =  %@",message.body);
    
    UILocalNotification *noti = [[UILocalNotification alloc]init];
//    [noti setAlertTitle:[NSString stringWithFormat:@"来自%@ : %@消息",message.from, message.body]];
    //本地通知
    [noti setAlertBody:[NSString stringWithFormat:@"来自%@ : %@消息",message.from, message.body]];
    
    //设置appicon图标
    [noti setApplicationIconBadgeNumber:1];
    
    //弹出本地通知
    [[UIApplication sharedApplication] presentLocalNotificationNow:noti];
}
#pragma mark -----XMPPStream代理⬆️----






@end
