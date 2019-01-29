//
//  SearchhistoryCell.m
//  qmp_ios
//
//  Created by QMP on 2017/10/17.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "SearchhistoryCell.h"
#import <UICollectionViewLeftAlignedLayout.h>

@interface SearchhistoryCell()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateLeftAlignedLayout>
{
    NSMutableArray *_widthArr;
}

@end
@implementation SearchhistoryCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:UIApplicationStateRestorationUserInterfaceIdiomKey]) {
        [self setUI];
    }
    return self;
}


- (void)setUI{

    UICollectionViewLeftAlignedLayout *layout = [[UICollectionViewLeftAlignedLayout alloc]init];
    layout.minimumLineSpacing = 10;
    layout.minimumInteritemSpacing = 10;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;

    _collectionView = [[UICollectionView alloc]initWithFrame:self.bounds collectionViewLayout:layout];
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [self.contentView addSubview:_collectionView];
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCellID"];
    _collectionView.backgroundColor = self.contentView.backgroundColor;
    _collectionView.contentInset = UIEdgeInsetsMake(5, 17, 0, 17);
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    _collectionView.frame = self.contentView.bounds;

    [UIView performWithoutAnimation:^{
        [_collectionView reloadData];
        
    }];
    
}

-(void)setHistoryArr:(NSArray *)historyArr{
    
    NSMutableArray *arr = [NSMutableArray arrayWithArray:historyArr];
    if (historyArr && historyArr.count>30) {
        
        [arr removeObjectsInRange:NSMakeRange(30, historyArr.count-30)];
    }
    _widthArr = [NSMutableArray array];
    _historyArr = arr;
    _widthArr = [NSMutableArray array];
    [UIView performWithoutAnimation:^{
        [_collectionView reloadData];

    }];
}

- (void)setDataArr:(NSArray *)dataArr{
    _historyArr = [NSMutableArray arrayWithArray:dataArr];
    _widthArr = [NSMutableArray array];
    [_collectionView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _historyArr.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *str = _historyArr[indexPath.item];
    
    CGFloat width = [PublicTool widthOfString:str height:CGFLOAT_MAX fontSize:13];
    if (width > (SCREENW - 40)) {
        NSMutableString *muStr = [NSMutableString stringWithString:str];
        str = [[muStr substringToIndex:20] stringByAppendingString:@"..."];
       width = [PublicTool widthOfString:str height:CGFLOAT_MAX fontSize:13];

    }
    //如果是火爆 宽度增加
    if ([self.hotArr containsObject:str]) {
        [_widthArr addObject:@(width+22+10)];
        return CGSizeMake(width+22+10, 27);
    }
    [_widthArr addObject:@(width+22)];
    return CGSizeMake(width+22, 27);
    
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
  
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UICollectionViewCellID" forIndexPath:indexPath];
    
    UILabel *label = [cell.contentView viewWithTag:1000];
    
    if (!label) {
        label = [[UILabel alloc]initWithFrame:cell.bounds];
        [cell.contentView addSubview:label];
        label.font = [UIFont systemFontOfSize:12];
        label.textColor = COLOR2D343A;
        label.textAlignment = NSTextAlignmentCenter;
        label.tag = 1000;
        
    }
    UIImageView *imgV = [cell.contentView viewWithTag:1001];
    if (!imgV) {
        imgV = [[UIImageView alloc]initWithFrame:CGRectMake(7, 0, 15, cell.contentView.height)];
        imgV.image =[BundleTool imageNamed:@"search_hot"];
        imgV.contentMode = UIViewContentModeCenter;
        [cell.contentView addSubview:imgV];
        imgV.tag = 1001;
    }
    
    cell.contentView.backgroundColor = HTColorFromRGB(0xf5f5f5);
    cell.contentView.layer.masksToBounds = YES;
    cell.contentView.layer.cornerRadius = 13.5;
    
    NSString *str = _historyArr[indexPath.item];
    CGFloat width = [_widthArr[indexPath.item] floatValue];

    if ([self.hotArr containsObject:str]) {
        imgV.hidden = NO;
        label.frame = CGRectMake(imgV.right+3, 0, width - (imgV.right+3), 27);
        label.textAlignment = NSTextAlignmentLeft;
    }else{
        imgV.hidden = YES;
        label.frame = CGRectMake(0, 0, width, 27);
        label.textAlignment = NSTextAlignmentCenter;
    }
    
    label.text = str;
    return cell;
}


//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
//    return 15;
//}
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
//    return 15;
//}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    
    [UIView animateWithDuration:0.1 animations:^{
        
        cell.contentView.backgroundColor = HTColorFromRGB(0xeeeeee);
        
    }completion:^(BOOL finished) {
        
        if (self.selectedIndex) {
            self.selectedIndex(indexPath.item);
        }
        cell.contentView.backgroundColor = H568COLOR;

    }];
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
