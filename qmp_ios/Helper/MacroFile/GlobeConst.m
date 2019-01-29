//
//  GlobeConst.m
//  qmp_ios
//
//  Created by molly on 2017/4/27.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "GlobeConst.h"

@implementation GlobeConst

NSString * const PTYPE = @"qmp_ios";
NSString * const TELE = @"qimingpian01";
NSString * const EMAIL = @"service@qimingpian.com";
//页面来源  公司公告和行研报告
NSString * const GSGG = @"gongsigonggao";
NSString * const HYBG = @"hangyanbaogao";
NSString * const ZGS  = @"zhaogushu";
NSString * const BP   = @"bp";

NSString * const PDFFWX = @"pdfCopyFromWx";
NSString * const PDFCOLLECT = @"pdfFromCollectList";
NSString * const PDFFURL = @"pdfFromUrl";
NSString * const PDFTABLENAME = @"downloadpdflist";


NSString * const APPKEY = @"2584608c485b84117618154c17cb5a28"; //版本>=2.2.3使用

//#ifdef  QMP_PRO
#pragma mark --第三方配置参数

//全局的宏定义
NSString * const kWXAPP_ID = @"wxdc126215fc09c859"
NSString * const BUGLY_APP_ID = @"i1400015713";//腾讯bugly


NSString * const UMENG_SHARE_APPKEY = @"571b71e9e0f55ae9e8000db6";

NSString * const EaseMobAppKey = @"1159171128178788#qmpapp"; //环信
//极光KEY
NSString * const JIGUANG_APPKEY = @"4d77430fcc5476bf0382ea7e";

//AppStore URL
NSString * const APPSTORE = @"https://itunes.apple.com/cn/app/id1103060310?mt=8";

//判断app需不需要更新
NSString * const UPDATEAPP = @"http://ios1.api.qimingpian.com/d/iosversionupdate";



//通用反馈接口
NSString * const GENERAL_FEEDBACK = @"http://ios1.api.qimingpian.com/h/editcommonfeedback";

NSString * const JGICON_DEFAULT = @"jigou_default";
NSString * const JGICON_DEFAULTURL = @"http://ios1.api.qimingpian.com/Public/images/jigou_default.png";

NSString * const COMICON_DEFAULT = @"logo_default";
NSString * const COMICON_DEFAULTURL = @"http://ios1.api.qimingpian.com/Public/images/logo_default.png";

NSString * const PROICON_DEFAULT = @"product_default";
NSString * const PROICON_DEFAULTURL = @"http://ios1.api.qimingpian.com/Public/images/product_default.png";

@end
