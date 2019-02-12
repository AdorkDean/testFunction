//
//  PublicTool.m
//  BSOrange
//
//  Created by kenshin on 14-9-1.
//  Copyright (c) 2014年 BazzarEntertainment. All rights reserved.
//

#import "PublicTool.h"
#import <AVFoundation/AVFoundation.h>
#include <sys/xattr.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "MainNavViewController.h"
#import <MessageUI/MessageUI.h>//发邮件
#import <MBProgressHUD.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <Contacts/Contacts.h>
#import <ContactsUI/ContactsUI.h>
#include <CoreFoundation/CoreFoundation.h>

#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#include "ChatViewController.h"
#import "PersonModel.h"
#import "ProductDetailsController.h"
#import "OrganizeDetailViewController.h"
#import "ActivityModel.h"
#import "CardItem.h"
#import "ActivityListViewController.h"
#import "NewsWebViewController.h"

@interface PublicTool()<CNContactViewControllerDelegate,ABNewPersonViewControllerDelegate>

@end

@implementation PublicTool
{
    //反复init NSDateFormatter开销太大，故重用之
    NSDateFormatter *_dateFormatterYMD;
    NSDateFormatter *_dateFormatterYMD_CH;
    NSDateFormatter *_dateFormatterYMDHMS;
}


static PublicTool *gSharedInstance = nil;

+(PublicTool *)sharedInstance
{
    static dispatch_once_t disonce;
    dispatch_once(&disonce, ^{
        gSharedInstance = [[PublicTool alloc] init];
    });
    
    return gSharedInstance;
}

#pragma mark --字符串
+ (NSInteger) unicodeLengthOfString: (NSString *) text {
    NSInteger asciiLength = 0;
    
    for (NSUInteger i = 0; i < text.length; i++) {
        
        
        unichar uc = [text characterAtIndex: i];
        
        asciiLength += isascii(uc) ? 1 : 2;
    }
    
    NSInteger unicodeLength = asciiLength / 2;
    
    if(asciiLength % 2) {
        unicodeLength++;
    }
    
    return unicodeLength;
}

+ (CGFloat)widthOfString:(NSString*)string height:(CGFloat)height fontSize:(CGFloat)fontSize{
    
    CGFloat strWidth = [string boundingRectWithSize:CGSizeMake(MAXFLOAT, height) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]} context:nil].size.width;
    return strWidth;
    
}

/**
 空字符串返回 -
 */
+ (NSString*)nilStringReturn:(NSString*)str{
    if ([PublicTool isNull:str]) {
        return  @"-";
    }
    return str;
}

+ (BOOL)isNull:(NSString*)string{
    
    if ([string isEqual:@"NULL"] || [string isEqual:@"NSNull"] || [string isKindOfClass:[NSNull class]] || [string isEqual:[NSNull null]] || [string isEqual:NULL] || [[string class] isSubclassOfClass:[NSNull class]] || string == nil || string == NULL || [string isKindOfClass:[NSNull class]]){
       
        return YES;
        
    }else{
        
        if ([string isKindOfClass:[NSString class]]) {
            if([string isEqualToString:@"<null>"] || [string isEqualToString:@"(null)"] || [string isEqualToString:@"null"] || [[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]==0){
                return YES;
            }
        }
        
        return NO;
    }
}

+(NSString*)encodeString:(NSString*)unencodedString{
    NSString *encodedString = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              (CFStringRef)unencodedString,
                                                              NULL,
                                                              (CFStringRef)@"!*'();:@&;=+$,/?%#[]",
                                                              kCFStringEncodingUTF8));
    return encodedString;
}


//URLDEcode
+(NSString *)decodeString:(NSString*)encodedString
{
    NSString *decodedString = (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,
                                                                                                                    (__bridge CFStringRef)encodedString,
                                                                                                                    CFSTR(""),
                                                                                                                    CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    return decodedString;
}

+ (CGFloat)heightOfString:(NSString*)string width:(CGFloat)width font:(UIFont*)font{
    return [string boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size.height + 0.1;
}

+ (void)storeShortUrlToLocal:(NSString *)urlStr{
    
    NSMutableArray *pasteUrlMArr = nil;
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSArray *arr = [userDefault objectForKey:@"pasteUrlMArr"];
    if (arr) {
        pasteUrlMArr = [NSMutableArray arrayWithArray:arr];
    }
    else{
        
        pasteUrlMArr = [[NSMutableArray alloc] initWithCapacity:0];
    }
    NSMutableArray *urlMArr = [[NSMutableArray alloc] initWithCapacity:0];
    if (pasteUrlMArr.count > 0) {
        for (NSDictionary *dict in pasteUrlMArr) {
            [urlMArr addObject:[dict objectForKey:@"url"]];
        }
    }
    
    if (![urlMArr containsObject:urlStr]) {
        NSMutableDictionary *urlMDict = [[NSMutableDictionary alloc] initWithCapacity:0];
        [urlMDict setValue:@"" forKey:@"title"];
        [urlMDict setValue:urlStr forKey:@"url"];
        [pasteUrlMArr insertObject:urlMDict atIndex:0];
        [userDefault setValue:pasteUrlMArr forKey:@"pasteUrlMArr"];
        [userDefault synchronize];
    }
}

+ (void)deleteShortUrlToLocal:(NSString *)urlStr{
    
    NSMutableArray *pasteUrlMArr = nil;
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSArray *arr = [userDefault objectForKey:@"pasteUrlMArr"];
    if (arr) {
        pasteUrlMArr = [NSMutableArray arrayWithArray:arr];
    }else{
        return;
    }
    
    if (pasteUrlMArr.count > 0) {
        [pasteUrlMArr enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([urlStr isEqualToString:obj[@"url"]]) {
                [pasteUrlMArr removeObject:obj];
            }
        }];
    }
   
    [userDefault setValue:pasteUrlMArr forKey:@"pasteUrlMArr"];
    [userDefault synchronize];
    
}


+ (UIImage*)screenshotWithView:(UIView*)view size:(CGSize)size addBottomImage:(UIImage*)bottomImg{
    
    
    return nil;
}

//将HTML字符串转化为NSAttributedString富文本字符串
+ (NSAttributedString *)attributedStringWithHTMLString:(NSString *)htmlString
{
    NSDictionary *options = @{ NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType,
                               NSCharacterEncodingDocumentAttribute :@(NSUTF8StringEncoding) };
    
    NSData *data = [htmlString dataUsingEncoding:NSUTF8StringEncoding];
    
    return [[NSAttributedString alloc] initWithData:data options:options documentAttributes:nil error:nil];
}
+ (NSString *)strConverterFloatK:(NSString *)title{
    NSInteger count = [title integerValue];
    if (count < 1000){
        return [NSString stringWithFormat:@"%ld", count];
    }else{
        float countK = count / 1000.0;
        return [NSString stringWithFormat:@"%0.1fK", countK];
    }
    return @"";
}

//去除特殊字符
+(NSString*)filterSpecialString:(NSString*)originStr{
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"@／：；（）¥「」＂、[]{}#%-*+=_\\|~＜＞$€^•'@#$%^&*()_+'\""];
    NSString *trimmedString = [originStr stringByTrimmingCharactersInSet:set];
    trimmedString = [trimmedString stringByReplacingOccurrencesOfString:@"\r\n" withString:@""]; //换行符是\r\n 而不是\n
    trimmedString = [trimmedString stringByReplacingOccurrencesOfString:@"\n" withString:@""]; //换行符是\r\n 而不是\n
    trimmedString = [trimmedString stringByReplacingOccurrencesOfString:@"<br>" withString:@""];
    trimmedString = [trimmedString stringByReplacingOccurrencesOfString:@"<br/>" withString:@""];

    // 去掉字符串首尾的空格和字符串
    trimmedString = [trimmedString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    return trimmedString;
}

+ (BOOL)checkIsChinese:(NSString *)string{
    for (int i=0; i<string.length; i++) {
        unichar ch = [string characterAtIndex:i];
        if (0x4E00 <= ch  && ch <= 0x9FA5) {
            return YES;
        }
    }
    return NO;
}

#pragma mark -- 图片相关
+ (UIImage*)screenshotWithView:(UIView *)view size:(CGSize)size{
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);  //NO，YES 控制是否透明
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    // 生成后的image
    return image;
}

//+ (UIImage*)screenshotWithView:(UIView*)view size:(CGSize)size addBottomImage:(UIImage*)bottomImg {
//
//}


//展示HUD提示框
+ (MBProgressHUD*)showHudWithView:(UIView*)view{
   
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:view];
    
    hud.removeFromSuperViewOnHide = YES;
    hud.mode = MBProgressHUDModeIndeterminate;
//    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
//    hud.bezelView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
//    hud.contentColor = [UIColor whiteColor];

    [view addSubview:hud];
    [hud show:YES];
    
    return hud;

}

+ (MBProgressHUD*)showLoadingHUDWithTitle:(NSString*)title view:(UIView*)view{
   
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:view];
    [view addSubview:hud];

    hud.removeFromSuperViewOnHide = YES;
    hud.mode = MBProgressHUDModeIndeterminate;
    
//    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
//    hud.bezelView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
//    hud.contentColor = [UIColor whiteColor];
    
    [hud show:YES];    // Set the determinate mode to show task progress.
    hud.labelText = title;

    return hud;
}

+ (void)dismissHud:(UIView*)view{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hud = [PublicTool hudOnView:view];
        if (hud) {
            hud.removeFromSuperViewOnHide = YES;
            [hud hide:YES];
            [PublicTool dismissHud:view];
        }
    });
    
}

+ (MBProgressHUD*)hudOnView:(UIView*)view{
    for (UIView *subV in view.subviews) {
        if ([subV isKindOfClass:[MBProgressHUD class]]) {
            
            return (MBProgressHUD*)subV;
        }
    }
    return nil;
}


+ (void)showHudAlertWithTitle:(NSString *)title inView:(UIView *)tmpView success:(BOOL)success
{
    if (!tmpView) {
        tmpView = [[UIApplication sharedApplication]keyWindow];
    }

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:tmpView animated:YES];
    
    hud.removeFromSuperViewOnHide = YES;
    
//    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
//    hud.bezelView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    
    // Set the custom view mode to show any view.
    hud.mode = MBProgressHUDModeCustomView;
    // Set an image view with a checkmark.
    NSString *imgName = success ? @"mb_right" : @"mb_error";
    UIImage *image = [[UIImage imageNamed:imgName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    hud.customView = [[UIImageView alloc] initWithImage:image];
    // Looks a bit nicer if we make it square.
    hud.square = YES;
    // Optional label text.
    hud.labelText =title;
    hud.labelColor = [UIColor whiteColor];
    [hud hide:YES afterDelay:0.7];

}

+ (void)showNetWorkErrorInView:(UIView *)view{
    
    [PublicTool showHudAlertWithTitle:@"网络错误" inView:KEYWindow success:NO];

}
+ (void)showMsg:(NSString *)msg delay:(CGFloat)delay {
    [ShowInfo showInfoOnView:KEYWindow withInfo:msg delay:delay];
}
+ (void)showMsg:(NSString *)msg{
    
    [ShowInfo showInfoOnView:KEYWindow withInfo:msg];
    
    return;
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:window];
    hud.mode = ProgressHUDModeText;
    [window addSubview:hud];
//    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
//    hud.bezelView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
//    hud.contentColor = [UIColor whiteColor];
    hud.labelFont = [UIFont systemFontOfSize:14];
    hud.labelText = msg;
    [hud show:YES];
    [hud hide:YES afterDelay:0.7];
}

