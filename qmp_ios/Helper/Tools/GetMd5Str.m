//
//  GetMd5Str.m
//  QiMingPian
//
//  Created by Molly on 16/2/29.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import "GetMd5Str.h"
#import "CommonCrypto/CommonDigest.h"

@implementation GetMd5Str

+(NSString *)md5:(NSString *)str {
    const char *cStr = [str UTF8String];//转换成utf-8
    unsigned char result[16];//开辟一个16字节（128位：md5加密出来就是128位/bit）的空间（一个字节=8字位=8个二进制数）
    CC_MD5( cStr, strlen(cStr), result);
    /*
     extern unsigned char *CC_MD5(const void *data, CC_LONG len, unsigned char *md)官方封装好的加密方法
     把cStr字符串转换成了32位的16进制数列（这个过程不可逆转） 存储到了result这个空间中
     */
    NSMutableString *Mstr = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH];
    for (int i=0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [Mstr appendFormat:@"%02X",result[i]];
    }
    return Mstr;
//    NSMutableString *Mstr = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH];
//    for (int i=0; i<CC_MD5_DIGEST_LENGTH; i++) {
//        [Mstr appendFormat:@"%d",(char)result[i]];
//    }
//    return Mstr;
    /*
     x表示十六进制，%02X  意思是不足两位将用0补齐，如果多余两位则不影响
     NSLog("%02X", 0x888);  //888
     NSLog("%02X", 0x4); //04
     */
}
@end
