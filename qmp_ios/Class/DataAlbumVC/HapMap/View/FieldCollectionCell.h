//
//  FieldCollectionCell.h
//  qmp_ios
//
//  Created by QMP on 2017/11/17.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HapMapAreaModel.h"

@interface FieldCollectionCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet UILabel *countLab;

@property(nonatomic,strong)HapMapAreaModel *filedModel;
@end