+ (void)showError:(NSString*)msg{
    [PublicTool showHudAlertWithTitle:msg inView:KEYWindow success:NO];
}

+ (void)showSuccess:(NSString*)msg{
    [PublicTool showHudAlertWithTitle:msg inView:KEYWindow success:YES];

}

#pragma mark - 时间处理
+ (NSString*)currentYear{
    NSString *currentDate = [PublicTool currentDateTime];
    return [currentDate substringToIndex:4];
    
}
+ (NSString*)currentDay{
    NSString *currentDate = [PublicTool currentDateTime]; //"yyyy-MM-dd HH:mm:ss"
    return [currentDate substringWithRange:NSMakeRange(5, 5)];

}

+ (NSString*)yesToday{
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:-24*60*60];
    NSString *timeString = [[[PublicTool sharedInstance] dateFormatterYMDHMS] stringFromDate:date];

    return [timeString substringWithRange:NSMakeRange(5, 5)];
}

+ (NSString *)getNowTimeStamp
{
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[dat timeIntervalSince1970];
    NSString *timeString = [NSString stringWithFormat:@"%.0f", a];
    
    return (timeString);
}

- (NSDateFormatter *)dateFormatterYMD {
    if (! _dateFormatterYMD) {
        _dateFormatterYMD = [[NSDateFormatter alloc] init];
        [_dateFormatterYMD setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        [_dateFormatterYMD setDateFormat:@"yyyy-MM-dd"];
    }
    return _dateFormatterYMD;
}

- (NSDateFormatter *)dateFormatterYMD_CH {
    if (! _dateFormatterYMD_CH) {
        _dateFormatterYMD_CH = [[NSDateFormatter alloc] init];
        [_dateFormatterYMD_CH setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        [_dateFormatterYMD_CH setDateFormat:@"yyyy年MM月dd日"];
    }
    return _dateFormatterYMD_CH;
}

- (NSDateFormatter *)dateFormatterYMDHMS {
    if (! _dateFormatterYMDHMS) {
        _dateFormatterYMDHMS = [[NSDateFormatter alloc] init];
        [_dateFormatterYMDHMS setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        [_dateFormatterYMDHMS setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    return _dateFormatterYMDHMS;
}
///将 年月日时分秒 转换为 时间戳
+ (NSString *)getTimeStamp:(NSString *)dataString withFormate:(NSString *)dataFormate{
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:dataFormate];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"Asia/Shanghai"]];
    NSDate * inputDate = [formatter dateFromString:dataString];
    NSTimeInterval tempStamp = [inputDate timeIntervalSince1970];
    NSInteger timeS = round(tempStamp);
    return  [NSString stringWithFormat:@"%ld", timeS];
}

+(NSString *)currentDateTime{
	NSDate *date = [NSDate date];
	NSString *timeString = [[[PublicTool sharedInstance] dateFormatterYMDHMS] stringFromDate:date];
	return timeString;
}

+(NSString *)dateTimeYMD:(int)seconds{
	NSDate *date = [NSDate dateWithTimeIntervalSince1970:seconds];
	NSString *timeString = [[[PublicTool sharedInstance] dateFormatterYMD] stringFromDate:date];
	return timeString;
}

+(NSString *)dateTimeYMD_CH:(int)seconds{
	NSDate *date = [NSDate dateWithTimeIntervalSince1970:seconds];
	NSString *timeString = [[[PublicTool sharedInstance] dateFormatterYMD_CH] stringFromDate:date];
	return timeString;
}

+(NSString *)dateTimeYMDHMS:(int)seconds{
	NSDate *date = [NSDate dateWithTimeIntervalSince1970:seconds];
	NSString *timeString = [[[PublicTool sharedInstance] dateFormatterYMDHMS] stringFromDate:date];
    return timeString;
}

+(NSDate *)dateFromString:(NSString *)dateString{
	NSDate *date = [[[PublicTool sharedInstance] dateFormatterYMDHMS] dateFromString:dateString];
    return date;
}

+(NSDate *)dateFromString:(NSString *)dateString formatter:(NSDateFormatter*)formatter{
    NSDate *date = [formatter dateFromString:dateString];
    return date;
}

// 2017-09-29 18:30:33  -> 今天 昨天  . .   . . .
+ (NSString*)dateString:(NSString*)originStr{
    
    NSString *year = [originStr substringToIndex:4];
    NSString *month = [originStr substringWithRange:NSMakeRange(5, 2)];
    NSString *day = [originStr substringWithRange:NSMakeRange(8, 2)];
    
    BOOL isCurrentYear = [year isEqualToString:[PublicTool currentYear]];
    NSString *today = [PublicTool currentDay]; //09-10
    BOOL isCurrentDay = NO;
    if ((month.intValue == [[today substringToIndex:2]intValue]) && (day.intValue == [[today substringFromIndex:3]intValue])) {
        isCurrentDay = YES;
    }
    
    NSString *yesToday = [[PublicTool yesToday] substringFromIndex:3];
    
    BOOL isYestoday = NO;
    if ((day.intValue == yesToday.intValue) && (month.intValue == [[today substringToIndex:2]intValue])) {
        isYestoday = YES;
    }
    
    if (isCurrentYear) {
        if (isCurrentDay) {
            return @"今日";
        }else if(isYestoday){
            return @"昨日";
        }else{
            NSString *date = [NSString stringWithFormat:@"%@-%@",month,day];
            return date;
        }
    }else{
        return [NSString stringWithFormat:@"%@-%@-%@",year,month,day];
    }
}

//2017-09-07 10:29:26
+ (NSString*)dateOfTimeString:(NSString*)originStr{
    NSString *year = [originStr substringToIndex:4];
    NSString *month = [originStr substringWithRange:NSMakeRange(5, 2)];
    NSString *day = [originStr substringWithRange:NSMakeRange(8, 2)];
    NSString *hour = [originStr substringWithRange:NSMakeRange(11, 2)];
    NSString *minute = [originStr substringWithRange:NSMakeRange(14, 2)];
    
    BOOL isCurrentYear = [year isEqualToString:[PublicTool currentYear]];
    NSString *today = [PublicTool currentDay]; //09-10
    BOOL isCurrentDay = [today isEqualToString:[originStr substringWithRange:NSMakeRange(5, 5)]];
    
    if (isCurrentYear) {
        if (isCurrentDay) {
            return [NSString stringWithFormat:@"%@:%@",hour,minute];
        }else{
            return [NSString stringWithFormat:@"%@-%@",month,day];
            
        }
    }else{
        return [NSString stringWithFormat:@"%@-%@-%@",year,month,day];
        
    }
}
//2017.9.29 -> 2017.09.29
+ (NSString*)fullDateStringWithYMRString:(NSString*)shortString{
    if (![PublicTool isNull:shortString]) {
        NSString *time = shortString;
        NSArray *arr = [time componentsSeparatedByString:@"."];
        if (arr.count > 1) {
            NSMutableString *timeStr = [NSMutableString string];
            for (NSString *str in arr) {
                NSString *dateString = str;
                if (dateString.length == 1) {
                    dateString = [NSString stringWithFormat:@"0%@",dateString];
                }
                [timeStr appendFormat:@"%@.",dateString];
            }
            [timeStr deleteCharactersInRange:NSMakeRange(timeStr.length - 1, 1)];
            return timeStr;
        }else{
            return time;
        }
    }
    return @"";
}
#pragma mark - 保存图片到相册

//创建自定义相册，并保存相片
//+ (void)saveImageToAppAlbum:(UIImage*)image success:(void (^)(void))success failure:(void (^)(NSError *error))failure{
//    
//    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
//    [assetsLibrary saveImage:image toAlbum:APPNAME completion:^(NSURL *assetURL, NSError *error) {
//        if (error) {
//            failure(error);
//        }else{
//            success();
//        }
//    } failure:^(NSError *error) {
//        failure(error);
//    }];
//}


//图片压缩
//对图片尺寸进行压缩--
+(UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // End the context
    UIGraphicsEndImageContext();
    
    // Return the new image.
    return newImage;
}

+(void)saveImageToLocal:(UIImage*)image finishedBlock:(void(^)(NSString *imageName,NSString *imagePath))finished
{
    //已日期命名图片，存储到documentDirectory
    NSDate *date = [NSDate date];
    NSDateFormatter *format = [[NSDateFormatter alloc]init];
    [format setDateFormat:@"YYYYMMDDHHmmss"];
    NSString *dateStr = [format stringFromDate:date];
    
    //压缩图片
    [PublicTool imageWithImage:image scaledToSize:CGSizeMake(image.size.width/2.0, image.size.height/2.0)];
    NSData *data;
    NSString *imageName;
    if (UIImagePNGRepresentation(image) == nil) {
        data = UIImageJPEGRepresentation(image, 1);
        imageName = [dateStr stringByAppendingString:@".jpeg"];
    } else {
        data = UIImagePNGRepresentation(image);
        imageName = [dateStr stringByAppendingString:@".png"];
    }
    
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    //文件夹

    NSString *imageDirectory = [DocumentDirectory stringByAppendingPathComponent:@"uploadImageFile"];
    if (![fileMgr fileExistsAtPath:imageDirectory]) {
        [fileMgr createDirectoryAtPath:imageDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *imagePath = [imageDirectory stringByAppendingPathComponent:imageName] ;
    [fileMgr createFileAtPath:imagePath contents:data attributes:nil];
    finished(imageName,imagePath);
    
    
}

+(void)shareImage:(UIImage*)image InController:(UIViewController*)controller success:(void (^)(void))success failure:(void (^)(NSError* error))failure{
    
}

#pragma mark - 其他

+ (NSString *)getUniqueString
{
    int randValue = arc4random() % 1000;//0 到 1000的随机数字
    NSString *randStr = [NSString stringWithFormat:@"%@%d",[self getNowTimeStamp],randValue];
    return randStr;
}

+ (void)showFadeAnimation:(UIView *)view
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.fromValue = [NSNumber numberWithFloat:0.0f];
    animation.toValue = [NSNumber numberWithFloat:1.0f];
    animation.duration = 0.5f;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [view.layer addAnimation: animation forKey: @"FadeIn"];
}


+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    const char* filePath = [[URL path] fileSystemRepresentation];
    
    const char* attrName = "com.apple.MobileBackup";
    u_int8_t attrValue = 1;
    
    int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
    return result == 0;
}


+(CGRect)amplifyFrame:(CGRect)frame times:(CGFloat)times
{
    CGRect tempFrame = CGRectZero;
    CGFloat width = (times-1)*CGRectGetWidth(frame);
    CGFloat height =(times-1)*CGRectGetHeight(frame);
    tempFrame.origin.x = CGRectGetMinX(frame)-width/2.f;
    tempFrame.origin.y = CGRectGetMinX(frame)-height/2.f;
    tempFrame.size = CGSizeMake(width+CGRectGetWidth(frame), height+CGRectGetHeight(frame));
    return tempFrame;
}

+ (UIImage *)roundImage:(UIImage *)image bounds:(CGRect)bounds
{
    UIGraphicsBeginImageContextWithOptions(bounds.size, NO, [[UIScreen mainScreen] scale]);
    
    [[UIBezierPath bezierPathWithRoundedRect:bounds
                                cornerRadius:bounds.size.width/2] addClip];
    [image drawInRect:bounds];
    
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return finalImage;
}


+(UIImage*) OriginImage:(UIImage *)image scaleToSize:(CGSize)size{
    UIGraphicsBeginImageContext(size);  //size 为CGSize类型，即你所需要的图片尺寸
    
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return scaledImage;   //返回的就是已经改变的图片
}

+ (UIImage *)compressImage:(UIImage *)image toByte:(NSUInteger)maxLength {
    // Compress by quality
    CGFloat compression = 1;
    NSData *data = UIImageJPEGRepresentation(image, compression);
    if (data.length <= maxLength) return image;
    
    CGFloat max = 1;
    CGFloat min = 0;
    for (int i = 0; i < 6; ++i) {
        compression = (max + min) / 2;
        data = UIImageJPEGRepresentation(image, compression);
        if (data.length < maxLength * 0.9) {
            min = compression;
        } else if (data.length > maxLength) {
            max = compression;
        } else {
            break;
        }
    }
    UIImage *resultImage = [UIImage imageWithData:data];
    if (data.length <= maxLength) return resultImage;
    
    // Compress by size
    NSUInteger lastDataLength = 0;
    while (data.length > maxLength && data.length != lastDataLength) {
        lastDataLength = data.length;
        CGFloat ratio = (CGFloat)maxLength / data.length;
        CGSize size = CGSizeMake((NSUInteger)(resultImage.size.width * sqrtf(ratio)),
                                 (NSUInteger)(resultImage.size.height * sqrtf(ratio))); // Use NSUInteger to prevent white blank
        UIGraphicsBeginImageContext(size);
        [resultImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
        resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        data = UIImageJPEGRepresentation(resultImage, compression);
    }
    
    return resultImage;
}

+ (BOOL)isPureLetters:(NSString*)str{
    
    for(int i=0;i<str.length;i++){
        
        unichar c=[str characterAtIndex:i];
        
        if((c<'A'||c>'Z')&&(c<'a'||c>'z'))
            
            return NO;
        
    }
    
    return YES;
    
}

//检查电话和密码、验证码

+(BOOL)checkVerifyCode:(NSString*)verifyCode
{
    if ([verifyCode length] == 0) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入验证码" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    NSString *regex = @"[0-9]{4}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch = [pred evaluateWithObject:verifyCode];
    if (!isMatch) {
        NSString *regex6 = @"[0-9]{6}";
        NSPredicate *pred6 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex6];
        BOOL isMatch6 = [pred6 evaluateWithObject:verifyCode];
        if (!isMatch6) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入正确的验证码" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            
            [alert show];
            return NO;
        }
    }
    return YES;
}


// 利用正则表达式验证
+ (BOOL )checkEmail:( NSString  *)email
{
    NSString  *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}" ;
    NSPredicate  *emailTest = [ NSPredicate   predicateWithFormat : @"SELF MATCHES%@",emailRegex];
    BOOL isRight =  [emailTest  evaluateWithObject :email];
    if (!isRight) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入正确的邮箱" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    return YES;
}
+(BOOL)checkTel:(NSString *)str
{
    if (!str || [str length] == 0) {
    
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入手机号码" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    NSString *regex = @"^(1[3|4|5|6|7|8|9][0-9]\\d{8})$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch = [pred evaluateWithObject:str];
    if (!isMatch) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入正确的手机号码" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    return YES;
}
/// 手机号和固话检测
+ (BOOL)checkIsTel:(NSString *)telStr{
    if (telStr.length==0) {
        return NO;
    }
    //手机号
    NSString * regex = @"^(1[3|4|5|6|7|8|9][0-9]\\d{8})$";
    NSPredicate * mobiTelPred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMobiMatch = [mobiTelPred evaluateWithObject:telStr];
    
    //固话
    NSString * offlineTelRegx = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    NSPredicate * offlineTelPred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", offlineTelRegx];
    BOOL isOfflineMatch = [offlineTelPred evaluateWithObject:telStr];
    
    if (isMobiMatch || isOfflineMatch) { //移动电话 or 固话（400未做判断） 可通过
        return YES;
    }
    return NO;
}


+ (BOOL)checkTel:(NSString *)str andPwd:(NSString*)pwd
{
    if ([str length] == 0) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入手机号码" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    
    NSString *regex = @"^(1[3|4|5|7|8|9][0-9]\\d{8})$";//@"^((13[0-9])|(147)|(15[^4,\\D])|(18[0,5-9]))\\d{8}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch = [pred evaluateWithObject:str];
    if (!isMatch) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"手机号格式错误" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    
    //密码长度
    if([pwd length] < 6 || [pwd length] > 16){
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"密码为6-16位" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    
    return YES;
}

+ (NSInteger)getActivityCount
{
    NSNumber *count = [[NSUserDefaults standardUserDefaults] objectForKey:@"ActivityCount"];
    if (count) {
        return count.integerValue;
    }
    
    return 0;
}

+ (void)makeACall:(NSString*)phoneNum{
    
    NSString *tmpPhoneNum = [phoneNum stringByReplacingOccurrencesOfString:@" " withString:@""];//去掉空格
    NSString *newPhoneNum = [tmpPhoneNum stringByReplacingOccurrencesOfString:@"-" withString:@""];//例如010-12345678 去掉-变成01012345678
    
    UIWebView *phoneCallWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
    [[PublicTool topViewController].view addSubview:phoneCallWebView];
    
//    if([PublicTool checkTel:newPhoneNum]){
    
        NSURL* dialUrl = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", newPhoneNum]];
        if ([[UIApplication sharedApplication] canOpenURL:dialUrl])
        {
            if (phoneCallWebView) {
                [phoneCallWebView loadRequest:[NSURLRequest requestWithURL:dialUrl]];
            }
            else{
                [[UIApplication sharedApplication] openURL:dialUrl];
            }
        }
        else
        {
            [PublicTool showMsg:@"设备不支持"];
        }
    
//    } else {
//        [PublicTool showMsg:@"您选择的号码不合法"];
//    }
}


+ (void)sendEmail:(NSString*)email{
    
    if (![MFMailComposeViewController canSendMail]) {
        [PublicTool showMsg:@"不能发送邮件,请检查邮件设置!"];
        return;
    } else{
        
        Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
        if (!mailClass) {
            [PublicTool showMsg:@"当前系统版本不支持应用内发送邮件功能，您可以使用mailto方法代替"];
            return;
        }
        if (![mailClass canSendMail]) {
            [PublicTool showMsg:@"用户没有设置邮件账户"];
            return;
        }
        
         NSMutableString *mailUrl = [[NSMutableString alloc] initWithCapacity:0];
        //添加收件人
        [mailUrl appendFormat:@"mailto:%@", email];
        //添加抄送
        [mailUrl appendFormat:@"?cc=%@", @""];
        //添加密送
        [mailUrl appendFormat:@"&bcc=%@",@""];
        //添加主题
        [mailUrl appendString:@"&subject=my email"];
        //添加邮件内容
        [mailUrl appendString:@"&body= body!"];
        NSString* email = [mailUrl stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
        [[UIApplication sharedApplication] openURL: [NSURL URLWithString:email]];
        
    }
}


+ (void)CheckAddressBookAuthorization:(void (^)(bool isAuthorized , bool isUp_ios_9))block {
    
    if (iOS9_OR_HIGHER) {
        CNContactStore * contactStore = [[CNContactStore alloc]init];
        if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusNotDetermined) {
            [contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * __nullable error) {
                if (error)
                {
                    NSLog(@"Error: %@", error);
                }
                else if (!granted)
                {
                    
                    block(NO,YES);
                }
                else
                {
                    block(YES,YES);
                }
            }];
        }else if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusAuthorized){
            block(YES,YES);
        }else {
            block(NO,YES);
//            [PublicTool showAlert:@"通讯录" message:@"请到设置>隐私>通讯录打开本应用的权限设置"];
        }
    }else {
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        ABAuthorizationStatus authStatus = ABAddressBookGetAuthorizationStatus();
        
        if (authStatus == kABAuthorizationStatusNotDetermined)
        {
            ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (error)
                    {
                        NSLog(@"Error: %@", (__bridge NSError *)error);
                    }
                    else if (!granted)
                    {
                        
                        block(NO,NO);
                    }
                    else
                    {
                        block(YES,NO);
                    }
                });
            });
        }else if (authStatus == kABAuthorizationStatusAuthorized){
            block(YES,NO);
        }else {
            block(NO,NO);

//            [PublicTool showAlert:@"通讯录" message:@"请到设置>隐私>通讯录打开本应用的权限设置"];
        }
    }
}


