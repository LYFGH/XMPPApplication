//
//  YFManagerStream.h
//  XMPPTest2
//
//  Created by 李亚飞 on 2019/9/5.
//  Copyright © 2019 xxxx. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YFManagerStream : NSObject

//创建一个Stream 流
@property (nonatomic, strong)XMPPStream *xmppStream;


+ (instancetype)shareManager;

//密码
@property (nonatomic,copy)NSString *password;

//自动重连对象
@property (nonatomic, strong)  XMPPReconnect * xmppReconnect;

//心跳检测
@property (nonatomic, strong)  XMPPAutoPing *xmppAutoPing;


//创建好友列表功能模块
@property (nonatomic, strong) XMPPRoster *xmppRoster;


//消息功能模块
@property (nonatomic, strong) XMPPMessageArchiving *xmppMessageArchiving;


//自己个人资料功能模块
@property (nonatomic, strong)XMPPvCardTempModule * xmppvCardTempModule;


//别人个人资料功能模块
@property (nonatomic, strong)XMPPvCardAvatarModule *xmppvCardAvatarModule;





//连接到服务器
-(void)loginToServer:(XMPPJID *)myJid andPassWord:(NSString *)password;


@end

NS_ASSUME_NONNULL_END
