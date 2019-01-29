//
//  SimilarFilterCell.h
//  qmp_ios
//
//  Created by shan wen on 2018/2/22.
//  Copyright © 2018年 Molly. All rights reserved.
//相似项目筛选维度  cell

#import <UIKit/UIKit.h>

@interface SimilarFilterCell : UITableViewCell

@property(nonatomic,strong) UICollectionView *tagsCollecView;
@property(nonatomic,strong) UIButton *showAllBtn;
@property(nonatomic,strong)UILabel *titleLab;

@property(nonatomic,copy) NSString *selectedTag;
@property(nonatomic,strong) NSArray *tagsArr;

@property (copy, nonatomic) void(^clickTag)(NSString *tag);


@end
