//
//  Macro.h
//  qmp_ios
//
//  Created by QMP on 2017/8/29.
//  Copyright © 2017年 Molly. All rights reserved.
//

#ifndef Macro_h
#define Macro_h



#ifdef DEBUG
#define QMPLog(x, ...) NSLog(x, ##__VA_ARGS__);
#else
#define QMPLog(x, ...)
#endif

enum
{
    ResourceCacheMaxSize = 128<<20    /**< use at most 128M for resource cache */
    //pdf用
};

//融资日报
#define RONGZIXINWEN_BASE @"http://wx.qimingpian.com/cb/table.html"
//融资周报
#define RONGZIZHOUBAO_NEWS @"http://wx.qimingpian.com/cb/dailyrz.html?order=week"


//适配 iOS 11 
#define  adjustsScrollViewInsets_NO(scrollView,vc)\
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
if ([UIScrollView instancesRespondToSelector:NSSelectorFromString(@"setContentInsetAdjustmentBehavior:")]) {\
[scrollView   performSelector:NSSelectorFromString(@"setContentInsetAdjustmentBehavior:") withObject:@(2)];\
} else {\
vc.automaticallyAdjustsScrollViewInsets = NO;\
}\
_Pragma("clang diagnostic pop") \
} while (0)



#pragma mark --宏
typedef NS_ENUM(NSInteger,ShareType){
    ShareTypeWechatSession = 1,
    ShareTypeWechatTimeLine,
    ShareTypeWechatFavorite,
    ShareTypeSaveToLocal,
    ShareTypeCopyURL

};

typedef NS_ENUM(NSInteger,PersonRole){
    PersonRole_Investor = 1,
    PersonRole_Creator,
    PersonRole_Other
};


//关注页 类型
typedef NS_ENUM(NSInteger,DynamicPage) {
    DynamicPage_All = 1,
    DynamicPage_Pro,
    DynamicPage_Jigou,
    DynamicPage_Lingyu
};

// App内关注的主体  五种
typedef NS_ENUM(NSInteger,AttentType) {
    AttentType_Subject = 1,
    AttentType_Product,
    AttentType_Organization,
    AttentType_Person,
    AttentType_Hot
    
};

//动态推送的类型
typedef NS_ENUM(NSInteger,ActivityPushType) {
    ActivityPushType_Comment = 1,
    ActivityPushType_GiveCoin,
    ActivityPushType_AttentPerson,
    ActivityPushType_Like,
    ActivityPushType_CommentLike
};


typedef NS_ENUM(NSInteger, ActivityListViewControllerType) {
    ActivityListViewControllerTypePerson = 0,   ///< 人物
    ActivityListViewControllerTypeUser,         ///< 用户
    ActivityListViewControllerTypeProduct,      ///< 项目
    ActivityListViewControllerTypeOrgnize,      ///< 机构
    
};

//通讯录 名片
typedef NS_ENUM(NSInteger, CardStyleFrom){
    CardStyleFromUpload, //上传
    CardStyleFromEntrust, //委托
    CardStyleFromExchange //交换的名片
};


#pragma mark --静态变量

static CGFloat MenuHeight = 0;

static CGFloat kHeaderViewH = 0;

static CGFloat kNewsMenuHeight = 0;
static CGFloat kNewsMenuHeaderVwH = 0;


#pragma mark --PDF_LIST

#define TABLENAME_DOWNLOADPDFLIST  @"downloadpdflist" //存储下载的pdf表


//系统主要颜色
#define NV_BACK_COLOR         [UIColor WhiteColor]

#define RED_BG_COLOR           HTColorFromRGB(0xea4756)
#define RED_TEXTCOLOR         HTColorFromRGB(0xea4756)
#define RED_LIGHT_COLOR       HTColorFromRGB(0xFFF4F5)
#define RED_DARKCOLOR         HTColorFromRGB(0xD0021B) //主题色

#define NV_TITLE_COLOR        HTColorFromRGB(0x1d1d1d)
#define NV_OTHERTITLE_COLOR   HTColorFromRGB(0x555555)
#define TABLEVIEW_COLOR       HTColorFromRGB(0xF8F8F8)
#define LINE_COLOR            HTColorFromRGB(0xd2d2d2)
#define LIST_LINE_COLOR       HTColorFromRGB(0xF5F5F5) //灰色
#define F5COLOR               HTColorFromRGB(0xf5f5f5) //灰色

#define BORDER_LINE_COLOR     HTColorFromRGB(0xf0f0f0)

