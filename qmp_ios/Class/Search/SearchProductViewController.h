//
//  SearchProductViewController.h
//  qmp_ios
//
//  Created by Molly on 16/8/23.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchCompanyModel.h"
#import "OrganizeItem.h"


@protocol AddProductToGroupOnGroupDelegate <NSObject>

@optional
- (void)addSuccess;
- (void)addProduct:(SearchCompanyModel *)companyModel;
- (void)addOrganize:(OrganizeItem*)jigouModel;

@end

@interface SearchProductViewController : BaseViewController

@property (strong, nonatomic) NSString *groupId;  // 感兴趣  workFlowNum
@property (strong, nonatomic) NSMutableArray *hasProductidMArr;
@property (strong, nonatomic) NSMutableArray *hasOrganizeidMArr;

@property (strong, nonatomic) id<AddProductToGroupOnGroupDelegate> delegate;

- (instancetype)initWithAction:(NSString *)action;

@end
