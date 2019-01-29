//
//  CreateFeedBackViewController.h
//  qmp_ios
//
//  Created by QMP on 2018/4/8.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "BaseViewController.h"

typedef void(^CreateFeedBackFinishBlock)(NSDictionary *dict);
@interface CreateFeedBackViewController : BaseViewController
@property (nonatomic, assign) NSInteger source; ///< 1: 贡献反馈 2: 全局反馈
@property (nonatomic, copy) CreateFeedBackFinishBlock block;
@end
