//
//  DetailFeedBackTxtCell.h
//  qmp_ios
//
//  Created by QMP on 2018/7/2.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HMTextView.h"

typedef void(^callChangeTxtBlock)(NSString *txt);

@interface DetailFeedBackTxtCell : UITableViewCell
@property (strong, nonatomic) HMTextView *inputTxtVw;
@property (nonatomic, copy) callChangeTxtBlock calltxtBack;
+ (instancetype)initTableViewCell:(UITableView *)tableView;
@end
