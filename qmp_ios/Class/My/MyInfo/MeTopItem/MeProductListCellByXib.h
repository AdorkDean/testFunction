//
//  MeProductListCellByXib.h
//  qmp_ios
//
//  Created by QMP on 2018/5/17.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MeTopItemModel.h"

typedef  NS_ENUM(NSInteger, fromAreaType){
        fromMeProductType,
        fromMeJiGouTyp,
};
@interface MeProductListCellByXib : UITableViewCell

+ (instancetype)cellWithTableView:(UITableView*)tableView;

@property (nonatomic, assign) fromAreaType type;
@property (weak, nonatomic) IBOutlet UIButton *attetionBtn;
@property (strong, nonatomic) MeTopItemModel * model;

@end
