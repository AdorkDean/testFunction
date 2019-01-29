//
//  QMPCommunityViewController.h
//  CommonLibrary
//
//  Created by QMP on 2019/1/9.
//  Copyright © 2019 WSS. All rights reserved.
//社区列表

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger,CommunityType) {
    CommunityType_UserShare = 1, //用户分享
    CommunityType_Topic         //话题讨论
};
@interface QMPCommunityListController : BaseViewController
@property(nonatomic,assign) CommunityType communityType;

- (void)postButtonClick;
@end

NS_ASSUME_NONNULL_END