+ (void)savePeopleToContactForCardItem:(id) cardItemM{
    //访问手机通讯录
    [PublicTool CheckAddressBookAuthorization:^(bool isAuthorized, bool isUp_ios_9) {
        if (!isAuthorized) {
            [PublicTool showAlert:@"通讯录权限未开启" message:@"通讯录权限未开启，请进入系统【设置】>【隐私】>【通讯录】中打开开关,开启通讯录功能"];
        }
    }];
    
    CardItem *cardItem = (CardItem*)cardItemM;
    BOOL isNewContact = YES;
    
    if (iOS9_OR_HIGHER) {
        CNContactStore * store = [[CNContactStore alloc]init];
        //检索条件，检索所有名字中有zhang的联系人
        NSPredicate * predicate = [CNContact predicateForContactsMatchingName:cardItem.cardName];
        //提取数据,要修改的必需先提取出来，放在keysToFetch中提取
        NSArray * contacts = [store unifiedContactsMatchingPredicate:predicate keysToFetch:@[CNContactGivenNameKey] error:nil];
       
        for (CNContact *contact in contacts) {
            
            NSLog(@"通讯录 姓名-------%@",contact.givenName);
            NSString *name = ![PublicTool isNull:cardItem.contacts] ? cardItem.contacts:cardItem.cardName;
            if ([contact.givenName isEqualToString:name]) {
                
                //初始化方法
                CNSaveRequest * saveRequest = [[CNSaveRequest alloc]init];
                
                //删除联系人（不行）
                [saveRequest deleteContact:[contact mutableCopy]];
                [store executeSaveRequest:saveRequest error:nil];
                
                break;
            }
        }
        
    }else{
        
        // 1. 拿到通讯录
        ABAddressBookRef book = ABAddressBookCreateWithOptions(NULL, NULL);
        
        // 获取通讯录所有人
        CFArrayRef contants = ABAddressBookCopyArrayOfAllPeople(book);
        
        // 拿到通讯录中的某一个联系人
        for (NSInteger i = 0; i < CFArrayGetCount(contants); i++)
        {
            //获得People对象
            ABRecordRef person = CFArrayGetValueAtIndex(contants, i);
            CFTypeRef abName = ABRecordCopyValue(person, kABPersonFirstNameProperty);
           
            CFErrorRef error = NULL;
            NSString *nameString = (__bridge NSString *)abName;
            
            NSString *name = ![PublicTool isNull:cardItem.contacts] ? cardItem.contacts:cardItem.cardName;

            if ([nameString isEqualToString:name]) {
               
                CFRelease(abName);

                ABAddressBookRemoveRecord(book, person, &error);
                
                ABAddressBookSave(book,&error);
                
               
                break;

            }
            
            if (abName) CFRelease(abName);
            if (person) CFRelease(person);
            
        }
    }
    
    if (isNewContact) {
        
        [PublicTool addNewContact:cardItem];
        
    }    
}

