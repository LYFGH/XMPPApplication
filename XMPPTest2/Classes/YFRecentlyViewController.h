//
//  YFRecentlyViewController.h
//  XMPPTest2
//
//  Created by 李亚飞 on 2019/9/9.
//  Copyright © 2019 xxxx. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YFRecentlyViewController : UITableViewController

//接收目标的jid
@property(nonatomic, strong)XMPPJID *userJid;

@end

NS_ASSUME_NONNULL_END
