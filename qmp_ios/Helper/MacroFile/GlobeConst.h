//
//  GlobeConst.h
//  qmp_ios
//
//  Created by molly on 2017/4/27.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GlobeConst : NSObject

extern NSString * const PTYPE;
extern NSString * const TELE;
extern NSString * const EMAIL;
extern NSString * const GSGG;
extern NSString * const HYBG;
extern NSString * const BP;
extern NSString * const ZGS;
extern NSString * const PDFFWX;
extern NSString * const PDFCOLLECT;
extern NSString * const PDFFURL;
extern NSString * const PDFTABLENAME;
//全局的宏定义
extern NSString * const APPKEY;//版本>=2.2.3使用

// @"407c6629f7695adfc4cf1350a55ea710" 版本>=2.2.3便停用它

extern NSString * const kWXAPP_ID;//微信

extern NSString * const BUGLY_APP_ID;//腾讯bugly


extern NSString * const UMENG_SHARE_APPKEY;

extern NSString * const EaseMobAppKey; //环信


//我的->关于我们(企名片)详情 unionid
//extern NSString * const ABOUT_UNIONID;

//AppStore URL
extern NSString * const APPSTORE;
//判断app需不需要更新
extern NSString * const UPDATEAPP;

//通用反馈接口
extern NSString * const GENERAL_FEEDBACK;

extern NSString * const JGICON_DEFAULT;
extern NSString * const JGICON_DEFAULTURL;

extern NSString * const COMICON_DEFAULT;
extern NSString * const COMICON_DEFAULTURL;

extern NSString * const PROICON_DEFAULT;
extern NSString * const PROICON_DEFAULTURL;
extern NSString * const JIGUANG_APPKEY;

@end
