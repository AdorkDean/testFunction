//
//  DetailFeedBackHeadVw.h
//  qmp_ios
//
//  Created by QMP on 2018/7/2.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailFeedBackHeadVw : UIView
@property (nonatomic, copy) NSString * imgUrlStr;
@property (nonatomic, copy) NSString * detailNameStr;

+ (instancetype)initLoadViewNibFrame:(CGRect)frame;
//0:人物，1：项目，2：机构
+ (instancetype)initLoadViewNibFrame:(CGRect)frame type:(NSInteger)type;
@end