+ (BOOL)isNewContact:(NSString*)phone{
    
    //访问手机通讯录
    [PublicTool CheckAddressBookAuthorization:^(bool isAuthorized, bool isUp_ios_9) {
        if (!isAuthorized) {
            [PublicTool showAlert:@"通讯录权限未开启" message:@"通讯录权限未开启，请进入系统【设置】>【隐私】>【通讯录】中打开开关,开启通讯录功能"];
        }
    }];
    
    if (iOS9_OR_HIGHER) {
        
        CNContactStore * store = [[CNContactStore alloc]init];
        NSArray *fetchKeys = @[CNContactPhoneNumbersKey];
        CNContactFetchRequest *request = [[CNContactFetchRequest alloc] initWithKeysToFetch:fetchKeys];
        
        // 3.3.请求联系人
        NSError *error = nil;
        __block BOOL isNew = YES;
        [store enumerateContactsWithFetchRequest:request error:&error usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
            // stop是决定是否要停止
            
            // 2.获取电话号码
            NSArray *phones = contact.phoneNumbers;
            
            // 3.遍历电话号码
            for (CNLabeledValue *labelValue in phones) {
                CNPhoneNumber *phoneNumber = labelValue.value;
                if ([phoneNumber.stringValue isEqualToString:phone]) {
                    isNew = NO;
                    *stop = YES;
                }
            }
        }];
        return isNew;
        
    }else{
        
        
        BOOL isNew = YES;;

        // 1. 拿到通讯录
        ABAddressBookRef book = ABAddressBookCreateWithOptions(NULL, NULL);
        
        // 获取通讯录所有人
        CFArrayRef contants = ABAddressBookCopyArrayOfAllPeople(book);
        
        // 拿到通讯录中的某一个联系人
        for (NSInteger i = 0; i < CFArrayGetCount(contants); i++)
        {
            //获得People对象
            ABRecordRef person = CFArrayGetValueAtIndex(contants, i);
            
            CFTypeRef abPhone = ABRecordCopyValue(person, kABPersonPhoneProperty);
            
            CFErrorRef error = NULL;
            NSString *phoneStr = (__bridge NSString *)abPhone;
            
            if ([phoneStr isEqualToString:phoneStr]) {
               
                isNew = NO;
                CFRelease(abPhone);
                
                ABAddressBookRemoveRecord(book, person, &error);
                
                ABAddressBookSave(book,&error);
            
                break;
                
            }
            
            if (abPhone) CFRelease(abPhone);
            if (person) CFRelease(person);
            
        }
        return isNew;
    }
    
    return NO;
}

+ (void)addNewContact:(CardItem*)cardItem{
    //访问手机通讯录
    [PublicTool CheckAddressBookAuthorization:^(bool isAuthorized, bool isUp_ios_9) {
        if (!isAuthorized) {
            [PublicTool showAlert:@"通讯录权限未开启" message:@"通讯录权限未开启，请进入系统【设置】>【隐私】>【通讯录】中打开开关,开启通讯录功能"];
        }
    }];
    
    if (iOS9_OR_HIGHER) {
        CNMutableContact *contact = [[CNMutableContact alloc] init]; // 第一次运行的时候，会获取通讯录的授权（对通讯录进行操作，有权限设置）
        
        // 1、添加姓名（姓＋名）
        NSString *name = ![PublicTool isNull:cardItem.contacts] ? cardItem.contacts:cardItem.cardName;

        contact.givenName = name;
        
        
        // 2、添加职位相关
        contact.organizationName = cardItem.company;
        contact.departmentName = cardItem.dept;
        NSString *zhiwu = ![PublicTool isNull:cardItem.zhiwei] ? cardItem.zhiwei:cardItem.zhiwu;

        contact.jobTitle = zhiwu;
        
        
        // 8、添加电话
        NSString *phone = ![PublicTool isNull:cardItem.telephone] ? cardItem.telephone:cardItem.phone;
        CNLabeledValue *homePhone = [CNLabeledValue labeledValueWithLabel:CNLabelPhoneNumberiPhone value:[CNPhoneNumber phoneNumberWithStringValue:phone]];
        contact.phoneNumbers = @[homePhone];
        
        // 9、添加urlAddresses,
        if (![PublicTool isNull:cardItem.web]) {
            CNLabeledValue *homeurl = [CNLabeledValue labeledValueWithLabel:CNLabelURLAddressHomePage value:cardItem.web];
            contact.urlAddresses = @[homeurl];
        }
       
        
        // 获取通讯录操作请求对象
        CNSaveRequest *request = [[CNSaveRequest alloc] init];
        [request addContact:contact toContainerWithIdentifier:nil]; // 添加联系人操作（同一个联系人可以重复添加）
        // 获取通讯录
        CNContactStore *store = [[CNContactStore alloc] init];
        // 保存联系人
        [store executeSaveRequest:request error:nil];
        
       
    }else{
        
        //拿到通讯录
        ABAddressBookRef book = ABAddressBookCreateWithOptions(NULL, NULL);
        CFErrorRef error = NULL;

        // 1. 创建联系人
        ABRecordRef people = ABPersonCreate();
        
        // 2. 设置联系人信息
        NSString *name = ![PublicTool isNull:cardItem.contacts] ? cardItem.contacts:cardItem.cardName;
        ABRecordSetValue(people, kABPersonFirstNameProperty, (__bridge CFStringRef)name, NULL);
        
        // 创建电话号码
        
        //创建一个多值属性(电话)
        NSString *phone = ![PublicTool isNull:cardItem.telephone] ? cardItem.telephone:cardItem.phone;

        ABMutableMultiValueRef multi = ABMultiValueCreateMutable(kABMultiStringPropertyType);
        ABMultiValueAddValueAndLabel(multi, (__bridge CFTypeRef)phone, kABPersonPhoneMobileLabel, NULL);
        ABRecordSetValue(people, kABPersonPhoneProperty, multi, &error);
        
        //公司
        ABRecordSetValue(people, kABPersonOrganizationProperty, (__bridge CFStringRef)cardItem.company, NULL);
        ABRecordSetValue(people, kABPersonDepartmentProperty, (__bridge CFStringRef)cardItem.dept, NULL);
        NSString *zhiwu = ![PublicTool isNull:cardItem.zhiwei] ? cardItem.zhiwei:cardItem.zhiwu;

        ABRecordSetValue(people, kABPersonJobTitleProperty, (__bridge CFStringRef)zhiwu, NULL);
//
//        //邮箱
//        ABRecordSetValue(people, kABPersonEmailProperty, (__bridge CFStringRef)cardItem.email, NULL);
        

       
        // 4. 将联系人添加到通讯录中
        ABAddressBookAddRecord(book, people, &error);
        
        // 5. 保存通讯录
        ABAddressBookSave(book, &error);
        CFRelease(multi);
        CFRelease(people);
        CFRelease(book);
    }
    
}

+ (void)dealPhone:(NSString*)phone{
    
    
    if ([PublicTool isNull:phone]) {
        [PublicTool showMsg:@"暂无联系方式"];
        return;
    }
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:phone message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *callAction = [UIAlertAction actionWithTitle:@"呼叫" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFI_STATUSBAR_REFRESH object:nil];
        [PublicTool makeACall:phone];
    }];
    
    [alertVC addAction:callAction];
    UIAlertAction *copyAction = [UIAlertAction actionWithTitle:@"复制" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFI_STATUSBAR_REFRESH object:nil];
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = phone;
        [PublicTool showMsg:@"复制成功"];
    }];
    
    [alertVC addAction:copyAction];
    
    UIAlertAction *toContact;
    if (![PublicTool isNull:phone]) {
        toContact = [UIAlertAction actionWithTitle:@"添加到手机通讯录" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFI_STATUSBAR_REFRESH object:nil];
            [self savePhone:phone];
        }];
        [alertVC addAction:toContact];
        //
    }
    
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFI_STATUSBAR_REFRESH object:nil];
    }];
    [alertVC addAction:cancleAction];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        
        UIPopoverPresentationController *popPresenter = [alertVC popoverPresentationController];
        popPresenter.sourceView = [PublicTool topViewController].view;
        popPresenter.sourceRect = CGRectMake(0, SCREENH-150, SCREENW, 150);
        [[PublicTool topViewController] presentViewController:alertVC animated:YES completion:nil];
        
    } else {
        [[PublicTool topViewController].navigationController presentViewController:alertVC animated:YES completion:nil];
    }
    
}

+ (void)dealWechat:(NSString*)wechat{
    
    if ([PublicTool isNull:wechat]) {
        [PublicTool showMsg:@"暂无微信"];
        return;
    }
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:wechat message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *copyAction = [UIAlertAction actionWithTitle:@"复制" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFI_STATUSBAR_REFRESH object:nil];
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = wechat;
        [PublicTool showMsg:@"复制成功"];
    }];
    
    [alertVC addAction:copyAction];
    
    UIAlertAction *toContact;
    if (![PublicTool isNull:wechat]) {
        toContact = [UIAlertAction actionWithTitle:@"复制并打开微信" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFI_STATUSBAR_REFRESH object:nil];
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = wechat;
            NSURL *url = [NSURL URLWithString:@"weixin://"];
            BOOL canOpen = [[UIApplication sharedApplication] canOpenURL:url];
            if (canOpen) {
                [[UIApplication sharedApplication] openURL:url];
            }else{
                [PublicTool showMsg:@"未安装微信"];
            }
            
        }];
        [alertVC addAction:toContact];
        //
    }
    
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFI_STATUSBAR_REFRESH object:nil];
    }];
    [alertVC addAction:cancleAction];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        
        UIPopoverPresentationController *popPresenter = [alertVC popoverPresentationController];
        popPresenter.sourceView = [PublicTool topViewController].view;
        popPresenter.sourceRect = CGRectMake(0, SCREENH-150, SCREENW, 150);
        [[PublicTool topViewController] presentViewController:alertVC animated:YES completion:nil];
        
    } else {
        [[PublicTool topViewController].navigationController presentViewController:alertVC animated:YES completion:nil];
    }
    
}

+ (void)dealEmail:(NSString*)email{
    if ([PublicTool isNull:email]) {
        [PublicTool showMsg:@"暂无邮箱"];
        return;
    }
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:email message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *copyAction = [UIAlertAction actionWithTitle:@"复制" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFI_STATUSBAR_REFRESH object:nil];
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = email;
        [PublicTool showMsg:@"复制成功"];
    }];
    
    [alertVC addAction:copyAction];
    
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFI_STATUSBAR_REFRESH object:nil];
    }];
    [alertVC addAction:cancleAction];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        
        UIPopoverPresentationController *popPresenter = [alertVC popoverPresentationController];
        popPresenter.sourceView = [PublicTool topViewController].view;
        popPresenter.sourceRect = CGRectMake(0, SCREENH-150, SCREENW, 150);
        [[PublicTool topViewController] presentViewController:alertVC animated:YES completion:nil];
        
    } else {
        [[PublicTool topViewController].navigationController presentViewController:alertVC animated:YES completion:nil];
    }
}

