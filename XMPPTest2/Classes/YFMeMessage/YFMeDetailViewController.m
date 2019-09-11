//
//  YFMeDetailViewController.m
//  XMPPTest2
//
//  Created by 李亚飞 on 2019/9/9.
//  Copyright © 2019 xxxx. All rights reserved.
//

#import "YFMeDetailViewController.h"

@interface YFMeDetailViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,XMPPvCardTempModuleDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UILabel *nickName;
@property (weak, nonatomic) IBOutlet UILabel *qianMing;

@property(nonatomic, strong)XMPPvCardTemp *myvCardTemp;
@end

@implementation YFMeDetailViewController

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
    
    [self update];
}

-(void)update
{
    //头像
    self.icon.image = [UIImage imageWithData:self.myvCardTemp.photo];
    
    //名字
//    self.nameLabel.text = [YFManagerStream shareManager].xmppStream.myJID.bare;
    
    //昵称
    self.nickName.text = self.myvCardTemp.nickname;
    
    //个性签名
    self.qianMing.text = self.myvCardTemp.desc;
    
    
}


#pragma 跳转控制器
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"desc"]) {
        segue.destinationViewController.title = @"个性签名";
    }else{
        segue.destinationViewController.title = @"昵称";
    }
}




-(void)changeUserImage
{
    //相册
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    picker.allowsEditing = YES;
    picker.delegate = self;
    [self.navigationController presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info
{
    //获取头像
    NSLog(@"info == %@",info);
    
    //获取图片
    UIImage *image = info[UIImagePickerControllerEditedImage];
    NSData *imagedata = UIImageJPEGRepresentation(image, 0.2);
    
    self.myvCardTemp.photo = imagedata;
    [[YFManagerStream shareManager].xmppvCardTempModule updateMyvCardTemp:self.myvCardTemp];
    [self.navigationController dismissViewControllerAnimated:picker completion:nil];
    
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
