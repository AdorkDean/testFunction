//
//  ActivityLayout.h
//  qmp_ios
//
//  Created by QMP on 2018/6/28.
//  Copyright © 2018年 Molly. All rights reserved.
//详情页动态的layout

#import <Foundation/Foundation.h>

extern const CGFloat ActivityCellAvatarWH;
extern const CGFloat ActivityCellPaddingLR;
extern const CGFloat ActivityCellAvatarT;
extern const CGFloat ActivityCellNameL;
extern const CGFloat ActivityCellVerticalMargin;
extern const CGFloat ActivityCellHorizontalMargin;
extern const CGFloat ActivityCellTextT;
extern const CGFloat ActivityCellHeaderH;

extern const CGFloat ActivityCellTextFontSize;
extern const CGFloat ActivityCellLinkHeight;
extern const CGFloat ActivityCellBarHeight;
extern const CGFloat ActivityCellCompanyHeight;
extern const CGFloat ActivityCellPhotosT;
extern const CGFloat ActivityCellLinkInfoT;


typedef NS_ENUM(NSInteger, ActivityLayoutType) {
    ActivityLayoutTypePerson = 0,
    ActivityLayoutTypeCompany,
    ActivityLayoutTypeCompanyValue
};

@class YYTextLayout, ActivityModel;
@interface ActivityLayout : NSObject
+ (ActivityLayout *)activityLayoutWithActivity:(NSDictionary *)dict;
- (instancetype)initActivityLayoutWithActivity:(NSDictionary *)dict;
+ (ActivityLayout *)layoutWithActivityModel:(ActivityModel *)model;

- (void)layout;
- (ActivityLayout *)reLayoutForDetail;
- (ActivityLayout *)reLayoutForShare;

@property (nonatomic, assign) BOOL share;   ///< 分享页布局（不需要做重用处理）
@property (nonatomic, assign) BOOL detail;  ///< 详情页布局（不需要做重用处理）
@property (nonatomic, assign) BOOL isNote;  ///< 私人笔记布局
@property (nonatomic, strong) NSDictionary *activity;
@property (nonatomic, strong) ActivityModel *activityModel;

@property (nonatomic, assign) CGFloat cellHeight;

@property (nonatomic, assign) CGFloat centerHeight;
@property (nonatomic, strong) YYTextLayout *textLayout;
@property (nonatomic, strong) NSArray *matchArr;

@property (nonatomic, strong) NSArray *showRelates;
@property (nonatomic, assign) CGFloat detailRelateHeight;
@property (nonatomic, strong) NSArray *detailRelateFrames;

@property (nonatomic, assign) CGFloat imageTop;
@property (nonatomic, assign) CGSize imageSize;

@property (nonatomic, assign) CGFloat linkInfoTop;


@property (nonatomic, assign) CGFloat companyTop;

@property (nonatomic, strong) NSAttributedString *linkTitle;
@property (nonatomic, assign) NSRange linkRange;

@property (nonatomic, strong) NSString *desc;

@property (nonatomic, assign) BOOL explored;
@property (nonatomic, assign) BOOL needExplored;

- (instancetype)initLayoutWithActivityModel:(ActivityModel *)model forDetail:(BOOL)detail;
- (instancetype)initLayoutWithActivityModel:(ActivityModel *)model forNote:(BOOL)isNote;


- (instancetype)initLayoutWithActivityModel:(ActivityModel *)model type:(ActivityLayoutType)theType;
@property (nonatomic, assign) ActivityLayoutType type;
@property (nonatomic, assign) CGSize collectionCellSize;
@property (nonatomic, copy) NSString *displayText;
@end