#define NAVCOLOR            RGBa(227,62,55,1)
#define RGBblackColor       RGBa(65, 59, 59, 1)
#define RGBBlueColor        BLUE_BG_COLOR
#define BLUE_DARK_COLOR     HTColorFromRGB(0x1566B1)
#define BLUE_BG_COLOR       HTColorFromRGB(0x006EDA)
#define BLUE_LIGHT_COLOR    [HTColorFromRGB(0x006EDA) colorWithAlphaComponent:0.08]
#define BLUE_TITLE_COLOR    HTColorFromRGB(0x006EDA)
#define BLUE_BRIGHT_COLOR   HTColorFromRGB(0x0D7DFF)
#define LABEL_BG_COLOR      HTColorFromRGB_Alpha(0x179CD8,0.11)
#define YELLOW_COLOR        HTColorFromRGB(0xFA8858)

#define RGBLineGray         LINE_COLOR
#define RGBTableViewBackgroud RGBa(240,239,245,1)
#define COLOR2D343A         HTColorFromRGB(0x2D343A)
#define COLOR8C909B         HTColorFromRGB(0x8C909B)
#define COLOR737782         HTColorFromRGB(0x737782)
#define H3COLOR             HTColorFromRGB(0x333333)
#define H2COLOR             HTColorFromRGB(0x222222)
#define H4COLOR             HTColorFromRGB(0x444444)
#define H5COLOR             HTColorFromRGB(0x555555)
#define H80COLOR            HTColorFromRGB(0x808080)
#define HCCOLOR             HTColorFromRGB(0xCCCCCC)
#define H9COLOR             HTColorFromRGB(0x9197A1)
#define H999999             HTColorFromRGB(0x999999)
#define H6COLOR             HTColorFromRGB(0x666666)
#define H27COLOR            HTColorFromRGB(0x272727)
#define PINKCOLOR           HTColorFromRGB(0xFFF7F7)
#define H568COLOR           HTColorFromRGB(0xF5F6F8)
#define HEEECOLOR           HTColorFromRGB(0xeeeeee)



#define PageMenuTitleSelectColor   BLUE_TITLE_COLOR
#define PageMenuTitleUnSelectColor HTColorFromRGB(0x444444)
#define PageMenuTitleFont          [UIFont systemFontOfSize:15]
#define PageMenuTrackerStyle       SPPageMenuTrackerStyleLineAttachment
#define PageMenuTrackerColor       HTColorFromRGB(0x006EDA)
#define kPageMenuH                 44

//导航栏value
#define LEFTBUTTONFRAME CGRectMake(0, 0, 44, 44)
#define RIGHTBARBTNFRAME CGRectMake(0, 0, 44, 44)

#define LEFTNVSPACE -17
#define RIGHTNVSPACE -15

//版本
#define VERSION [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]
#define VERSIONBUILD [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]

#define SCREENW [UIScreen mainScreen].bounds.size.width//屏幕宽度
#define SCREENH [UIScreen mainScreen].bounds.size.height
#define VIEWW self.view.frame.size.width
#define VIEWH self.view.frame.size.height
#define RGB(r,g,b,a) [UIColor colorWithRed:r / 255.0 green:g / 255.0 blue:b / 255.0 alpha:a]
#define RGBa(r,g,b,a) [UIColor colorWithRed:r / 255.0 green:g / 255.0 blue:b / 255.0 alpha:a]

#define HTColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define HTColorFromRGB_Alpha(rgbValue,alphaValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:alphaValue]

//获取系统版本

#define KEYWindow [UIApplication sharedApplication].keyWindow



#pragma mark - 设备信息
#define IOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]
#define iOS8_OR_HIGHER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8)
#define iOS9_OR_HIGHER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9)
#define iOS10_OR_HIGHER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10)
#define iOS8_Lower ([[[UIDevice currentDevice] systemVersion] floatValue] < 8)
#define iOS11_OR_HIGHER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 11)
//#define iOS7Later ([UIDevice currentDevice].systemVersion.floatValue >= 7.0f)
//#define iOS8Later ([UIDevice currentDevice].systemVersion.floatValue >= 8.0f)
//#define iOS9Later ([UIDevice currentDevice].systemVersion.floatValue >= 9.0f)
//#define iOS9_1Later ([UIDevice currentDevice].systemVersion.floatValue >= 9.1f)

#define isRetina ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhone6 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhone6P ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(828, 1472), [[UIScreen mainScreen] currentMode].size) : NO)

