//
//  PersonBusinessRoleCell.h
//  qmp_ios
//
//  Created by QMP on 2018/4/16.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PersonRoleModel;
@protocol PersonBusinessRoleCellDelegate <NSObject>
@optional
- (void)personBusinessRoleCellAvatarClick:(PersonRoleModel *)personRole;
@end
@interface PersonBusinessRoleCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *companyNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UILabel *registerCapitalLabel;
@property (weak, nonatomic) IBOutlet UILabel *tiemLabel;
@property (weak, nonatomic) IBOutlet UIButton *statusButton;
@property (weak, nonatomic) IBOutlet UIImageView *lineView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet UILabel *avatarLabel;

@property (nonatomic, strong) PersonRoleModel *model;
@property (nonatomic, weak) id<PersonBusinessRoleCellDelegate> delegate;

+ (instancetype)cellWithTableView:(UITableView*)tableView;

@end
