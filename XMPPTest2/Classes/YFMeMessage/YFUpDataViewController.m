//
//  YFUpDataViewController.m
//  XMPPTest2
//
//  Created by 李亚飞 on 2019/9/9.
//  Copyright © 2019 xxxx. All rights reserved.
//

#import "YFUpDataViewController.h"

@interface YFUpDataViewController ()
@property (weak, nonatomic) IBOutlet UITextField *updateTF;

@property(nonatomic, strong)XMPPvCardTemp *myvCardTemp;

@end

@implementation YFUpDataViewController
- (XMPPvCardTemp *)myvCardTemp
{
    if (!_myvCardTemp) {
        _myvCardTemp = [YFManagerStream shareManager].xmppvCardTempModule.myvCardTemp;
    }
    return _myvCardTemp;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}

-(void)updataMessage
{
    if ([self.title isEqualToString:@"个性签名"]) {
        self.myvCardTemp.desc = self.updateTF.text;
    }else{
        self.myvCardTemp.nickname = self.updateTF.text;
    }
    
    [[YFManagerStream shareManager].xmppvCardTempModule updateMyvCardTemp:self.myvCardTemp];
    [self.navigationController popViewControllerAnimated:YES];
}


@end
