//
//  PersonInvestCaseTableViewCell.m
//  qmp_ios
//
//  Created by QMP on 2018/9/26.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "PersonInvestCaseTableViewCell.h"

//#import "OrganizeInvestCaseCollectionCell.h"
#import "DynamicRelateCell.h"
#import "PersonInvestCaseCollectionViewCell.h"

@interface PersonInvestCaseTableViewCell () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) UICollectionView *collectionView;
@end
@implementation PersonInvestCaseTableViewCell

+ (instancetype)cellWithTableView:(UITableView*)tableView {
    PersonInvestCaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PersonInvestCaseTableViewCellID"];
    if (!cell) {
        cell = [[PersonInvestCaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PersonInvestCaseTableViewCellID"];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:self.collectionView];
    }
    return self;
}

- (void)setDataArray:(NSArray *)dataArray{
    _dataArray = dataArray;
    [self.collectionView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return MIN(self.dataArray.count, 15);
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
   
    PersonInvestCaseCollectionViewCell *similarCollectionCell = [PersonInvestCaseCollectionViewCell cellWithCollectionView:collectionView indexPath:indexPath];
    id model = self.dataArray[indexPath.item];
    similarCollectionCell.personTzM = model;
    similarCollectionCell.iconColor = RANDOM_COLORARR[indexPath.item%6];
    return similarCollectionCell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
  
    id model = self.dataArray[indexPath.item];
    [[AppPageSkipTool shared] appPageSkipToDetail:[model valueForKey:@"detail"]];
    
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        MyCollectionViewFlowLayout *layout = [[MyCollectionViewFlowLayout alloc] init];//WithSectionInset:UIEdgeInsetsMake(10, 16, 5, 16)];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing  = 8;
        layout.minimumInteritemSpacing = 0;
        layout.itemSize = CGSizeMake(SCREENW-16, 68);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.contentInset = UIEdgeInsetsMake(0, 16, 5, 16);
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
        _collectionView.alwaysBounceHorizontal = YES;
        [_collectionView registerNib:[UINib nibWithNibName:@"PersonInvestCaseCollectionViewCell" bundle:[BundleTool commonBundle]] forCellWithReuseIdentifier:@"PersonInvestCaseCollectionViewCellID"];
        _collectionView.scrollEnabled =NO;
        
    }
    return _collectionView;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    self.collectionView.frame = self.bounds;
}
@end
