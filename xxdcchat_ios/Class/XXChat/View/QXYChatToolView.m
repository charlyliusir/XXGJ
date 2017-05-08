//
//  QXYChatToolView.m
//  QXYChatMessageUI
//
//  Created by 刘朝龙 on 2017/3/14.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "QXYChatToolView.h"

@interface QXYChatToolView () <UITextFieldDelegate>
@property (weak, readwrite, nonatomic) IBOutlet UIView *chatRecordContentView;
@property (weak, nonatomic) IBOutlet UITextField *chatTextField;
@property (weak, nonatomic) IBOutlet UILabel *chatRecordLabel;
@property (weak, nonatomic) IBOutlet UIView *otherView;

@end

@implementation QXYChatToolView

+ (instancetype)chatToolView
{
    return [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil] firstObject];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.chatTextField.delegate = self;
    [self.chatRecordContentView setUserInteractionEnabled:NO];
}

#pragma mark - open method
- (void)changeVoiceState:(QXYVoiceState)voiceState
{
    NSString *stateStr = self.chatRecordLabel.text;
    switch (voiceState) {
        case QXYVoiceStateNormal:
        {
            [self.chatRecordContentView setBackgroundColor:XX_RGBCOLOR_WITHOUTA(235, 235, 235)];
            stateStr = @"按住 说话";
        }
            break;
        case QXYVoiceStateSelect:
        {
            [self.chatRecordContentView setBackgroundColor:XX_RGBCOLOR_WITHOUTA(211, 211, 211)];
            stateStr = @"长按 录音";
        }
            break;
        case QXYVoiceStateClose:
        {
            [self.chatRecordContentView setBackgroundColor:XX_RGBCOLOR_WITHOUTA(211, 211, 211)];
            stateStr = @"松开 取消";
        }
            break;
        default:
            break;
    }
    
    self.chatRecordLabel.text = stateStr;
}

- (void)closeChatToolView
{
//    [((UIButton *)[self viewWithTag:101]) setSelected:NO];
    [((UIButton *)[self viewWithTag:102]) setSelected:NO];
    [self.otherView setHidden:YES];
}

#pragma mark - private method
- (void)changeToolBoxState:(QXYChatToolBoxState)toolBoxState
{
    /** 键盘状态*/ /** 更多状态*/
    if (toolBoxState == QXYChatToolBoxStateKeyBoard|| toolBoxState == QXYChatToolBoxStateKeyOther)
    {
        UIButton *btn = ((UIButton *)[self viewWithTag:101]);
        [btn setImage:[UIImage imageNamed:@"chat_ui_btn_voice_normal"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"chat_ui_btn_voice_selected"] forState:UIControlStateHighlighted];
        if (toolBoxState == QXYChatToolBoxStateKeyOther)
        {
            [btn setSelected:NO];
        }
    }
    /** 语音状态*/
    else if (toolBoxState == QXYChatToolBoxStateKeyVoice)
    {
        UIButton *btn = ((UIButton *)[self viewWithTag:101]);
        [btn setImage:[UIImage imageNamed:@"chat_ui_btn_keyboard_normal"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"chat_ui_btn_keyboard_selected"] forState:UIControlStateHighlighted];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatToolView:exchangBoxState:)])
    {
        [self.delegate chatToolView:self exchangBoxState:toolBoxState];
    }
}
/**
 录音UI和聊天UI互相切换

 @param btn 切换按钮
 */
- (IBAction)showVoiceUI:(UIButton *)btn
{
    // 取消操作其他按钮的所有状态
    [((UIButton *)[self viewWithTag:102]) setSelected:NO];
    
    // 这里直接判断按钮点击状态
    // normal 未点击状态，切换到录音UI
    // select 点击状态，切换到聊天UI
    if (!btn.selected)
    {
        [self.chatRecordContentView setHidden:NO];
        [self.chatTextField setEnabled:NO];
    }else
    {
        [self.chatRecordContentView setHidden:YES];
        [self.chatTextField setEnabled:YES];
    }
    if (!btn.selected)
    {
        [self changeToolBoxState:QXYChatToolBoxStateKeyVoice];
        // 如果当前 Other 页面是显示状态，则隐藏显示
        if (self.delegate && [self.delegate respondsToSelector:@selector(chatToolView:openOtherItem:)])
        {
            [self.delegate chatToolView:self openOtherItem:NO];
        }
    }else
    {
        [self changeToolBoxState:QXYChatToolBoxStateKeyBoard];
        [self.chatTextField becomeFirstResponder];
    }
    
    // 更改按钮点击状态
    btn.selected = !btn.selected;

}


/**
 展开和关闭其他控件

 @param btn 切换按钮
 */
- (IBAction)showOtherUI:(UIButton *)btn
{
    // 取消操作录音按钮的所有状态
    [((UIButton *)[self viewWithTag:101]) setSelected:NO];
    [self.chatRecordContentView setHidden:YES];
    [self.chatTextField setEnabled:YES];
    // 根据按钮状态显示其他页面
    // normal 未点击状态，显示其他页面
    // select 点击状态，隐藏其他页面
    if (!btn.selected)
    {
        [self changeToolBoxState:QXYChatToolBoxStateKeyOther];
        [self.otherView setHidden:NO];
    }else
    {
        [self changeToolBoxState:QXYChatToolBoxStateKeyBoard];
        [self.otherView setHidden:YES];
    }
    
    // 如果当前 Other 页面是显示状态，则隐藏显示
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatToolView:openOtherItem:)])
    {
        [self.delegate chatToolView:self openOtherItem:!btn.selected];
    }
    
    // 更改按钮点击状态
    btn.selected = !btn.selected;
        
}


#pragma mark - textfield delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (![textField.text isEqualToString:@""]&&self.delegate && [self.delegate respondsToSelector:@selector(chatToolView:sendMessage:)])
    {
        [self.delegate chatToolView:self sendMessage:textField.text];
    }
    
    textField.text = @"";
    
    return YES;
}

- (IBAction)hitToolButton:(id)sender {
    
    UIButton *btn = (UIButton *)sender;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatToolView:didSelectOtherItem:)])
    {
        [self.delegate chatToolView:self didSelectOtherItem:(QXYChatToolBoxOtherItem)(btn.tag - 100)];
    }
    
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
