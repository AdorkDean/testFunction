//
//  PersonDetailsController.h
//  qmp_ios
//
//  Created by QMP on 2018/6/29.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "BaseViewController.h"

@interface PersonDetailsController : BaseViewController
@property(nonatomic,assign) BOOL fromClaimReq;
@property (copy, nonatomic)NSString *persionId;
//@property (copy, nonatomic)NSString *ticket;
@property(nonatomic,assign)BOOL isMy;
@property (copy, nonatomic)UIColor *nameLabColor;


@end
