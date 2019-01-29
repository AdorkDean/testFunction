//
//  CompanyHeaderView.h
//  qmp_ios
//
//  Created by QMP on 2017/10/12.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CompanyDetailBasicModel.h"
#import "CompanyDetailModel.h"

@interface CompanyHeaderView : UIView
@property (weak, nonatomic) IBOutlet UIButton *cauwuBtn;
@property (weak, nonatomic) IBOutlet UIButton *feedBackBtn;
@property (weak, nonatomic) IBOutlet UIButton *baiduBtn;
@property (weak, nonatomic) IBOutlet UIButton *noteBtn;

@property(nonatomic,strong) CompanyDetailModel *detailModel;
@property(nonatomic,strong) CompanyDetailBasicModel *basicModel;
@property (nonatomic, strong) NSNumber *claim_type;
@property (nonatomic, strong) NSNumber *op_flag;

@property (copy, nonatomic) void(^ClaimButtonClick)(UIButton *claimBtn);
@property (nonatomic, assign) BOOL needClaimButton;
@end

