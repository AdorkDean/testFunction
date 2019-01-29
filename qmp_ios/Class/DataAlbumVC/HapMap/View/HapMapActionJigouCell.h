//
//  HapMapActionJigouCell.h
//  qmp_ios
//
//  Created by QMP on 2017/11/17.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HapMapTrendModel.h"


@interface HapMapActionJigouCell : UITableViewCell

@property (copy, nonatomic) void(^clickJigou)(NSString *jigouUrl);

- (void)buildUI:(NSArray*)dataArr;


@end
