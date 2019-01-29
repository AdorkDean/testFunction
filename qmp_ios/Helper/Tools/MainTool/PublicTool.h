//
//  PublicTool.h
//  BSOrange
//
//  Created by kenshin on 14-9-1.
//  Copyright (c) 2014年 BazzarEntertainment. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MBProgressHUD.h>
#import "FriendModel.h"
#import <objc/runtime.h>


@interface PublicTool : NSObject



#pragma mark --MBProgressHUD
+ (MBProgressHUD*)showHudWithView:(UIView*)view;
+ (MBProgressHUD*)showLoadingHUDWithTitle:(NSString*)title view:(UIView*)view;

+ (void)dismissHud:(UIView*)view;
+ (void)showNetWorkErrorInView:(UIView *)view;
+ (void)showMsg:(NSString *)msg;
+ (void)showError:(NSString*)msg;
+ (void)showSuccess:(NSString*)msg;
+ (void)showMsg:(NSString *)msg delay:(CGFloat)delay;

//view 的消失动画
+ (void)showFadeAnimation:(UIView *)view;

#pragma mark --字符串
+ (BOOL)isPureLetters:(NSString*)str;
/**
 空字符串返回 -
 */
+ (NSString*)nilStringReturn:(NSString*)str;

/**
 判空 -
 */
+ (BOOL)isNull:(NSString*)string;


+ (CGFloat)widthOfString:(NSString*)string height:(CGFloat)height fontSize:(CGFloat)fontSize;

+ (CGFloat)heightOfString:(NSString*)string width:(CGFloat)width font:(UIFont*)font;

+ (NSAttributedString *)attributedStringWithHTMLString:(NSString *)htmlString;

+ (NSString *)strConverterFloatK:(NSString *)title;
//URLEncode
+(NSString*)encodeString:(NSString*)unencodedString;
//URLDEcode
+(NSString *)decodeString:(NSString*)encodedString;
//去除特殊字符
+(NSString*)filterSpecialString:(NSString*)originStr;
/** 是否包含中文*/
+ (BOOL)checkIsChinese:(NSString *)string;
#pragma mark --图片相关
//截取图片
+ (UIImage*)screenshotWithView:(UIView*)view  size:(CGSize)size;
+ (UIImage*)screenshotWithView:(UIView*)view size:(CGSize)size addBottomImage:(UIImage*)bottomImg;

/**
  收藏的url的增和删
 */
+ (void)storeShortUrlToLocal:(NSString *)urlStr;
+ (void)deleteShortUrlToLocal:(NSString *)urlStr;

/**
 *  统计字符串长度（同新浪微博,ASCII和Unicode混合）
 *
 *  @return 长度
 */
+ (NSInteger)unicodeLengthOfString:(NSString *)text;
+ (NSString *)getUniqueString;

#pragma mark --日期相关
+ (NSString*)currentYear;
+ (NSString*)currentDay;
+ (NSString*)yesToday;
+ (NSString *)getNowTimeStamp;
+ (NSString *)currentDateTime;
+ (NSString *)dateTimeYMD:(int)seconds;
+ (NSString *)dateTimeYMD_CH:(int)seconds;
+ (NSString *)dateTimeYMDHMS:(int)seconds;
+ (NSDate *)dateFromString:(NSString *)dateString;
+(NSDate *)dateFromString:(NSString *)dateString formatter:(NSDateFormatter*)formatter;
///将 年月日时分秒 转换为 时间戳  yyyy-MM-dd HH:mm:ss HH表示24小时制，hh表示12小时制
+ (NSString *)getTimeStamp:(NSString *)dataString withFormate:(NSString *)dataFormate;

// 2017-09-29 18:30:33  -> 今天 昨天  . .   . . .
+ (NSString*)dateString:(NSString*)originStr;

// 2017-09-29 18:30:33  -> 09:45  9-10 2018-09-10 . .   . . .
+ (NSString*)dateOfTimeString:(NSString*)originStr;

//2017.9.29 -> 2017.09.29
+ (NSString*)fullDateStringWithYMRString:(NSString*)shortString;


