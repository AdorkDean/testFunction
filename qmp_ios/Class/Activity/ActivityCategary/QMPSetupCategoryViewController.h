//
//  QMPSetupCategoryViewController.h
//  CommonLibrary
//
//  Created by QMP on 2018/12/6.
//  Copyright © 2018 WSS. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface QMPSetupCategoryViewController : BaseViewController
@property (nonatomic, copy) void (^cateGrayDidSetup)(NSArray *items);

@property (nonatomic, strong) NSMutableArray *showCategorys;
@property (nonatomic, strong) NSMutableArray *allCategorys;
@end

NS_ASSUME_NONNULL_END
