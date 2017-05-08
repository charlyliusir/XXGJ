//
//  XXGJAlertView.m
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/3/19.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJAlertView.h"

@interface XXGJAlertView ()
@property (nonatomic, assign)id <XXGJAlertViewDelegate>delegate;
@property (nonatomic, strong)id object;

@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;

@end

@implementation XXGJAlertView

+ (instancetype)alertViewContent:(NSString *)content withDelegate:(id <XXGJAlertViewDelegate>)delegate withObject:(id)obj
{
    XXGJAlertView *alertView = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil].lastObject;
    [alertView.contentLabel setText:content];
    alertView.delegate = delegate;
    alertView.object   = obj;
    return alertView;
}

#pragma mark - open method
- (void)setContentName:(NSString *)name alertIndex:(AlertViewIndex)alertIndex
{
    switch (alertIndex) {
        case AlertViewIndexConfirm:
            [self.confirmBtn setTitle:name forState:UIControlStateNormal];
            break;
        case AlertViewIndexCancel:
            [self.cancelBtn setTitle:name forState:UIControlStateNormal];
            break;
        default:
            break;
    }
}
#pragma mark - private method
- (IBAction)confirmAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(alertView:clickAtIndex:object:)]) {
         [self.delegate alertView:self clickAtIndex:AlertViewIndexConfirm object:self.object];
    }
}
- (IBAction)cancelAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(alertView:clickAtIndex:object:)]) {
         [self.delegate alertView:self clickAtIndex:AlertViewIndexCancel object:self.object];
    }
}

- (void)showInView:(UIView *)view
{
    [self setFrame:view.frame];
    [view addSubview:self];
    [view bringSubviewToFront:self];
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidden)];
    [self addGestureRecognizer:tapGestureRecognizer];
}

- (void)hidden
{
    [self removeFromSuperview];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
