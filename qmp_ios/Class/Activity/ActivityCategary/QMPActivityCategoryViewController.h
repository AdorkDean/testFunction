//
//  QMPActivityCategoryViewController.h
//  CommonLibrary
//
//  Created by QMP on 2018/12/4.
//  Copyright © 2018 WSS. All rights reserved.
//

#import <WMPageController.h>
NS_ASSUME_NONNULL_BEGIN

@interface QMPActivityCategoryViewController : WMPageController
- (void)scrollTop;
- (void)showToTag:(NSString*)tagName activityID:(NSString*)activityID;
- (void)postButtonClick;

@end

NS_ASSUME_NONNULL_END
