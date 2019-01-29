//
//  ClaimCell.h
//  CommonLibrary
//
//  Created by QMP on 2019/1/18.
//  Copyright © 2019 WSS. All rights reserved.
//要求认证 或者 认证角色限制

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ClaimCell : UITableViewCell

+ (instancetype)cellWithTableView:(UITableView*)tableView tipInfo:(NSString*)tipInfo showbgImg:(BOOL)showBgImg ;
@end

NS_ASSUME_NONNULL_END
