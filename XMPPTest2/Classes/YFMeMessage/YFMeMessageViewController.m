//
//  YFMeMessageViewController.m
//  XMPPTest2
//
//  Created by 李亚飞 on 2019/9/9.
//  Copyright © 2019 xxxx. All rights reserved.
//

#import "YFMeMessageViewController.h"

@interface YFMeMessageViewController ()<XMPPvCardTempModuleDelegate>
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *qianMingLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *icon;

@property(nonatomic, strong)XMPPvCardTemp *myvCardTemp;
@end

@implementation YFMeMessageViewController

- (XMPPvCardTemp *)myvCardTemp
{
    if (!_myvCardTemp) {
        _myvCardTemp = [YFManagerStream shareManager].xmppvCardTempModule.myvCardTemp;
    }
    return _myvCardTemp;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    [[YFManagerStream shareManager].xmppvCardTempModule addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    //设置参数
    [self update];
}
-(void)update
{
    //头像
    self.icon.image = [UIImage imageWithData:self.myvCardTemp.photo];
    
    //名字
    self.nameLabel.text = [YFManagerStream shareManager].xmppStream.myJID.bare;
    
    //昵称
    self.nickNameLabel.text = self.myvCardTemp.nickname;
    
    //个性签名
    self.qianMingLabel.text = self.myvCardTemp.desc;
    
    
}


- (void)xmppvCardTempModuleDidUpdateMyvCard:(XMPPvCardTempModule *)vCardTempModule
{
    //数据重新刷新
    //1,清除之前的内存存储
    self.myvCardTemp = nil;
    //2,赋值
    [self update];
}



@end
