//
//  CompanyFinancialHeaderView.h
//  qmp_ios
//
//  Created by QMP on 2018/5/3.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FinanicalNeedModel;
@interface CompanyFinancialHeaderView : UITableViewHeaderFooterView
@property (weak, nonatomic) IBOutlet UILabel *lunciLabel;
@property (weak, nonatomic) IBOutlet UILabel *moneyLabel;
@property (weak, nonatomic) IBOutlet UILabel *scaleLabel;
@property (weak, nonatomic) IBOutlet UILabel *userLabel;
@property (weak, nonatomic) IBOutlet UILabel *advantageLabel;
@property (weak, nonatomic) IBOutlet UIButton *contactButton;
@property (weak, nonatomic) IBOutlet UILabel *zhiweiLabel;
@property (weak, nonatomic) IBOutlet UIButton *bpButton;

@property(nonatomic, strong) FinanicalNeedModel * needModel;

@end
