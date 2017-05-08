//
//  XXGJAddMessageViewController.m
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/4/12.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJAddMessageViewController.h"

@interface XXGJAddMessageViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *messageTextFiled;

@end

@implementation XXGJAddMessageViewController

+ (instancetype)addMessageViewController
{
    return [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil].firstObject;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    /** 设置导航栏样式*/
    [self setNavigationBarTitle:@"添加为好友"];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStyleDone target:self action:@selector(sendAndAddNewFriend:)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - setter and getter
- (void)setNFriend:(User *)nFriend
{
    _nFriend = nFriend;
    [self.messageTextFiled setText:[NSString stringWithFormat:@"我是%@",self.appDelegate.user.nick_name]];
}

#pragma mark - private method
- (void)sendAndAddNewFriend:(UIBarButtonItem *)rightButtonItem
{
    NSDictionary *dict = @{XXGJ_N_PARAM_USERID:self.appDelegate.user.user_id, XXGJ_N_PARAM_TARGETID:self.nFriend.user_id, XXGJ_N_PARAM_REMARK:self.messageTextFiled.text};
    [XXGJNetKit addFriend:dict rBlock:^(id obj, BOOL success, NSError *error) {
        NSLog(@".. %@", obj);
        if (obj && [obj[@"statusText"] isEqualToString:@"ok"]) {
            [MBProgressHUD showLoadHUDCustomImage:successHUDName title:@"已发送"];
            /** 返回上一层*/
            [self backMethod:nil];
        }
        else
        {
            [MBProgressHUD showLoadHUDText:@"添加好友命令发送失败, 请检查当前网络状态" during:0.25];
        }
        
    }];
}
- (IBAction)clearMessageAction:(id)sender
{
    [self.messageTextFiled setText:@""];
}

- (IBAction)resignFirstResponderAction:(id)sender
{
    [self.messageTextFiled resignFirstResponder];
}


#pragma mark - delegate
#pragma mark - text field delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.messageTextFiled resignFirstResponder];
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
