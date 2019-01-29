//
//  PersonInvestCaseCollectionViewCell.h
//  qmp_ios
//
//  Created by QMP on 2018/9/26.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "InsetsLabel.h"
NS_ASSUME_NONNULL_BEGIN
@class PersonTouziModel;
@interface PersonInvestCaseCollectionViewCell : UICollectionViewCell
@property (nonatomic, weak) IBOutlet UIImageView *iconView;
@property (nonatomic, weak) IBOutlet UILabel *iconLabel;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet InsetsLabel *roundLabel;
@property (nonatomic, weak) IBOutlet UILabel *industryLabel;
@property (nonatomic, weak) IBOutlet UILabel *businessLabel;
@property (nonatomic, weak) IBOutlet UIImageView *dotView;
@property (nonatomic, weak) IBOutlet UILabel *investInfoLabel;


+ (instancetype)cellWithCollectionView:(UICollectionView*)collectionView indexPath:(NSIndexPath*)indexPath;
@property(nonatomic,strong) UIColor *iconColor;
@property (nonatomic, strong) PersonTouziModel *personTzM;
@end

NS_ASSUME_NONNULL_END
