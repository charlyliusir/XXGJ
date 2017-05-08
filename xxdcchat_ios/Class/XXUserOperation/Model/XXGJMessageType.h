//
//  XXGJMessageType.h
//  XXGJSocketClient
//
//  Created by 刘朝龙 on 2017/3/12.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, XXGJTypeMessage) {
    XXGJNotFindMessage  = -1,
    XXGJTextMessage     = 0,
    XXGJImageMessage,
    XXGJAudioMessage,
    XXGJHeartBeat,
    XXGJRichText,
    XXGJRedEnvelope,
    XXGJPhoneMessage,
    XXGJAckMessage,
    XXGJWithdrawnMessage,
};

@interface XXGJMessageType : NSObject
+ (NSString *)messageToString:(XXGJTypeMessage)typeMessage;
@end