/**
 *  添加目录为iCloud备份忽略路径，Document里非用户明确生成&|大量不定期数据生成的路径需要如此添加为iCloud忽略路径
 *
 *  @param URL 文件路径
 *
 *  @return 成功/失败
 */
+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL;

#pragma mark --视图相关
/*
 *以中心点为基准放大或缩小frame
 *@param frame 原frame
 *@param times 放大倍数
 */

+(CGRect)amplifyFrame:(CGRect)frame times:(CGFloat)times;


+ (UIImage *)roundImage:(UIImage *)image bounds:(CGRect)bounds;
+ (UIImage *)compressImage:(UIImage *)image toByte:(NSUInteger)maxLength;
+(UIImage*) OriginImage:(UIImage *)image scaleToSize:(CGSize)size;

/**
 *  保存图片到相册
 *
 *  @param image   图片
 *  @param success 成功回调
 *  @param failure 失败回调
 */
//+ (void)saveImageToAppAlbum:(UIImage*)image success:(void (^)(void))success failure:(void (^)(NSError *error))failure;

+(void)shareImage:(UIImage*)image InController:(UIViewController*)controller success:(void (^)(void))success failure:(void (^)(NSError* error))failure;
//存到本地 回调图片名称和存储地址
+(void)saveImageToLocal:(UIImage*)image finishedBlock:(void(^)(NSString *imageName,NSString *imagePath))finished;

//邮箱格式
+ (BOOL)checkEmail:( NSString  *)email;

//检查电话号码和密码
+(BOOL)checkVerifyCode:(NSString*)verifyCode;
+(BOOL)checkTel:(NSString *)str;
/// 手机号和固话检测
+ (BOOL)checkIsTel:(NSString *)telStr;
/// 手机号未做校验，弃用代码，现保留此处
+ (BOOL)isMobileNumber:(NSString *)mobileNum;

+ (BOOL)checkTel:(NSString *)str andPwd:(NSString*)pwd;
+ (void)makeACall:(NSString*)phoneNum;
+ (void)sendEmail:(NSString*)email;
+ (void)CheckAddressBookAuthorization:(void (^)(bool isAuthorized , bool isUp_ios_9))block;

#pragma mark ---工具

+ (BOOL)isMsgActivityShow;


+(void)setLabel:(UILabel *)label color:(UIColor *)color string:(NSString *)str font:(UIFont *)font withLineSpacing:(CGFloat)space;

//斜体字
+ (UIFont *)makeFontItalic:(UIFont *)font radio:(CGFloat)radio;

+ (UIImage *)imageWithName:(NSString *)imageName;

//* 获取目前的控制器*/
+(UIViewController *)getCurrentVC;

+(UIViewController*)topViewController;

/**
 *  相机 相册权限
 */
+ (BOOL)isCameraAvailable;
+ (BOOL)isAlbumAvailable;

/*
  用户版本 与 appstore版本相差几个版本
 */
+ (NSInteger)userAppVersionToAppStore;


#pragma mark  ---文件处理
+ (void)deleteFileForPath:(NSString*)path;

/** 返回键盘视图*/
+ (UIView *)findKeyboard;

//从detail url中获取跳转参数
+ (NSMutableDictionary *)toGetDictFromStr:(NSString *)tempStr;
/** 是否全为数字 */
+ (BOOL)isNum:(NSString *)checkedNumString;

//获取拼音首字母(传入汉字字符串, 返回大写拼音首字母)
+ (NSString *)firstCharactor:(NSString *)aString;

+ (NSArray*)rangeOfSubString:(NSString*)subStr inString:(NSString*)string;
+ (NSArray*)noDifferenceUporLowRangeOfSubString:(NSString*)subStr inString:(NSString*)string;
#pragma mark  --好友信息
+ (void)saveFriendInfo:(NSArray*)friendArr;
+ (FriendModel*)friendForUsercode:(NSString*)usercode;


//判断对象是否有某个属性
+ (BOOL)haveProperty:(NSString*)property class:(id)object;

