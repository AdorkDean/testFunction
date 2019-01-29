//
//  ProductTableHeadView.h
//  qmp_ios
//
//  Created by QMP on 2018/6/11.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CompanyDetailModel.h"
#import "FinanicalNeedModel.h"
#import "ProductDetailViewModel.h"

@interface ProductTableHeadView : UIView

@property (weak, nonatomic) IBOutlet UIView *basicInfoV;
@property (weak, nonatomic) IBOutlet UIView *needMoneyV;
@property (copy, nonatomic) void(^tapedNeedMoneyView)(void);
@property (copy, nonatomic) void(^claimBtnClick)(UIButton *claimBtn);

@property(nonatomic,strong) CompanyDetailModel *detailM;
@property(nonatomic,strong) FinanicalNeedModel *needModel;

@property(nonatomic,strong) ProductDetailViewModel *viewModel;



- (instancetype)initWithCompanyDetailModel:(CompanyDetailModel*)detailM financeNeedModel:(FinanicalNeedModel*)needModel;

- (void)setSelectedMenu:(NSString*)menuTitle;

- (void)refreshCountWithDic:(NSDictionary*)dic;

@end