+ (void)dealPhone:(NSString*)phone message:(NSString*)msg{
    if ([PublicTool isNull:phone]) {
        [PublicTool showMsg:@"暂无联系方式"];
        return;
    }
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:phone message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *callAction = [UIAlertAction actionWithTitle:@"呼叫" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFI_STATUSBAR_REFRESH object:nil];
        [PublicTool makeACall:phone];
    }];
    
    [alertVC addAction:callAction];
    UIAlertAction *copyAction = [UIAlertAction actionWithTitle:@"复制" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFI_STATUSBAR_REFRESH object:nil];
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = phone;
        [PublicTool showMsg:@"复制成功"];
    }];
    
    [alertVC addAction:copyAction];
    
    UIAlertAction *toContact = [UIAlertAction actionWithTitle:@"添加到手机通讯录" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFI_STATUSBAR_REFRESH object:nil];
        [self savePhone:phone];
    }];
    [alertVC addAction:toContact];
    
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFI_STATUSBAR_REFRESH object:nil];
    }];
    [alertVC addAction:cancleAction];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        
        UIPopoverPresentationController *popPresenter = [alertVC popoverPresentationController];
        popPresenter.sourceView = [PublicTool topViewController].view;
        popPresenter.sourceRect = CGRectMake(0, SCREENH-150, SCREENW, 150);
        [[PublicTool topViewController] presentViewController:alertVC animated:YES completion:nil];
        
    } else {
        [[PublicTool topViewController].navigationController presentViewController:alertVC animated:YES completion:nil];
    }
}

+ (void)dealWechat:(NSString*)wechat message:(NSString*)msg{
    
    if ([PublicTool isNull:wechat]) {
        [PublicTool showMsg:@"暂无微信"];
        return;
    }
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:wechat message:msg preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *copyAction = [UIAlertAction actionWithTitle:@"复制" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFI_STATUSBAR_REFRESH object:nil];
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = wechat;
        [PublicTool showMsg:@"复制成功"];
    }];
    
    [alertVC addAction:copyAction];
    
    UIAlertAction *toContact;
    if (![PublicTool isNull:wechat]) {
        toContact = [UIAlertAction actionWithTitle:@"复制并打开微信" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFI_STATUSBAR_REFRESH object:nil];
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = wechat;
            NSURL *url = [NSURL URLWithString:@"weixin://"];
            BOOL canOpen = [[UIApplication sharedApplication] canOpenURL:url];
            if (canOpen) {
                [[UIApplication sharedApplication] openURL:url];
            }else{
                [PublicTool showMsg:@"未安装微信"];
            }
            
        }];
        [alertVC addAction:toContact];
        //
    }
    
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFI_STATUSBAR_REFRESH object:nil];
    }];
    [alertVC addAction:cancleAction];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        
        UIPopoverPresentationController *popPresenter = [alertVC popoverPresentationController];
        popPresenter.sourceView = [PublicTool topViewController].view;
        popPresenter.sourceRect = CGRectMake(0, SCREENH-150, SCREENW, 150);
        [[PublicTool topViewController] presentViewController:alertVC animated:YES completion:nil];
        
    } else {
        [[PublicTool topViewController].navigationController presentViewController:alertVC animated:YES completion:nil];
    }
}

+ (void)dealEmail:(NSString*)email message:(NSString*)msg{
    
    if ([PublicTool isNull:email]) {
        [PublicTool showMsg:@"暂无邮箱"];
        return;
    }
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:email message:msg preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *copyAction = [UIAlertAction actionWithTitle:@"复制" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFI_STATUSBAR_REFRESH object:nil];
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = email;
        [PublicTool showMsg:@"复制成功"];
    }];
    
    [alertVC addAction:copyAction];
    
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFI_STATUSBAR_REFRESH object:nil];
    }];
    [alertVC addAction:cancleAction];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        
        UIPopoverPresentationController *popPresenter = [alertVC popoverPresentationController];
        popPresenter.sourceView = [PublicTool topViewController].view;
        popPresenter.sourceRect = CGRectMake(0, SCREENH-150, SCREENW, 150);
        [[PublicTool topViewController] presentViewController:alertVC animated:YES completion:nil];
        
    } else {
        [[PublicTool topViewController].navigationController presentViewController:alertVC animated:YES completion:nil];
    }
}


+ (void)savePhone:(NSString *)phone{
    //访问手机通讯录
    [PublicTool CheckAddressBookAuthorization:^(bool isAuthorized, bool isUp_ios_9) {
        if (!isAuthorized) {
            [PublicTool showAlert:@"通讯录权限未开启" message:@"通讯录权限未开启，请进入系统【设置】>【隐私】>【通讯录】中打开开关,开启通讯录功能"];
        }
    }];
    
    if(![PublicTool isNewContact:phone]){
        [PublicTool showMsg:@"该手机号已存在"];
        return;
    };

    if (iOS9_OR_HIGHER) {
        //1.创建Contact对象，必须是可变的
        CNMutableContact *contact = [[CNMutableContact alloc] init];
        //2.为contact赋值，setValue4Contact中会给出常用值的对应关系
        CNLabeledValue *phoneNumber = [CNLabeledValue labeledValueWithLabel:CNLabelPhoneNumberMobile value:[CNPhoneNumber phoneNumberWithStringValue:phone]];
        contact.phoneNumbers = @[phoneNumber];
        
        //3.创建新建好友页面
        CNContactViewController *controller = [CNContactViewController viewControllerForNewContact:contact];
        //代理内容根据自己需要实现
        controller.delegate = [PublicTool sharedInstance];
        //4.跳转
        UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:controller];
        [[PublicTool topViewController].navigationController presentViewController:navigation animated:YES completion:^{
            
        }];
        
    }else{
        
        ABNewPersonViewController *newPersonVC = [[ABNewPersonViewController alloc] init];
        newPersonVC.newPersonViewDelegate = [PublicTool sharedInstance];;
        
        ABRecordRef newPerson = ABPersonCreate();
        
        ABMultiValueRef phones = ABMultiValueCreateMutable(kABMultiStringPropertyType);
        CFStringRef mobile = (__bridge_retained CFStringRef)phone;
        ABMultiValueAddValueAndLabel(phones, mobile, kABPersonPhoneMainLabel, NULL);
        ABRecordSetValue(newPerson, kABPersonPhoneProperty, phones, NULL);
        
        ABAddressBookRef ref = ABAddressBookCreate();
        ABAddressBookAddRecord(ref, newPerson, nil);
        newPersonVC.displayedPerson = newPerson;
        
        CFRelease(mobile);
        CFRelease(newPerson);
        CFRelease(ref);
        
        ABPeoplePickerNavigationController *pNC = [[ABPeoplePickerNavigationController alloc] initWithRootViewController:newPersonVC];
        [[PublicTool topViewController] presentViewController:pNC animated:YES completion:nil];
    }
    
}

- (void)newPersonViewController:(ABNewPersonViewController *)newPersonView didCompleteWithNewPerson:(nullable ABRecordRef)person{
    
    [newPersonView dismissViewControllerAnimated:YES completion:nil];
    
}
#pragma mark --CNContactViewControllerDelegate
- (void)contactViewController:(CNContactViewController *)viewController didCompleteWithContact:(nullable CNContact *)contact{
    [viewController dismissViewControllerAnimated:YES completion:nil];
}


+ (void)showAlert:(NSString *)title message:(NSString *)message{
    
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshStatusBar" object:nil];
    }];
    
    UIAlertAction * otherAction = [UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshStatusBar" object:nil];

        NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        
        if([[UIApplication sharedApplication] canOpenURL:url]) {
            
            NSURL*url =[NSURL URLWithString:UIApplicationOpenSettingsURLString];
            
            [[UIApplication sharedApplication] openURL:url];
            
        }

        
  }];
    
    [alert addAction:cancelAction];
    [alert addAction:otherAction];
    [[PublicTool topViewController].navigationController presentViewController:alert animated:YES completion:nil];
    
}


+ (BOOL)isMsgActivityShow
{
    NSNumber* numberOfActivity = [[NSUserDefaults standardUserDefaults] objectForKey:@"localActivityCount"];
    NSNumber* numberOfActivityRequest = [[NSUserDefaults standardUserDefaults] objectForKey:@"requestActivityCount"];
    return [numberOfActivity integerValue] < [numberOfActivityRequest integerValue];
}

+(void)setLabel:(UILabel *)label color:(UIColor *)color string:(NSString *)str font:(UIFont *)font withLineSpacing:(CGFloat)space{
    
    NSMutableAttributedString * mas=[[NSMutableAttributedString alloc]init];
    
    NSMutableParagraphStyle * style=[NSMutableParagraphStyle new];
    
    style.alignment=NSTextAlignmentLeft;
    
    style.lineSpacing=space;
    
    style.lineBreakMode = NSLineBreakByTruncatingTail;
    
    style.paragraphSpacing=space;
    
    //    style.headIndent = 10;
    //    style.tailIndent = 10;
    
    NSDictionary * attributesDict=@{
                                    NSFontAttributeName:font,		//label.text字体大小
                                    NSForegroundColorAttributeName:color,	//label.textColor 字体颜色
                                    NSBackgroundColorAttributeName:[UIColor orangeColor],
                                    NSParagraphStyleAttributeName:style
                                    };
    
    NSAttributedString *as=[[NSAttributedString alloc]initWithString:str attributes:attributesDict];
    
    [mas appendAttributedString:as];
    
    [label setAttributedText:mas];
    
    return;
    
    NSMutableAttributedString *s =
    [[NSMutableAttributedString alloc] initWithString:str];
    
    [s addAttribute:NSBackgroundColorAttributeName
              value:[UIColor greenColor]
              range:NSMakeRange(0, s.length)];
    
    label.attributedText = s;
    
}

+ (UIImage *)imageWithName:(NSString *)imageName
{
    UIImage *image = [UIImage imageNamed:imageName];
    if (iPhone6) {
        UIImage *imageIphone6 = [UIImage imageNamed:[NSString stringWithFormat:@"%@-iphone6",imageName]];
        if (imageIphone6) {
            image = imageIphone6;
        }
    }
    return image;
}

+ (UIFont *)makeFontItalic:(UIFont *)font radio:(CGFloat)radio
{
    CGAffineTransform matrix =  CGAffineTransformMake(1, 0, tanf(radio * (CGFloat)M_PI / 180), 1, 0, 0);
    UIFontDescriptor *desc = [UIFontDescriptor fontDescriptorWithName : font.fontName matrix :matrix];
    
    UIFont *fontItalic = [UIFont fontWithDescriptor :desc size :font.pointSize];
    
    return fontItalic;
}

