//
//  ActivityCommentModel.h
//  qmp_ios
//
//  Created by QMP on 2018/7/2.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ActivityUserModel, YYTextLayout, ActivityCompanyModel;
@interface ActivityCommentModel : NSObject
@property (nonatomic, strong) ActivityUserModel *user;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *ID;
@property (nonatomic, copy) NSString *createAt;
@property (nonatomic, assign, getter=isAnonymous) BOOL anonymous;
@property (nonatomic, assign) NSInteger anonymous_degree;
@property (nonatomic, copy) NSString *like_num;
@property (nonatomic, assign) NSInteger likeCount;
@property (nonatomic, assign, getter=isLike) BOOL like_status;

@property (nonatomic, strong) ActivityCompanyModel *company;

+ (ActivityCommentModel *)activityDetail_commentModelWithResponse:(NSDictionary *)resp;


@property (nonatomic, assign) BOOL showCompany;

@property (nonatomic, assign) CGFloat cellHeight;
@property (nonatomic, strong) YYTextLayout *textLayout;

@property (nonatomic, assign) BOOL showID;
@end
