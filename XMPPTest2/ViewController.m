//
//  ViewController.m
//  XMPPTest2
//
//  Created by 李亚飞 on 2019/9/5.
//  Copyright © 2019 xxxx. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    XMPPJID *jid = [XMPPJID jidWithUser:@"lisi" domain:@"域名" resource:nil];
    [[YFManagerStream shareManager] loginToServer:jid andPassWord:@"123"];
    
}


@end
