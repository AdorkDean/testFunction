//
//  QMPActivityCategoryListViewController.h
//  CommonLibrary
//
//  Created by QMP on 2018/12/4.
//  Copyright © 2018 WSS. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface QMPActivityCategoryListViewController : BaseViewController
@property (nonatomic, copy) NSString *ticket;
@property (nonatomic, copy) NSString *topActivityID; //推送顶部动态id

- (instancetype)initWithTicket:(NSString *)ticket;
@property (nonatomic, assign) BOOL didRefreshed;
@end

NS_ASSUME_NONNULL_END
