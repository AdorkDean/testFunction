//
//  ActiveJigouCell.h
//  qmp_ios
//
//  Created by QMP on 2017/11/9.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActiveJigouModel.h"

@interface ActiveJigouCell : UITableViewCell

@property(nonatomic,strong) ActiveJigouModel *jigouModel;

@property (nonatomic, assign) BOOL isFa;

@end
