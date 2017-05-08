//
//  NSString+IMEx.m
//  IMSocketClient
//
//  Created by 刘朝龙 on 2017/3/10.
//  Copyright © 2017年 刘朝龙. All rights reserved.
//

#import "NSString+IMEx.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (IMEx)
- (NSString *) md5
{
    CC_MD5_CTX md5;
    CC_MD5_Init (&md5);
    CC_MD5_Update (&md5, [self UTF8String], (CC_LONG)[self length]);
    
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final (digest, &md5);
    NSString *s = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                   digest[0],  digest[1],
                   digest[2],  digest[3],
                   digest[4],  digest[5],
                   digest[6],  digest[7],
                   digest[8],  digest[9],
                   digest[10], digest[11],
                   digest[12], digest[13],
                   digest[14], digest[15]];
    
    return s;
}
+ (NSString *)convertToJsonData:(NSDictionary *)dict

{
    
    NSError *error;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *jsonString;
    
    if (!jsonData) {
        
        NSLog(@"%@",error);
        
    }else{
        
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        
    }
    
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    
//    NSRange range = {0,jsonString.length};
//    
//    //去掉字符串中的空格
//    
//    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
//    
//    NSRange range2 = {0,mutStr.length};
//    
//    //去掉字符串中的换行符
//    
//    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    
    return mutStr;
    
}
+ (NSString *)uuidString
{
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
    NSString *uuid = [NSString stringWithString:(__bridge NSString *)uuid_string_ref];
    CFRelease(uuid_ref);
    CFRelease(uuid_string_ref);
    return [uuid lowercaseString];
}
- (BOOL)isEmpty
{
    
    if (self==NULL) {
        return YES;
    }
    
    if ([self isEqualToString:@""]) {
        return YES;
    }
    
    if ([self isEqualToString:@" "]) {
        return YES;
    }
    
    if ([self isEqualToString:@"\n"]) {
        return YES;
    }
    if ([self containsString:@"\n    "]) {
        return YES;
    }
    
    return NO;
    
}

- (CGFloat)changeStationWidthTxtt:(CGFloat)widthText anfont:(CGFloat)fontSize
{
    UIFont * tfont = [UIFont systemFontOfSize:fontSize];
    //段落信息
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{NSFontAttributeName:tfont, NSParagraphStyleAttributeName:paragraphStyle.copy};
    //高度估计文本大概要显示几行，宽度根据需求自己定义。 MAXFLOAT 可以算出具体要多高
    CGSize size =CGSizeMake(widthText,CGFLOAT_MAX);
    //ios7方法，获取文本需要的size，限制宽度
    CGSize  actualsize =[self boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    return actualsize.height + 1;
}

@end
