//
//  OrganizeInvestCaseCollectionCell.h
//  qmp_ios
//
//  Created by QMP on 2018/7/27.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InsetsLabel.h"

@class JigouInvestmentsCaseModel;
@class PersonTouziModel;

@interface OrganizeInvestCaseCollectionCell : UICollectionViewCell
@property (nonatomic, weak) IBOutlet UIImageView *iconView;
@property (nonatomic, weak) IBOutlet UILabel *iconLabel;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet InsetsLabel *roundLabel;
@property (nonatomic, weak) IBOutlet UILabel *industryLabel;
@property (nonatomic, weak) IBOutlet UILabel *businessLabel;
@property (nonatomic, weak) IBOutlet UIImageView *dotView;
@property (nonatomic, weak) IBOutlet UILabel *investInfoLabel;
@property (weak, nonatomic) IBOutlet UIImageView *topBagdeView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelConstraint;


+ (instancetype)cellWithCollectionView:(UICollectionView*)collectionView indexPath:(NSIndexPath*)indexPath;
@property(nonatomic,strong) UIColor *iconColor;
@property (nonatomic, strong) JigouInvestmentsCaseModel *model;
@property (nonatomic, strong) PersonTouziModel *personTzM;

@end
