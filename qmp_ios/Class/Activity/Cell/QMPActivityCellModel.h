//
//  QMPActivityCellModel.h
//  qmp_ios
//
//  Created by QMP on 2018/8/22.
//  Copyright © 2018年 Molly. All rights reserved.
//根据ActivityModel 计算cell布局

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class YYTextLayout, ActivityModel;
@interface QMPActivityCellModel : NSObject
@property (nonatomic, assign) BOOL isCommunity;
- (instancetype)initWithActivity:(ActivityModel *)activity forCommunity:(BOOL)community; //资讯和圈子分开
- (instancetype)initWithActivity:(ActivityModel *)activity forCommunity:(BOOL)community detail:(BOOL)detail; //资讯和圈子详情页分开
@property (nonatomic, strong) ActivityModel *activity;



@property (nonatomic, strong, readonly) YYTextLayout *textLayout;
/**** size ****/
@property (nonatomic, assign) CGFloat textHeight; // fix
@property (nonatomic, assign) CGFloat fixTextHeight;

@property (nonatomic, assign) NSRange linkHighlightRange;

@property (nonatomic, assign) CGSize imagesSize;

@property (nonatomic, strong) NSArray *displayRelates;
@property (nonatomic, strong) NSArray *relateItemFrames;
@property (nonatomic, assign) CGSize relatesSize;
@property (nonatomic, assign) CGRect editRelateFrame;
@property (nonatomic, assign) CGRect editRelateFrame2;
@property (nonatomic, assign) CGFloat cellHeight;

/**** state ****/
@property (nonatomic, assign) BOOL detail;
@property (nonatomic, assign) BOOL needDelete;//仅详情页self.detail 我的发布显示删除
@property (nonatomic, assign) BOOL expanding;
@property (nonatomic, assign) BOOL needExpand;
@property (nonatomic, assign) BOOL showID;

- (void)setNeedLayout;
@end
