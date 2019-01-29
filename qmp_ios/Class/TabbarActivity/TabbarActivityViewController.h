//
//  TabbarActivityViewController.h
//  qmp_ios_v2.0
//
//  Created by QMP on 2018/10/31.
//  Copyright © 2018 Molly. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface TabbarActivityViewController : BaseViewController
- (void)toSquare;
- (void)scrollTop;
- (void)showToTag:(NSString*)tagName activityID:(NSString*)activityID;
@end

NS_ASSUME_NONNULL_END
