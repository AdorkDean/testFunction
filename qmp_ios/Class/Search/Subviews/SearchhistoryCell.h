//
//  SearchhistoryCell.h
//  qmp_ios
//
//  Created by QMP on 2017/10/17.
//  Copyright © 2017年 Molly. All rights reserved.
// 搜索历史 cell，内部UICollectionView

#import <UIKit/UIKit.h>

@interface SearchhistoryCell : UITableViewCell
@property(nonatomic,strong)UICollectionView *collectionView;

@property (copy, nonatomic) void(^selectedIndex)(NSInteger index);

@property(nonatomic,strong) NSArray *hotArr;
@property(nonatomic,strong) NSArray *historyArr;
@property(nonatomic,strong) NSArray *dataArr;

@property (copy, nonatomic) NSString *keyword;

@end
