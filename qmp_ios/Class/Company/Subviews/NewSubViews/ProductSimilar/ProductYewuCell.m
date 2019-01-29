//
//  ProductYewuCell.m
//  qmp_ios
//
//  Created by QMP on 2018/8/6.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "ProductYewuCell.h"
#import "SimilarCell.h"
#import "DetailLayout.h"


@interface ProductYewuCell()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) UICollectionView *mainView;
@end
@implementation ProductYewuCell

+ (instancetype)cellWithTableView:(UITableView*)tableView{
    
    ProductYewuCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProductYewuCellID"];
    if (!cell) {
        cell = [[ProductYewuCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ProductYewuCellID"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:self.mainView];
    }
    return self;
}
- (void)setDataArray:(NSArray *)dataArray{
    _dataArray = dataArray;
    [self.mainView reloadData];
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return MIN(15, self.dataArray.count);
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    SimilarCell *cell = [SimilarCell cellWithCollectionView:collectionView indexPath:indexPath];
    cell.yewuModel = self.dataArray[indexPath.item]; //业务和相似项目
    cell.iconColor = RANDOM_COLORARR[indexPath.item%6];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    SearchCompanyModel *product = self.dataArray[indexPath.item];
    [[AppPageSkipTool shared] appPageSkipToDetail:product.detail];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
- (void)layoutSubviews {
    [super layoutSubviews];
    self.mainView.frame = self.contentView.bounds;
}
#pragma mark - Getter
- (UICollectionView *)mainView {
    if (!_mainView) {
        DetailLayout *layout = [[DetailLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize = CGSizeMake(SCREENW-16, 64);
        layout.minimumLineSpacing = 8;
        layout.minimumInteritemSpacing = 0;
        
        CGRect rect = CGRectMake(0, 0, 0, 0);
        _mainView = [[UICollectionView alloc] initWithFrame:rect collectionViewLayout:layout];
        _mainView.backgroundColor = [UIColor whiteColor];
        _mainView.dataSource = self;
        _mainView.delegate = self;
        _mainView.showsHorizontalScrollIndicator = NO;
        _mainView.contentInset = UIEdgeInsetsMake(6, 16, 2, 16);
        _mainView.decelerationRate = UIScrollViewDecelerationRateFast;
        _mainView.alwaysBounceHorizontal = YES;
        [_mainView registerNib:[UINib nibWithNibName:@"SimilarCell" bundle:[BundleTool commonBundle]] forCellWithReuseIdentifier:@"SimilarCellID"];
        _mainView.scrollEnabled = NO;
        
    }
    return _mainView;
}


@end
