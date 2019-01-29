//
//  RzfilterTableViewCell.m
//  qmp_ios_v2.0
//
//  Created by Molly on 2017/1/16.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "RzfilterTableViewCell.h"
#import "DrawerViewCollectionViewCell.h"

#define cellWidth (SCREENW - 85*ratioWidth)

@interface RzfilterTableViewCell()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>{
    
    BOOL _isCountry;
    NSInteger _count;
    NSString *_area;
}

@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) NSString *cellIdentifier;
@property (strong, nonatomic) NSMutableArray *dataMArr;
@property (strong, nonatomic) NSMutableArray *selectMArr;
@end

@implementation RzfilterTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier isCountry:(BOOL)isCountry withCount:(NSInteger)count withDataMArr:(NSMutableArray *)dataMArr withSelectedMArr:(NSMutableArray *)selectMArr{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.dataMArr = dataMArr;
        self.selectMArr = selectMArr;
        _isCountry = isCountry;
        _count = count;
        _area = @"国内";
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _collectionView =[ [UICollectionView alloc] initWithFrame:CGRectMake(0,0, cellWidth, ceil(dataMArr.count / 3.f) *37+10) collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.scrollEnabled = NO;
        _cellIdentifier = @"RzfilterCollectionViewCell";
        [_collectionView registerClass:[DrawerViewCollectionViewCell class] forCellWithReuseIdentifier:_cellIdentifier];
        [self.contentView addSubview:_collectionView];
        
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
}

#pragma mark - collectView
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return _count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DrawerViewCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:_cellIdentifier forIndexPath:indexPath];
    
    IndustryItem *industryItem = self.dataMArr[indexPath.row];
    
    UIColor *titleColor;
    if ([industryItem.selected isEqualToString:@"1"]) {
        
        [cell.industryBtn setTitle:industryItem.name forState:UIControlStateNormal];
        cell.industryBtn.layer.borderColor = [BLUE_TITLE_COLOR CGColor];
        cell.industryBtn.selected = YES;
        titleColor = BLUE_TITLE_COLOR;
    } else{
        cell.industryBtn.layer.borderColor = [H999999 CGColor];
        [cell.industryBtn setTitle:industryItem.name forState:UIControlStateNormal];
        cell.industryBtn.selected = NO;
        titleColor = H3COLOR;
    }
    
    [cell.industryBtn setTitleColor:titleColor forState:UIControlStateNormal];
    
    cell.industryBtn.tag = indexPath.row;
    [cell.industryBtn addTarget:self action:@selector(pressInductryBtn:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    CGFloat W = (cellWidth - 20 * 2 - 20*2) / 3-1;
    return CGSizeMake(W, 25);
}

- (UIEdgeInsets) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(5, 20, 10, 20);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    
    return 12.f;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    
    return 20.f;
}
#pragma mark - public
- (void)pressInductryBtn:(UIButton *)sender{
    
    NSString *title = sender.titleLabel.text;
    
    BOOL selected = !sender.selected;
    sender.selected = selected;
    if (sender.selected) {
        [self.selectMArr addObject:title];
        [sender setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
        sender.layer.borderColor = [BLUE_TITLE_COLOR CGColor];
    }else{
        sender.layer.borderColor = [H999999 CGColor];
        [sender setTitleColor:H3COLOR forState:UIControlStateNormal];
        if([self.selectMArr containsObject:title]){
            [self.selectMArr removeObject:title];
        }
    }
    IndustryItem *industryItem = self.dataMArr[sender.tag];
    industryItem.selected = sender.selected ? @"1":@"0";
}

@end
