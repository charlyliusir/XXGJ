//
//  XXGJGroupUserView.m
//  xxdcchat_ios
//
//  Created by 刘朝龙 on 2017/3/31.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "XXGJGroupUserView.h"
#import <UIButton+WebCache.h>
#import "User.h"

@interface XXGJGroupUserView()
@property (weak, nonatomic) IBOutlet UIButton *userAvatarImageBtn;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;

@end
@implementation XXGJGroupUserView

+ (instancetype)groupUserView:(User *)user isGroupOwener:(BOOL)isGroupOwener
{
    XXGJGroupUserView *groupUserView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil] lastObject];
    groupUserView.isGroupOwener = isGroupOwener;
    groupUserView.user = user;
    return groupUserView;
}

- (void)setUser:(User *)user
{
    _user = user;
    
    NSString *placeholderString = @"placeholder_user_female_icon";
    if ([_user.sex isEqualToString:@"男"]) {
        placeholderString = @"placeholder_user_female_icon";
    }
    if (_user.avatar)
    {
        [self.userAvatarImageBtn sd_setImageWithURL:[NSURL URLWithString:[XXGJ_N_BASE_IMAGE_URL stringByAppendingPathComponent:_user.avatar]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:placeholderString]];
    }else
    {
        [self.userAvatarImageBtn setImage:[UIImage imageNamed:placeholderString] forState:UIControlStateNormal];
    }
    
    if (self.isGroupOwener)
    {
        [self.userNameLabel setTextColor:[UIColor redColor]];
        [self.userNameLabel setText:[NSString stringWithFormat:@"%@(群主)", _user.nick_name]];
    }else{
        [self.userNameLabel setText:_user.nick_name];
    }
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (IBAction)clickUserAvatarAction:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickAvatarBtn:userInfo:)])
    {
        [self.delegate clickAvatarBtn:self userInfo:self.user];
    }
}

@end