//* 获取目前的控制器*/
+(UIViewController *)getCurrentVC{
    
    UIWindow *window = [[UIApplication sharedApplication].windows firstObject];
    if (!window) {
        return nil;
    }
    UIView *tempView;
    for (UIView *subview in window.subviews) {
        if ([[subview.classForCoder description] isEqualToString:@"UILayoutContainerView"]) {
            tempView = subview;
            break;
        }
    }
    if (!tempView) {
        tempView = [window.subviews lastObject];
    }
    
    id nextResponder = [tempView nextResponder];
    while (![nextResponder isKindOfClass:[UIViewController class]] || [nextResponder isKindOfClass:[UINavigationController class]] || [nextResponder isKindOfClass:[UITabBarController class]]) {
        tempView =  [tempView.subviews firstObject];
        
        if (!tempView) {
            return nil;
        }
        nextResponder = [tempView nextResponder];
    }
    return  (UIViewController *)nextResponder;

   
}

/**
 *
 *  获取最上层的vc
 */
+ (UIViewController*)topViewController
{
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    return [PublicTool topViewControllerWithRootViewController:window.rootViewController];
}

+ (UIViewController*)topViewControllerWithRootViewController:(UIViewController*)rootViewController {

    if([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController* tabBarController = (UITabBarController*)rootViewController;
        return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* nav = (UINavigationController*)rootViewController;
        return [self topViewControllerWithRootViewController:nav.visibleViewController];
    } else if (rootViewController.presentedViewController) {
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        return [self topViewControllerWithRootViewController:presentedViewController];
    } else {
        return rootViewController;
    }
}
#pragma mark --- 相机相册--
+ (BOOL)isCameraAvailable{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusAuthorized) {
        return YES;
    }
    else if(authStatus == AVAuthorizationStatusDenied || authStatus == AVAuthorizationStatusRestricted) {
        return NO;
    }
    else if(authStatus == AVAuthorizationStatusNotDetermined){
        //弹出系统的相机提示
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            
        }];
        return YES;
    }
    return NO;
}
+ (BOOL)isAlbumAvailable{
    ALAuthorizationStatus authStatus = [ALAssetsLibrary authorizationStatus];
    if (authStatus == ALAuthorizationStatusDenied || authStatus == ALAuthorizationStatusRestricted) {
        return NO;
    }
    else if(authStatus == ALAuthorizationStatusAuthorized){
        return  YES;
    }
    else if(authStatus == ALAuthorizationStatusNotDetermined){
        return YES;
    }
    return NO;
}

/*
 用户版本 与 appstore版本相差几个版本，4.5.3  6.4.5
 */
+ (NSInteger)userAppVersionToAppStore:(NSString*)appstoreVersion userAppVersion:(NSString*)userAppVersion{
    NSArray *appstoreArr = [appstoreVersion componentsSeparatedByString:@"."];
    NSArray *userAppArr = [userAppVersion componentsSeparatedByString:@"."];

    
    
    return 0;
}


+ (void)deleteFileForPath:(NSString*)path{
    NSFileManager *fileM = [NSFileManager defaultManager];
    
    if ([fileM fileExistsAtPath:path]) {
        
        [fileM removeItemAtPath:path error:nil];
    }
}

+ (UIView *)findKeyboard {
    UIView *keyboardView = nil;
    NSArray *windows = [[UIApplication sharedApplication] windows];
    //逆序效率更高，因为键盘总在上方
    for (UIWindow *window in [windows reverseObjectEnumerator]) {
        keyboardView = [PublicTool findKeyboardInView:window];
        if (keyboardView) {
            return keyboardView;
        }
    }
    return nil;
}

+ (UIView *)findKeyboardInView:(UIView *)view {
    for (UIView *subView in [view subviews]) {
        if (strstr(object_getClassName(subView), "UIKeyboard")) {
            return subView;
        }
        else {
            UIView *tempView = [self findKeyboardInView:subView];
            if (tempView) {
                return tempView;
            }
        }
    }
    return nil;
}

//从detail url中获取跳转参数
+ (NSMutableDictionary *)toGetDictFromStr:(NSString *)tempStr{
    
    if (![tempStr containsString:@"?"] || ![tempStr isKindOfClass:[NSString class]]) {
        return[NSMutableDictionary dictionary];
    }
    
    NSMutableDictionary *mdict = [NSMutableDictionary dictionaryWithCapacity:0];
    NSArray *arr1 = [tempStr componentsSeparatedByString:@"?"]; //从字符A中分隔成2个元素的数组
    if (arr1.count == 2) {
        NSArray *arr2 = [arr1.lastObject componentsSeparatedByString:@"&"];

        for (NSString *tmpStr in arr2) {
            NSArray *arr3 = [tmpStr componentsSeparatedByString:@"="];
            [mdict setValue:arr3.lastObject forKey:arr3.firstObject];
        }
    }
//    else{
//
//        [mdict setValue:@"7a170c950d455fed879e2262890bb6a2" forKey:@"ticket"];
//        [mdict setValue:@"fa1db6f27fe528dc10124fa6ecdaf73a" forKey:@"id"];
//    }

    return mdict;
}


+ (void)enterDetail:(NSString*)urlStr{

    NSDictionary *urlDict = [PublicTool toGetDictFromStr:urlStr];
    if ([PublicTool isNull:urlDict[@"ticket"]] || [PublicTool isNull:urlDict[@"id"]]) {
        return;
    }
    if([urlStr containsString:@"detailcom"]){

        //如果是公司
        ProductDetailsController *companyDetailVC = [[ProductDetailsController alloc]init];
        companyDetailVC.urlDict = urlDict;
        [[PublicTool topViewController].navigationController pushViewController:companyDetailVC animated:YES];

    }else if([urlStr containsString:@"detailorg"]){
        //如果是机构
        OrganizeDetailViewController *jigouDetailVC = [[OrganizeDetailViewController alloc]init];
        jigouDetailVC.urlDict = urlDict;
        [[PublicTool topViewController].navigationController pushViewController:jigouDetailVC animated:YES];

    }
}

+ (void)enterActivityListControllerWithID:(NSString *)ID type:(ActivityListViewControllerType)theType {
    
    ActivityListViewController *vc = [[ActivityListViewController alloc] init];
    vc.ID = ID;
    vc.type = theType;
    [[self topViewController].navigationController pushViewController:vc animated:YES];
}

+ (void)enterActivityListControllerWithID:(NSString *)ID type:(ActivityListViewControllerType)theType model:(id)aModel refresh:(void(^)(void))refreshBlock {
    ActivityListViewController *vc = [[ActivityListViewController alloc] init];
    vc.ID = ID;
    vc.ticket = ID;
    vc.type = theType;
    vc.model = aModel;
    vc.activityValueChangeBlock = refreshBlock;
    [[self topViewController].navigationController pushViewController:vc animated:YES];
}
+ (void)enterActivityListControllerWithTicket:(NSString *)ticket type:(ActivityListViewControllerType)theType model:(id)aModel refresh:(void(^)(void))refreshBlock {
    ActivityListViewController *vc = [[ActivityListViewController alloc] init];
    vc.ticket = ticket;
    vc.type = theType;
    vc.model = aModel;
    vc.activityValueChangeBlock = refreshBlock;
    [[self topViewController].navigationController pushViewController:vc animated:YES];
}

//无用
+ (void)enterOfficinalPage:(NSString*)ID  ticket:(NSString*)ticket{
//    OfficialPersonViewController *officialVC = [[OfficialPersonViewController alloc]init];
//    officialVC.ticket = ticket;
//    officialVC.ticketID = ID;
//    [[PublicTool topViewController].navigationController pushViewController:officialVC animated:YES];
}

//+ (void)enterPostActivity:(NSString*)url{
//    UIViewController *v = [PublicTool topViewController];
//    if ([v isKindOfClass:[PostActivityViewController class]]) {
//        [v.navigationController popViewControllerAnimated:NO];
//    }
//    PostActivityViewController *vc = [[PostActivityViewController alloc] init];
//    vc.link_url = url;
//    vc.needGo = YES;
//    [[PublicTool topViewController].navigationController pushViewController:vc animated:YES];
//}

//全为数字
+ (BOOL)isNum:(NSString *)checkedNumString {
    checkedNumString = [checkedNumString stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
    if(checkedNumString.length > 0) {
        return NO;
    }
    return YES;
}



+ (NSArray*)rangeOfSubString:(NSString*)subStr inString:(NSString*)string {
    if (subStr.length > string.length) {
        return @[];
    }
    NSMutableArray *rangeArray = [NSMutableArray array];
    NSString*string1 = [string stringByAppendingString:subStr];
    NSString *temp;
    for(int i =0; i <= string.length-subStr.length; i ++) {
        temp = [string1 substringWithRange:NSMakeRange(i, subStr.length)];
        if ([temp isEqualToString:subStr]) {
            NSRange range = {i,subStr.length};
            [rangeArray addObject: [NSValue valueWithRange:range]];
        }
    }
    return rangeArray;
    
}

+ (NSArray*)noDifferenceUporLowRangeOfSubString:(NSString*)subStr inString:(NSString*)string {
    if (subStr.length > string.length) {
        return @[];
    }
    NSMutableArray *rangeArray = [NSMutableArray array];
    NSString*string1 = [string stringByAppendingString:subStr];
    NSString *temp;
    for(int i =0; i <= string.length-subStr.length; i ++) {
        temp = [string1 substringWithRange:NSMakeRange(i, subStr.length)];
        if ([temp caseInsensitiveCompare:subStr] == NSOrderedSame) {
            NSRange range = {i,subStr.length};
            [rangeArray addObject: [NSValue valueWithRange:range]];
        }
    }
    return rangeArray;
    
}

//获取拼音首字母(传入汉字字符串, 返回大写拼音首字母)
+ (NSString *)firstCharactor:(NSString *)aString
{
    if (!aString) {
        return @"";
    }
    //转成了可变字符串
    NSMutableString *str = [NSMutableString stringWithString:aString];
    //先转换为带声调的拼音
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformMandarinLatin,NO);
    //再转换为不带声调的拼音
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformStripDiacritics,NO);
    //转化为大写拼音
    NSString *pinYin = [str capitalizedString];
    //获取并返回首字母
    if (pinYin.length >= 1) {
        return [pinYin substringWithRange:NSMakeRange(0, 1)];
    }else{
        return @"";
    }
}


//存储好友信息
+ (void)saveFriendInfo:(NSArray*)friendArr{
    
    NSMutableDictionary *friendInfoDic = [NSMutableDictionary dictionaryWithContentsOfFile:[PublicTool friendInfoPath]];
    for (FriendModel *friend1 in friendArr) {
        if (![PublicTool isNull:friend1.usercode]) {
             [friendInfoDic setValue:[NSString stringWithFormat:@"%@|%@",friend1.headimgurl?friend1.headimgurl:@"",friend1.nickname?friend1.nickname:@""] forKey:friend1.usercode];
        }
       
    }
    [friendInfoDic writeToFile:[PublicTool friendInfoPath] atomically:YES];
}

+ (FriendModel*)friendForUsercode:(NSString*)usercode{
    NSMutableDictionary *friendInfoDic = [NSMutableDictionary dictionaryWithContentsOfFile:[PublicTool friendInfoPath]];
    NSString *value = [friendInfoDic valueForKey:usercode];
     FriendModel *friendM = [[FriendModel alloc]init];
    
    if (value) {
        NSArray *arr = [value componentsSeparatedByString:@"|"];
       
        friendM.headimgurl = arr[0];
        friendM.nickname = arr[1];
    }
    
    return friendM;
}

