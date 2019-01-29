//
//  QMPCommunityController.h
//  CommonLibrary
//
//  Created by QMP on 2019/1/24.
//  Copyright © 2019 WSS. All rights reserved.
//社区  （用户分享和话题讨论）

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface QMPCommunityController : BaseViewController

- (void)scrollTop;
- (void)showToTag:(NSString*)tagName activityID:(NSString*)activityID;
@end

NS_ASSUME_NONNULL_END
