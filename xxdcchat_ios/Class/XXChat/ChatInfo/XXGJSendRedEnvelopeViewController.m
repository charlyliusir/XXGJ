//
//  XXGJSendRedEnvelopeViewController.m
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/4/18.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJSendRedEnvelopeViewController.h"
#import "XXGJAlertView.h"
#import "XXGJMessage.h"

@interface XXGJSendRedEnvelopeViewController () <UITextFieldDelegate, UITextViewDelegate, XXGJAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *moneyTextFiled;
@property (weak, nonatomic) IBOutlet UITextField *numberTextFiled;
@property (weak, nonatomic) IBOutlet UILabel *groupMemberNumberLabel;
@property (weak, nonatomic) IBOutlet UITextView *redEnvelopeTextView;
@property (weak, nonatomic) IBOutlet UILabel *moneyLabel;
@property (weak, nonatomic) IBOutlet UIButton *sendRedEnvelopeBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *RedEnvelopeLayoutConstraintTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *redEnvelopeLayoutConstraintBottom;

@end

@implementation XXGJSendRedEnvelopeViewController

+ (instancetype)sendRedEnvelopeViewControllerWithMethod:(SendRedEnvelopeMethod)method
{
    XXGJSendRedEnvelopeViewController *sendRedEnvelope = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil].firstObject;
    sendRedEnvelope.method = method;
    return sendRedEnvelope;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavigationBarTitle:@"发红包"];
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setFrame:CGRectMake(0, 0, 22, 22)];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"red_envelope_icon_open_close"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(backMethod:) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFiledChange:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - lazy method

#pragma mark - setter and getter
- (void)setMethod:(SendRedEnvelopeMethod)method
{
    _method = method;
    if (_method == SendRedEnvelopeMethodFriend)
    {
        self.redEnvelopeLayoutConstraintBottom.priority = UILayoutPriorityDefaultLow;
        self.RedEnvelopeLayoutConstraintTop.priority = UILayoutPriorityDefaultHigh;
    }
}

#pragma mark - private method
- (void)backMethod:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)sendRedEnvelope:(id)sender
{
    [self.moneyTextFiled resignFirstResponder];
    [self.numberTextFiled resignFirstResponder];
    [self.redEnvelopeTextView resignFirstResponder];
    // 判断发送金额是否不够分配
    if (self.method == SendRedEnvelopeMethodGroup && ([self.moneyTextFiled.text floatValue]*100 < [self.numberTextFiled.text intValue]))
    {
        //提示发送金额不够人数分配
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"单个红包金额不可低于0.01元，请重新填写金额！" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    
    XXGJAlertView *alertView = [XXGJAlertView alertViewContent:@"是否发送该红包" withDelegate:self withObject:nil];
    [alertView setContentName:@"取消" alertIndex:AlertViewIndexCancel];
    [alertView setContentName:@"发送" alertIndex:AlertViewIndexConfirm];
    [alertView showInView:self.view];
}
- (IBAction)textFieldResignFirstResponder:(id)sender
{
    [self.moneyTextFiled resignFirstResponder];
    [self.numberTextFiled resignFirstResponder];
    [self.redEnvelopeTextView resignFirstResponder];
    [self changeSendRedEnvelopeState];
}
- (void)changeSendRedEnvelopeState
{
    /** */
    if ([[self.moneyTextFiled text] floatValue] > 0.0 && self.method == SendRedEnvelopeMethodFriend)
    {
        [self.sendRedEnvelopeBtn setEnabled:YES];
    } else if ([[self.moneyTextFiled text] floatValue] > 0.0 && [[self.numberTextFiled text] integerValue] > 0 && self.method == SendRedEnvelopeMethodGroup)
    {
        [self.sendRedEnvelopeBtn setEnabled:YES];
    }else
    {
        [self.sendRedEnvelopeBtn setEnabled:NO];
    }
}

#pragma mark - notify
- (void)textFiledChange:(NSNotification *)notify
{
    UITextField *textField = (UITextField *)notify.object;
    /** */
    if ([textField isEqual:self.moneyTextFiled])
    {
        [self.moneyLabel setText:[NSString stringWithFormat:@"￥%.2f", [textField.text floatValue]]];
    }
    [self changeSendRedEnvelopeState];
}
#pragma mark - delegate
#pragma mark - alert delegate
- (void)alertView:(XXGJAlertView *)alertView clickAtIndex:(AlertViewIndex)index object:(id)obj
{
    if (index == AlertViewIndexConfirm)
    {
        NSString *session_key = self.appDelegate.socketManage.session_key;
        NSMutableDictionary *dict = @{}.mutableCopy;
        if (!session_key)
        {
            [MBProgressHUD showLoadHUDCustomImage:successHUDName title:@"请稍等，正在连接服务器！！！"];
            return;
        }
        [dict setObject:session_key forKey:XXGJ_N_PARAM_RED_SESSIONKEY];
        [dict setObject:self.redEnvelopeTextView.text forKey:XXGJ_N_PARAM_RED_CONTENT];
        [dict setObject:self.appDelegate.user.user_id forKey:XXGJ_N_PARAM_RED_USERID];
        [dict setObject:self.targetId forKey:XXGJ_N_PARAM_RED_TARGETID];
        [dict setObject:@([self.moneyTextFiled.text floatValue]) forKey:XXGJ_N_PARAM_RED_AMOUNT];
        if (self.method==SendRedEnvelopeMethodGroup)
        {
            [dict setObject:@(1) forKey:XXGJ_N_PARAM_RED_ISGROUP];
            [dict setObject:@([self.numberTextFiled.text intValue]) forKey:XXGJ_N_PARAM_RED_NUM];
            [dict setObject:@(1) forKey:XXGJ_N_PARAM_RED_ISRANDOM];
        }else
        {
            [dict setObject:@(0) forKey:XXGJ_N_PARAM_RED_ISGROUP];
            [dict setObject:@(1) forKey:XXGJ_N_PARAM_RED_NUM];
            [dict setObject:@(0) forKey:XXGJ_N_PARAM_RED_ISRANDOM];
        }
        [MBProgressHUD showLoadHUDIndeterminate:@"钱包支付"];
        [XXGJNetKit sendRedEnvelope:dict.copy rBlock:^(id obj, BOOL success, NSError *error) {
            if (success && obj)
            {
                NSDictionary *result = (NSDictionary *)obj;
                if (result && [result[@"statusText"] isEqualToString:@"success"])
                {
                    result = result[@"result"];
                    XXGJMessage *message = [[XXGJMessage alloc] init];
                    [message setArgsObject:result[@"id"] forKey:XXGJ_ARGS_PARAM_REDENVELOPE_ID];
                    message.UserId   = result[@"userId"];
                    message.TargetId = result[@"targetId"];
                    message.MessageType = @(XXGJRedEnvelope);
                    message.Content  = result[@"content"];
                    [MBProgressHUD hiddenHUD];
                    /** 通过通知回传给前一个页面*/
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (self.delegate && [self.delegate respondsToSelector:@selector(sendRedEnvelopeMessage:)])
                        {
                            [self.delegate sendRedEnvelopeMessage:message];
                        }
                        [self dismissViewControllerAnimated:YES completion:nil];
                    });
                } else
                {
                    [MBProgressHUD showLoadHUDCustomImage:successHUDName title:result[@"statusText"]];
                }
            }else
            {
                [MBProgressHUD showLoadHUDText:@"支付失败" during:0.5];
            }
        }];
        
    }
    
    [alertView hidden];
}
#pragma mark - text filed delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark - text view delegate

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
