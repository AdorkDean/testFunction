//
//  CompanyZhaopinCell.h
//  qmp_ios
//
//  Created by QMP on 2018/2/26.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZhaopinModel.h"

@interface CompanyZhaopinCell : UITableViewCell

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topEdge;
@property (weak, nonatomic) IBOutlet UIView *bottomLine;


@property(nonatomic,strong) ZhaopinModel *model;

@end
