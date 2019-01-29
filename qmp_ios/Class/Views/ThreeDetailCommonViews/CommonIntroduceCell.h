//
//  CommonIntroduceCell.h
//  qmp_ios
//
//  Created by QMP on 2018/6/29.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IntroduceCellLayout.h"

@interface CommonIntroduceCell : UITableViewCell

+ (instancetype)cellWithTableView:(UITableView*)tableView didTapShowAll:(void(^)(void))didTapShowAll;

@property(nonatomic,copy) NSString *shortUrl;
@property(nonatomic,strong) IntroduceCellLayout *layout;
@end
