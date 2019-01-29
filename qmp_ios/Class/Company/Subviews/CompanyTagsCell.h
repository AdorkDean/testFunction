//
//  CompanyTagsCell.h
//  qmp_ios
//
//  Created by QMP on 2017/8/30.
//  Copyright © 2017年 Molly. All rights reserved.

//公司详情标签cell

#import <UIKit/UIKit.h>

@interface CompanyTagsCell : UITableViewCell

@property(nonatomic,strong) UICollectionView *tagsCollecView;
@property(nonatomic,strong) NSArray *tagsArr;

@property (copy, nonatomic) void(^clickTag)(NSInteger index);



@end
