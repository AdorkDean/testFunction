//
//  SimilarCell.h
//  qmp_ios
//
//  Created by QMP on 2018/7/24.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchCompanyModel.h"
#import "PersonTouziModel.h"


@interface SimilarCell : UICollectionViewCell

+ (instancetype)cellWithCollectionView:(UICollectionView*)collectionView indexPath:(NSIndexPath*)indexPath;
@property(nonatomic,strong) UIColor *iconColor;

@property(nonatomic,strong) SearchCompanyModel *yewuModel;
@property(nonatomic,strong) PersonTouziModel *touziM;

@end