#define isSimulator (NSNotFound != [[[UIDevice currentDevice] model] rangeOfString:@"Simulator"].location)

#define iOS_Version [UIDevice currentDevice].systemVersion
#define isFisrtLaunch [[NSUserDefaults standardUserDefaults] boolForKey:@"alreadyFirstLaunch"]
#define isQPOSUser !IS_NULL_STRING([QFUser shared].session)

#define AppVersionShort [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]
#define AppVersionBuild [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]
#define AppVersion      [NSString stringWithFormat:@"%@.%@",AppVersionShort,AppVersionBuild]

#define Device  (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)?@"iPad":@"iPhone"

#define iPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define isiPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)

//系统对象
#define kAppdelegate [[UIApplication sharedApplication]delegate]


//参考的屏幕宽度和高度 - 适配尺寸
#define referenceBoundsHeight 667.0
#define referenceBoundsWight 375.0

#define ratioHeight SCREENH/referenceBoundsHeight
#define ratioWidth  SCREENW/referenceBoundsWight

#define kStatusBarHeight [[UIApplication sharedApplication] statusBarFrame].size.height
#define kNavigationBarHeight 44.0f
#define kScreenTopHeight (kStatusBarHeight+kNavigationBarHeight)
#define kScreenBottomHeight (isiPhoneX ? 83 : 49)
#define kShortBottomHeight 49
#define KSafeHeightBottom 43
#define kLeftSpaceWidth 13.f

#define CurrentLanguage ([[NSLocale preferredLanguages] objectAtIndex:0])

//文件
#define USER_DEFAULTS [NSUserDefaults standardUserDefaults]
#define DocumentDirectory NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject

// 文案
#define REQUEST_ERROR_TITLE    @"操作失败，请重试"
#define REQUEST_ERROR_NETWORK  @"网络加载失败,请点击屏幕重试"
#define REQUEST_SEARCH_NULL    @"暂无结果，换个词试试吧"
#define REQUEST_FILTER_NULL    @"暂时没有您要找的内容"
#define REQUEST_DATA_NULL      @"暂无数据"


#define RANDOM_COLORARR @[HTColorFromRGB(0xedd794),HTColorFromRGB(0xceaf96),HTColorFromRGB(0xa1dae5),HTColorFromRGB(0xeea8a8),HTColorFromRGB(0x8cceb9),HTColorFromRGB(0xa7c6f2)]

#define MESSAGE_FRIENDALERT  @"非好友关系，一方未回复之前另一方只能发送5条消息。"
#define MESSAGE_BEFRIEND     @"你们的交换联系方式已经完成"
#define MESSAGE_REJECTRECEIVE   @"您已拒绝接收对方的任何消息"
#define MESSAGE_REMOVEREJECT   @"您已解除对对方的屏蔽"
#define MESSAGE_REJECTED      @"对方已拒绝接受您的消息"

//FLag
#define LOGIN_WECHAT_CLICK      @"clickWechatLogin"
#define APPVERSION_CHECKSTATUS  @"isCheckAppStore"
#define LOGINLEADER_HAVEATTENT  @"loginLeader_haveAttent"


//图片
#define IMAGE_DATA_NULL    @"viewIcon_noData"
#define IMAGE_NONETWORK    @"viewIcon_noNetwork"

//通知
#define NOTIFI_STATUSBAR_REFRESH       @"refreshStatusBar"
#define NOTIFI_TABBARCLICK             @"tabbarClick"
#define NOTIFI_LOGIN                   @"isLogin"
#define NOTIFI_QUITLOGIN               @"quitLogin"
#define NOTIFI_LINGYUREFRESH           @"lingyu_attent_change"     //关注的领域设置
#define NOTIFI_COUNTRYFILTER_REFRESH   @"filter_country"  //国内外筛选条件刷新
#define NOTIFI_PRODUCTFILTER_REFRESH   @"filter_product"  //推荐筛选条件刷新

#define NOTIFI_PDFDOWNSUCCESS          @"downloadPdfSuccess"     //pdf下载成功
#define NOTIFI_PDFDOWNFAIL             @"downloadPdfFail"     //pdf下载失败
#define NOTIFI_HANDLEUPLOAD            @"fromwx_upload"     //从微信返回打开pdf上传
#define NOTIFI_ACTCOMMENTDEL           @"activityComment_del" //动态删除评论


#define isEditedMyInfo [NSString stringWithFormat:@"%@WriteIsFirstInfo",[WechatUserInfo shared].unionid]

#endif /* Macro_h */
