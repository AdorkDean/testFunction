//
//  OrganizeInvestCaseTableCell.m
//  qmp_ios
//
//  Created by QMP on 2018/7/27.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "OrganizeInvestCaseTableCell.h"
#import "OrganizeInvestCaseCollectionCell.h"
#import "DynamicRelateCell.h"

@interface OrganizeInvestCaseTableCell () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) UICollectionView *collectionView;
@end
@implementation OrganizeInvestCaseTableCell

+ (instancetype)cellWithTableView:(UITableView*)tableView idnetifier:(NSString*)identifier{
    OrganizeInvestCaseTableCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[OrganizeInvestCaseTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    return cell;
}


+ (instancetype)cellWithTableView:(UITableView*)tableView {
    OrganizeInvestCaseTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OrganizeInvestCaseTableCellID"];
    if (!cell) {
        cell = [[OrganizeInvestCaseTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"OrganizeInvestCaseTableCellID"];
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

- (void)setDataArray:(NSArray *)dataArray {
    _dataArray = dataArray;
    [self.collectionView reloadData];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return MIN(self.dataArray.count, 15);
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    OrganizeInvestCaseCollectionCell *similarCollectionCell = [OrganizeInvestCaseCollectionCell cellWithCollectionView:collectionView indexPath:indexPath];
    id model = self.dataArray[indexPath.item];
    similarCollectionCell.model = model;
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
        layout.itemSize = CGSizeMake(SCREENW-16, 78);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.contentInset = UIEdgeInsetsMake(2, 16, 5, 16);
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
        _collectionView.alwaysBounceHorizontal = YES;
        [_collectionView registerNib:[UINib nibWithNibName:@"OrganizeInvestCaseCollectionCell" bundle:[BundleTool commonBundle]] forCellWithReuseIdentifier:@"OrganizeInvestCaseCollectionCellID"];
        _collectionView.scrollEnabled =NO;

    }
    return _collectionView;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    self.collectionView.frame = self.bounds;
}
@end