+ (NSString*)friendInfoPath{
    
    NSString *documentPath =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    NSString *friendInfoPath = [documentPath stringByAppendingPathComponent:@"friendInfo.plist"];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    if (![fileMgr fileExistsAtPath:friendInfoPath]) {
        [fileMgr createFileAtPath:friendInfoPath contents:[NSData data] attributes:nil];

        NSDictionary *dic = @{@"1":@"1"};
        [dic writeToFile:[PublicTool friendInfoPath] atomically:YES];

    }
    return friendInfoPath;
}


+ (BOOL)haveProperty:(NSString*)property class:(id)object{
    u_int count = 0;
    objc_property_t *properties = class_copyPropertyList([object class], &count);
    NSMutableArray *propertyStr = [NSMutableArray array];
    for (int i = 0; i < count; i++) {
        const char *propertyName = property_getName(properties[i]);
        NSString *str = [NSString stringWithCString:propertyName encoding:NSUTF8StringEncoding];
        [propertyStr addObject:str];
    }
    if ([propertyStr containsObject:property]) {
        return YES;
    }
    return NO;
}

+ (void)alertActionWithTitle:(NSString*)title message:(NSString*)message cancleAction:(void (^)(void))cancleAction sureAction:(void (^)(void)) sureAction{

    UIAlertController * alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshStatusBar" object:nil];
        if (cancleAction) {
            cancleAction();
        }
    }];
    
    UIAlertAction * otherAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshStatusBar" object:nil];
        if (sureAction) {
            sureAction();
        }
    }];
    
    [alert addAction:cancelAction];
    [alert addAction:otherAction];
    [[PublicTool topViewController].navigationController presentViewController:alert animated:YES completion:nil];
}

+ (void)alertActionWithTitle:(NSString*)title message:(NSString*)message leftTitle:(NSString*)leftTitle rightTitle:(NSString*)rightTitle  leftAction:(void (^)(void))cancleAction rightAction:(void (^)(void)) sureAction{
    
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:leftTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshStatusBar" object:nil];
        if (cancleAction) {
            cancleAction();
        }
        
    }];
    
    UIAlertAction * otherAction = [UIAlertAction actionWithTitle:rightTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshStatusBar" object:nil];
        if (sureAction) {
            sureAction();
        }
    }];
    
    [alert addAction:cancelAction];
    [alert addAction:otherAction];
    [[PublicTool topViewController].navigationController presentViewController:alert animated:YES completion:nil];
}

+ (void)alertActionWithTitle:(NSString*)title message:(NSString*)message leftTitle:(NSString*)leftTitle rightTitle:(NSString*)rightTitle  leftActionClick:(void (^)(void))cancleAction rightActionClick:(void (^)(void)) sureAction leftEnable:(BOOL)leftEnable rightEnable:(BOOL)rightEnable{
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:leftTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshStatusBar" object:nil];
        if (cancleAction) {
            cancleAction();
        }
        
    }];
    
    UIAlertAction * otherAction = [UIAlertAction actionWithTitle:rightTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshStatusBar" object:nil];
        if (sureAction) {
            sureAction();
            
        }
    }];
    
    [alert addAction:cancelAction];
    [alert addAction:otherAction];
    cancelAction.enabled = leftEnable;
    otherAction.enabled = rightEnable;
    [[PublicTool topViewController].navigationController presentViewController:alert animated:YES completion:nil];
}

+ (void)alertActionWithTitle:(NSString*)title message:(NSString*)message btnTitle:(NSString*)btnTitle  action:(void (^)(void)) sureAction{
    
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
   
    UIAlertAction * otherAction = [UIAlertAction actionWithTitle:btnTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshStatusBar" object:nil];
        if (sureAction) {
            sureAction();
        }
    }];
    
    [alert addAction:otherAction];
    [[PublicTool topViewController].navigationController presentViewController:alert animated:YES completion:nil];
}
+ (void)alertVCWithTitle:(NSString *)title message:(NSString *)message defaultTitle:(NSString *)defaultTitle defaultAction:(void (^)(void))defaultBlock cancelTitle:(NSString *)cancelTitle cancelAction:(void (^)(void))cancelBlock{
    UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:[PublicTool isNull:title]?@"":title message:message  preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * deleteAction  = [UIAlertAction actionWithTitle:defaultTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshStatusBar" object:nil];

        if (defaultBlock) {
            defaultBlock();
        }
    }];
    
    [alertVC addAction:deleteAction];
    
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshStatusBar" object:nil];
        if (cancelBlock) {
            cancelBlock();
        }
    }];
    [alertVC addAction:cancelAction];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UIPopoverPresentationController *popPresenter = [alertVC popoverPresentationController];
        popPresenter.sourceView = [PublicTool getCurrentVC].view;
        popPresenter.sourceRect = CGRectMake(0, SCREENH-150, SCREENW, 150);
        [[PublicTool getCurrentVC] presentViewController:alertVC animated:YES completion:nil];
    } else {
        [[PublicTool getCurrentVC] presentViewController:alertVC animated:YES completion:^{
        }];
    }
}

+ (void)enterSystemContactAlbum{
    
    if (iOS9_OR_HIGHER) {
        CNContactPickerViewController *addressPicker = [[CNContactPickerViewController alloc] init];
        
        [[PublicTool topViewController].navigationController presentViewController:addressPicker animated:YES completion:nil];
        
    }else{
        
        ABPeoplePickerNavigationController *addressPicker = [[ABPeoplePickerNavigationController alloc] init];
        
        [[PublicTool topViewController].navigationController presentViewController:addressPicker animated:YES completion:nil];
    }
    
}

+ (NSMutableArray *)getAllContact{
    
    NSMutableArray *contactArr = [NSMutableArray array];
    
    if (iOS9_OR_HIGHER) {
        CNContactStore *contactStore = [CNContactStore new];
        NSArray *keys = @[CNContactPhoneNumbersKey,CNContactGivenNameKey];
        // 获取通讯录中所有的联系人
        CNContactFetchRequest *request = [[CNContactFetchRequest alloc] initWithKeysToFetch:keys];
        
        [contactStore enumerateContactsWithFetchRequest:request error:nil usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
            
//            NSMutableDictionary *contactDic = [NSMutableDictionary dictionary];
            // 获取姓名
            NSString *lastName = contact.givenName;
            
//            [contactDic setValue:[PublicTool isNull:lastName]?@"":lastName forKey:@"name"];
            // 获取电话号码
            for (CNLabeledValue *labeledValue in contact.phoneNumbers){
                
                CNPhoneNumber *phoneValue = labeledValue.value;
                NSString *phoneNumber = phoneValue.stringValue;
                phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
                phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
                phoneNumber = [phoneNumber stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

                if (phoneNumber.length == 11) {
                    [contactArr addObject:phoneNumber];

//                    [contactDic setValue:phoneNumber forKey:@"phone"];
                    NSLog(@"name: %@   phone: %@",lastName,phoneNumber);

                    break;
                }
            }
            
        }];
        
    }else{
        // 1. 拿到通讯录
        ABAddressBookRef book = ABAddressBookCreateWithOptions(NULL, NULL);
        
        // 获取通讯录所有人
        CFArrayRef contants = ABAddressBookCopyArrayOfAllPeople(book);
        
        // 拿到通讯录中的某一个联系人
        for (NSInteger i = 0; i < CFArrayGetCount(contants); i++)
        {
            //获得People对象
            ABRecordRef person = CFArrayGetValueAtIndex(contants, i);
            
            CFTypeRef abName = ABRecordCopyValue(person, kABPersonFirstNameProperty);
            
            CFErrorRef error = NULL;
            NSString *nameString = (__bridge NSString *)abName;
            
            CFTypeRef abPhone = ABRecordCopyValue(person, kABPersonPhoneProperty);
            NSString *phoneString = (__bridge NSString*)abPhone;
            phoneString = [phoneString stringByReplacingOccurrencesOfString:@"-" withString:@""];
            phoneString = [phoneString stringByReplacingOccurrencesOfString:@" " withString:@""];
            phoneString = [phoneString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

//            NSMutableDictionary *contactDic = [NSMutableDictionary dictionary];
//            [contactDic setValue:[PublicTool isNull:nameString]?@"":nameString forKey:@"name"];
            if (phoneString.length == 11) {
                [contactArr addObject:phoneString];

//                [contactDic setValue:phoneString forKey:@"phone"];
                NSLog(@"name: %@   phone: %@",nameString,phoneString);
                break;
            }
            
//            if (![PublicTool isNull:contactDic[@"phone"]]) {
//                [contactArr addObject:contactDic];
//            }
            
            ABAddressBookRemoveRecord(book, person, &error);
            ABAddressBookSave(book,&error);

            if (abName) CFRelease(abName);
            if (person) CFRelease(person);
            
        }
    }
    
    return contactArr;
}


#pragma mark --企名片
+ (void)viewCaiwuDataWithIpo_type:(NSString*)ipo_type ipo_code:(NSString*)ipo_code{
    
    NSString *urlKey = @"";

    NSArray *hsArr = @[@"上证A股",@"深交所中小板",@"深交所主板",@"深交所创业板",@"上海证券交易所"];
    
    NSArray *sbArr = @[@"新三板",@"新三板已摘牌"];
    
    NSArray *hkArr = @[@"港股",@"香港交易所主板",@"香港交易所创业板"];
    
    NSArray *usaArr = @[@"美股",@"美交所",@"纽交所",@"纳斯达克"];
    
    if ([sbArr containsObject:ipo_type]) {
        //新三板
        urlKey = [NSString stringWithFormat:@"sb_%@",ipo_code];
        
    }else if([hsArr containsObject:ipo_type]){
        //A股
        urlKey = [NSString stringWithFormat:@"hs_%@",ipo_code];
        
    }else if ([hkArr containsObject:ipo_type]){
        //港股
        ipo_code = [ipo_code substringFromIndex:1];
        urlKey = [NSString stringWithFormat:@"hk_HK%@",ipo_code];
        
    }else if ([usaArr containsObject:ipo_type]){
        //美股
        urlKey = [NSString stringWithFormat:@"usa_%@",ipo_code];
        
    }else{
        
        [ShowInfo showInfoOnView:KEYWindow withInfo:@"暂无数据"];
        return;
    }
    URLModel *urlModel = [[URLModel alloc]init];
    urlModel.url = [NSString stringWithFormat:@"http://m.10jqka.com.cn/stockpage/%@/#&atab=finance",urlKey];
    NewsWebViewController *webView = [[NewsWebViewController alloc] initWithUrlModel:urlModel withAction:@""];
    [[PublicTool topViewController].navigationController pushViewController:webView animated:YES];
}

+ (void)contactKefu:(NSString*)title reply:(NSString*)replyText{
   
    if ([PublicTool isNull:title]) {
        [PublicTool contactUser:kDefaultWel];
        return;
    }

    //调到增辉客服
    EMMessage *message = [EaseSDKHelper getTextMessage:title to:QMPHelperUserCode messageType:EMChatTypeChat messageExt:@{@"userAvatar":[WechatUserInfo shared].headimgurl?:@"",@"userNick":[WechatUserInfo shared].nickname?:@""}];
    message.from = [WechatUserInfo shared].usercode;
    message.conversationId = QMPHelperUserCode;

    [[EMClient sharedClient].chatManager sendMessage:message progress:^(int progress) {

    } completion:^(EMMessage *message, EMError *error) {
        [PublicTool contactUser:replyText];
    }];
}

+ (void)contactKefuMSG:(NSString*)title reply:(NSString*)replyText delMsg:(BOOL)delMsg{
    if ([PublicTool isNull:title]) {
        [PublicTool contactUser:kDefaultWel];
        return;
    }
    
    //调到增辉客服
    EMMessage *message = [EaseSDKHelper getTextMessage:title to:QMPHelperUserCode messageType:EMChatTypeChat messageExt:@{@"userAvatar":[WechatUserInfo shared].headimgurl?:@"",@"userNick":[WechatUserInfo shared].nickname?:@"",SHOWINFO_MSG_KEY:@"1"}];
    message.from = [WechatUserInfo shared].usercode;
    message.conversationId = QMPHelperUserCode;
    
    [[EMClient sharedClient].chatManager sendMessage:message progress:^(int progress) {
        
    } completion:^(EMMessage *message, EMError *error) {
        if (delMsg) {
            EMConversation *conversation = [[EMClient sharedClient].chatManager getConversation:QMPHelperUserCode type:EMConversationTypeChat createIfNotExist:NO];
            [conversation deleteMessageWithId:message.messageId error:nil];
        }
        [PublicTool contactUser:replyText];
    }];
}

+ (void)contactUser:(NSString*)replyText{
    
    ChatViewController *chatVC = [[ChatViewController alloc]initWithConversationChatter:QMPHelperUserCode conversationType:EMConversationTypeChat];
    FriendModel *friend1 = [[FriendModel alloc]init];
    friend1.usercode = QMPHelperUserCode;
    friend1.headimgurl = kHeadImgUrl;
    friend1.nickname = kCustomerName;
    chatVC.chatFriendM = friend1;
    [[PublicTool topViewController].navigationController pushViewController:chatVC animated:YES];
    if (![PublicTool isNull:replyText]) {
        NSString *info = replyText;
        
        EMMessage *message = [EaseSDKHelper getTextMessage:info to:[WechatUserInfo shared].usercode messageType:EMChatTypeChat messageExt:@{@"userAvatar":kHeadImgUrl,@"userNick":kCustomerName}];
        message.from = QMPHelperUserCode;
        message.conversationId = QMPHelperUserCode;
        message.direction = EMMessageDirectionReceive;
        [[EMClient sharedClient].chatManager sendMessage:message progress:^(int progress) {
            
        } completion:^(EMMessage *message, EMError *error) {
            
        }];
    }
    
}

//获取截长图
+ (UIImage*)getLongCaptureImage:(UIScrollView*)scrollView{

    UIImage *image2 = [UIImage imageNamed:@"QuickMark"];
    CGFloat imgH = scrollView.contentSize.width/1125 *591;
    UIImageView *imgV = [[UIImageView alloc]initWithImage:image2];
    imgV.frame = CGRectMake(0, scrollView.contentSize.height, scrollView.width, imgH);
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(scrollView.contentSize.width, scrollView.contentSize.height + imgH), YES, [UIScreen mainScreen].scale);//100
    {
        CGPoint savedContentOffset = scrollView.contentOffset;
        CGRect savedFrame = scrollView.frame;
        
        scrollView.contentOffset = CGPointZero;
        scrollView.frame = CGRectMake(0, 0, scrollView.contentSize.width, scrollView.contentSize.height+imgH+2);
        [scrollView addSubview:imgV];
        [scrollView.layer renderInContext: UIGraphicsGetCurrentContext()];
        
        [imgV removeFromSuperview];
        scrollView.contentOffset = savedContentOffset;
        scrollView.frame = savedFrame;
    }
    
    
    UIImage *togetherImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return togetherImage;
}

