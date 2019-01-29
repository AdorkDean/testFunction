//
//  ActivityModel.h
//  qmp_ios
//
//  Created by QMP on 2018/6/30.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ActivityHtmlMedia;
@interface ActivityLinkModel : NSObject
@property (nonatomic, strong) NSString *linkUrl;
@property (nonatomic, strong) NSString *linkImage;
@property (nonatomic, strong) NSString *linkTitle;
@end

@interface ActivityRelateModel : NSObject
@property (nonatomic, strong) NSString *type; ///< product, jigou, person, theme, user
@property (nonatomic, strong) NSString *image;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *route;  ///< 跳转需要的信息

@property (nonatomic, strong) NSString *ID;          ///< 同 ticketID(ticket 加密)
@property (nonatomic, strong) NSString *ticket;      ///< ticket
@property (nonatomic, strong) NSString *ticketID;    ///< ticket 加密
@property (nonatomic, strong) NSString *projectID;   ///< 真实的 id ??

@property (nonatomic, strong) NSString *uID;   ///< unionid
@property (nonatomic, strong) NSString *uuID;  ///< uuid

@property (nonatomic, assign) BOOL isFollowed;
@property (nonatomic, assign) BOOL isAuthor;  ///< 是否是发布者
@property (nonatomic, strong) NSString *claim_type;
@property (nonatomic, strong) NSString *userType; ///< person or user

@property (nonatomic, strong) NSString *qmpIcon;
@property (nonatomic, strong) NSString *desc;
@property (nonatomic, strong) NSString *yewu;
@property (nonatomic, strong) NSString *lunci;
@end

@interface ActivityUserModel : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *ID;
@property (nonatomic, strong) NSString *uID;
@property (nonatomic, strong) NSString *uuID;
@property (nonatomic, strong) NSString *avatar;
@property (nonatomic, strong) NSString *company;
@property (nonatomic, strong) NSString *position;
@property (nonatomic, strong) NSString *type;  ///< 1: 用户, 2: 官方账号  ///< comment -> user/person
@property (nonatomic, strong) NSString *desc;
@property (nonatomic, strong) NSString *usercode;
@property (nonatomic, assign) BOOL isFollowed;
@end

@interface ActivityImageModel : NSObject
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *smallUrl; //列表
@property (nonatomic, strong) NSString *squareUrl; //放大
@end

@interface ActivityCompanyModel : NSObject
@property (nonatomic, strong) NSString *company;
@property (nonatomic, strong) NSString *role;
@property (nonatomic, strong) NSString *position;  // zhiwu
@end

@interface ActivityModel : NSObject

@property (nonatomic, strong) NSString *act_id; ///< 真实的 id md5
@property (nonatomic, strong) NSString *ticket;
@property (nonatomic, strong) NSString *ID;       ///< ticket md5
@property (nonatomic, strong) NSString *ticketID; ///< ticket md5

@property (nonatomic, assign, getter=isDigged) BOOL digged;
@property (nonatomic, assign) NSInteger diggCount;
@property (nonatomic, assign) NSInteger commentCount;
@property (nonatomic, assign) NSInteger coinCount;

@property (nonatomic, assign, getter=isCollected) BOOL collected;
@property (nonatomic, assign, getter=isBuried) BOOL buried;
@property (nonatomic, assign, getter=isReported) BOOL reported;

@property (nonatomic, assign, getter=isToped) BOOL toped;
@property (nonatomic, assign, getter=isAnonymous) BOOL anonymous;
@property (nonatomic, copy) NSString * anonymous_degree;

@property (nonatomic, assign) BOOL showCompany;

@property (nonatomic, assign) BOOL isMine;

@property (nonatomic, strong) ActivityLinkModel *linkInfo;

@property (nonatomic, strong) ActivityUserModel *user;
@property (nonatomic, strong) ActivityCompanyModel *company;

@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *comment_html;
@property (nonatomic, strong) ActivityHtmlMedia *htmlMedia;

@property (nonatomic, strong) NSArray *images;

@property (nonatomic, strong) NSString *createTime;

@property (nonatomic, strong) NSArray *relateProducts;
@property (nonatomic, strong) NSArray *relateThemes;
@property (nonatomic, strong) NSArray *relatePersons;
@property (nonatomic, strong) NSArray *relateOrganizations;
@property (nonatomic, strong) ActivityRelateModel *authRelate; ///< 发布者以关联对象方式显示

@property (nonatomic, strong) NSMutableArray *relates;
@property (nonatomic, strong) NSArray *followRelates;  ///< 关注的 关联对象
@property (nonatomic, strong) ActivityRelateModel *headerRelate;  ///< 头部显示的对象

@property (nonatomic, assign) BOOL homeFollow;  // 列表页
@property (nonatomic, assign) BOOL note;  // 笔记
@property (nonatomic, assign) BOOL showEdit;  //是否展示编辑按钮
@property (nonatomic, assign) BOOL editing;


+ (ActivityModel *)activityModelWithDict:(NSDictionary *)dict;
/** 关注列表*/
+ (ActivityModel *)homeFollowVcModelWithDict:(NSDictionary *)dict;
/** 主题动态*/
+ (ActivityModel *)themeVcModelWithDict:(NSDictionary *)dict;
/** 圈子列表*/
+ (ActivityModel *)squareVCModelWithDict:(NSDictionary *)dict;

/** fixRealte：详情页header和列表页一致的需要，需要一致传入列表中的headerRelate */
+ (ActivityModel *)detailVCModelWithDict:(NSDictionary *)dict fixRealte:(ActivityRelateModel *)r;

/** 动态列表*/
+ (ActivityModel *)squareVCModelWithDict:(NSDictionary *)dict anonymous:(NSInteger)anonymous;

/**人物 动态列表*/
+ (ActivityModel *)personVCactivityModelWithDict:(NSDictionary *)dict ticket:(NSString *)t;

/**项目机构 动态列表*/
+ (ActivityModel *)activityModelWithDict:(NSDictionary *)dict forId:(NSString *)idd;

- (void)updateCountWithNew:(ActivityModel *)newActivity;
+ (ActivityUserModel *)userModelWithUserInfo:(NSDictionary *)dict;
+ (ActivityRelateModel *)relateModelWithProjectInfo:(NSDictionary *)dict;
+ (ActivityUserModel *)userModelWithDict:(NSDictionary *)dict;

@end




@interface ActivityModel (Detial)
//笔记在用
+ (ActivityModel *)detialVcModelWithDict:(NSDictionary *)dict;
@end