// alert提示
+ (void)alertActionWithTitle:(NSString*)title message:(NSString*)message cancleAction:(void (^)(void))cancleAction sureAction:(void(^)(void)) sureAction;

+ (void)alertActionWithTitle:(NSString*)title message:(NSString*)message leftTitle:(NSString*)leftTitle rightTitle:(NSString*)rightTitle  leftAction:(void (^)(void))cancleAction rightAction:(void (^)(void)) sureAction;

+ (void)alertActionWithTitle:(NSString*)title message:(NSString*)message leftTitle:(NSString*)leftTitle rightTitle:(NSString*)rightTitle  leftActionClick:(void (^)(void))cancleAction rightActionClick:(void (^)(void)) sureAction leftEnable:(BOOL)leftEnable rightEnable:(BOOL)rightEnable;

+ (void)alertActionWithTitle:(NSString*)title message:(NSString*)message btnTitle:(NSString*)btnTitle  action:(void (^)(void)) sureAction;
/*
 系统 左右弹窗（左边：取消 右边：defalut） 无刷新状态栏
 */
+ (void)alertVCWithTitle:(NSString *)title message:(NSString *)message defaultTitle:(NSString *)defaultTitle defaultAction:(void (^)(void))defaultBlock cancelTitle:(NSString *)cancelTitle cancelAction:(void (^)(void))cancelBlock;

+ (void)enterSystemContactAlbum; //系统通讯录

+ (NSMutableArray *)getAllContact; //返回通讯录 姓名和电话


// 财务数据 查看
+ (void)viewCaiwuDataWithIpo_type:(NSString*)ipo_type ipo_code:(NSString*)ipo_code;

#pragma mark --客服--
+ (void)contactKefu:(NSString*)title reply:(NSString*)replyText;
+ (void)contactKefuMSG:(NSString*)title reply:(NSString*)replyText delMsg:(BOOL)delMsg;

//获取截长图
+ (UIImage*)getLongCaptureImage:(UIScrollView*)scrollView;
//截屏
+ (UIImage*)getWindowCaptureImage;

//系统权限未打开提示
+ (void)showAlert:(NSString *)title message:(NSString *)message;

#pragma mark --通讯录
+ (void)savePeopleToContactForCardItem:(id)cardItemM;
+ (BOOL)isNewContact:(NSString*)phone;
+ (void)savePhone:(NSString*)phone;
+ (void)dealPhone:(NSString*)phone;
+ (void)dealWechat:(NSString*)wechat;
+ (void)dealEmail:(NSString*)email;

+ (void)dealPhone:(NSString*)phone message:(NSString*)msg;
+ (void)dealWechat:(NSString*)wechat message:(NSString*)msg;
+ (void)dealEmail:(NSString*)email message:(NSString*)msg;


#warning --跳转尽量移到AppPageSkipTool
//个人主页 和 人物详情页
+ (void)goPersonDetail:(id)person;

+ (void)enterDetail:(NSString*)urlStr;

+ (void)enterActivityListControllerWithID:(NSString *)ID type:(NSInteger)theType;

+ (void)enterOfficinalPage:(NSString*)ID  ticket:(NSString*)ticket;

+ (void)enterActivityListControllerWithID:(NSString *)ID type:(NSInteger)theType model:(id)aModel refresh:(void(^)(void))refreshBlock;
+ (void)enterActivityListControllerWithTicket:(NSString *)ticket type:(NSInteger)theType model:(id)aModel refresh:(void(^)(void))refreshBlock;
//模糊匹配  高亮显示
+ (NSMutableAttributedString *)createSearchKeyWord:(NSString *)keyWord originalString:(NSString *)oString withTextColor:(UIColor *)color keywordsColor:(UIColor *)keyColor;
//+ (void)enterPostActivity:(NSString*)url;


#pragma mark --用户相关
+ (BOOL)userisCliamed;
+ (BOOL)userisClaimInvestor;
+ (NSString*)roleTextWithRequestStr:(NSString*)role;

@end