//截屏
+ (UIImage*)getWindowCaptureImage{
    UIImage* image1 = nil;
    UIWindow *screenWindow = [UIApplication sharedApplication].delegate.window;
    CGFloat imgH = SCREENW/1125 *591;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(SCREENW, SCREENH + imgH), NO, 0.0);
    [screenWindow.layer renderInContext:UIGraphicsGetCurrentContext()];
    image1 = UIGraphicsGetImageFromCurrentImageContext();
    
    UIImage *image2 = [UIImage imageNamed:@"QuickMark"];
    [image2 drawInRect:CGRectMake(0, SCREENH, SCREENW, imgH)];//100
    UIImage *togetherImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return togetherImage;
    
}


/// 手机号未做校验，已弃用代码，现保留此处，供以前代码调用
+ (BOOL)isMobileNumber:(NSString *)mobileNum
{
    return YES;
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     * 联通：130,131,132,152,155,156,185,186
     * 电信：133,1349,153,180,189
     */
    if (mobileNum.length!=11) { //判断手机号
        return NO;
    }
    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    /**
     * 中国移动：China Mobile
     * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     */
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
    /**
     * 中国联通：China Unicom
     * 130,131,132,152,155,156,185,186
     */
    NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
    /**
     * 中国电信：China Telecom
     * 133,1349,153,180,189
     */
    NSString * CT = @"^1((33|53|8[09])[0-9]|349)\\d{7}$";
    /**
     * 大陆地区固话及小灵通
     * 区号：010,020,021,022,023,024,025,027,028,029
     * 号码：七位或八位
     */
    NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    NSPredicate *regextestphs = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", PHS];
    
    if (([regextestmobile evaluateWithObject:mobileNum] == YES)
        || ([regextestcm evaluateWithObject:mobileNum] == YES)
        || ([regextestct evaluateWithObject:mobileNum] == YES)
        || ([regextestcu evaluateWithObject:mobileNum] == YES)
        || ([regextestphs evaluateWithObject:mobileNum] == YES))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}
+ (SPPageMenu *)createCommonPageMenu {
    SPPageMenu *pageMenu = [SPPageMenu pageMenuWithFrame:CGRectMake(0, 0, SCREENW, kPageMenuH) trackerStyle:PageMenuTrackerStyle];
    pageMenu.itemTitleFont = PageMenuTitleFont;
    pageMenu.selectedItemTitleColor = PageMenuTitleUnSelectColor;
    pageMenu.unSelectedItemTitleColor = PageMenuTitleSelectColor;
    pageMenu.tracker.backgroundColor = PageMenuTrackerColor;
    return pageMenu;
}

//个人主页 和 人物详情页
+ (void)goPersonDetail:(id)personM{
    PersonModel *person = (PersonModel*)personM;
    if (![PublicTool isNull:person.personId]) {
        [[AppPageSkipTool shared] appPageSkipToPersonDetail:person.personId];
//
//        PersonDetailsController *personVC = [[PersonDetailsController alloc]init];
//        personVC.persionId = person.personId;
//        [[PublicTool topViewController].navigationController pushViewController:personVC animated:YES];
        
    }else if(![PublicTool isNull:person.unionid]){
        [[AppPageSkipTool shared] appPageSkipToUserDetail:person.unionid];
//
//        UnauthPeresonPageController *personVC = [[UnauthPeresonPageController alloc]init];
//        personVC.unionid = person.unionid;
//        [[PublicTool topViewController].navigationController pushViewController:personVC animated:YES];
    }
    
}

//模糊匹配  高亮显示
+ (NSMutableAttributedString *)createSearchKeyWord:(NSString *)keyWord originalString:(NSString *)oString withTextColor:(UIColor *)color keywordsColor:(UIColor *)keyColor{
    if([PublicTool isNull:oString]){
        return [[NSMutableAttributedString alloc]initWithString:@""];
    }
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:oString];
    [attributedString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0,oString.length)];
    NSMutableArray *keyWordArray2 = [NSMutableArray arrayWithCapacity:100];
    NSInteger strLength = [keyWord length];
    for (int i =0; i < strLength; i++) {
        [keyWordArray2 addObject:[keyWord substringWithRange:NSMakeRange(i, 1)]];
        
    }
    for (int i =0; i < [keyWordArray2 count] ; i++) {
        NSRange range = [[oString lowercaseString] rangeOfString:[[keyWordArray2 objectAtIndex:i] lowercaseString]];//判断字符串是否包含
        [attributedString addAttribute:NSForegroundColorAttributeName value:keyColor range:NSMakeRange(range.location,range.length)];
        
    }
    return attributedString;
}

#pragma mark --用户相关
+ (BOOL)userisCliamed{
    // 认证限制
    if ([WechatUserInfo shared].claim_type.integerValue == 1) {
        [PublicTool alertActionWithTitle:@"提示" message:@"您的认证信息正在审核中" btnTitle:@"我知道了" action:nil];
        return NO;
    }else if ([WechatUserInfo shared].claim_type.integerValue != 2) {
        [PublicTool alertActionWithTitle:@"提示" message:@"仅认证用户拥有此权限" leftTitle:@"确定" rightTitle:@"去认证" leftAction:^{
        } rightAction:^{
            [[AppPageSkipTool shared] appPageSkipToClaimPage];
        }];
        return NO;
    }
    return YES;
}

+ (BOOL)userisClaimInvestor{
    // 认证限制
    if ([WechatUserInfo shared].claim_type.integerValue == 1) {
        [PublicTool alertActionWithTitle:@"提示" message:@"您的认证信息正在审核中" btnTitle:@"我知道了" action:nil];
        return NO;
    }else if ([WechatUserInfo shared].claim_type.integerValue != 2) {
        [PublicTool alertActionWithTitle:@"提示" message:@"仅认证投资人和FA拥有此权限" leftTitle:@"确定" rightTitle:@"去认证" leftAction:^{
        } rightAction:^{
            [[AppPageSkipTool shared] appPageSkipToClaimPage];
        }];
        return NO;
    }
    //认证用户
    if (![[WechatUserInfo shared].person_role containsString:@"investor"] && ![[WechatUserInfo shared].person_role containsString:@"FA"]) { //非投资人
        [PublicTool alertActionWithTitle:@"提示" message:@"仅认证投资人和FA拥有此权限" btnTitle:@"确定" action:^{
            
        }];
        return NO;
    }
    
    return YES;
}

+ (NSString*)roleTextWithRequestStr:(NSString*)role{
    if ([PublicTool isNull:role]) {
        return @"";
    }
    NSArray *roleArr = @[role];
    if ([role containsString:@"|"]) {
        roleArr = [role componentsSeparatedByString:@"|"];
    }
    //角色 cyz => 创业者 ；investor => 投资人；FA => FA ；specialist =>专家 ；media =>媒体 ; other => 其他
    role = @"";
    NSDictionary *roleDic = @{@"investor":@"投资人",@"cyz":@"创业者",@"FA":@"FA",@"specialist":@"专家",@"media":@"媒体",@"other":@"其他"};
    for (NSString *roleStr in roleArr) {
        if ([roleDic.allKeys containsObject:roleStr]) {
            role = [NSString stringWithFormat:@"%@、%@",role,roleDic[roleStr]];
        }
    }
    if (role.length && [[role substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"、"]) {
        role = [role substringFromIndex:1];
    }
    return role;
}


@end
