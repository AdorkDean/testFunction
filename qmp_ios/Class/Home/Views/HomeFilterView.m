//
//  HomeFilterView.m
//  qmp_ios
//
//  Created by QMP on 2018/5/15.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "HomeFilterView.h"
#import "DBHelper.h"
@interface HomeFilterView () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout> {
    NSInteger _currentSection;
}
@property (nonatomic, strong) UICollectionView *contentView;
@property (nonatomic, weak) UICollectionViewFlowLayout *layout;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) NSMutableDictionary *exploreConfig;

@property (nonatomic, strong) FMDatabase *db;

@end
@implementation HomeFilterView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupViews];
        _db = [[DBHelper shared] toGetDB];
        
        
        if ([[DBHelper shared] isTableOK:@"t1" ofDataBase:_db]) {
            
        } else {
            
        }
    }
    return self;
}

- (void)setupViews {
    [self addSubview:self.contentView];
    [self addSubview:self.bottomView];
    
    [[UIApplication sharedApplication].keyWindow addSubview:self.maskView];
}
#pragma mark - Public
- (void)hide {
    self.show = NO;
    if ([self.delegate respondsToSelector:@selector(hideHomeFilterView:)]) {
        [self.delegate hideHomeFilterView:self];
    }
    [UIView animateWithDuration:0.2 animations:^{
        self.transform = CGAffineTransformMakeTranslation(0, -kHomeFilterViewMaxHeight-45);
        self.hidden = YES;
        self.maskView.alpha = 0.00001;
    } completion:^(BOOL finished) {
        self.maskView.hidden = YES;
    }];
    
}
- (void)show {
    self.show = YES;
    [UIView animateWithDuration:0.25 animations:^{
        self.transform = CGAffineTransformIdentity;
    }];
    self.hidden = NO;
    CGFloat top = kHomeFilterViewMaxHeight+kHomeFilterHeaderViewHeight+kScreenTopHeight;
    top = SCREENH - self.superview.height + kHomeFilterViewMaxHeight + kHomeFilterHeaderViewHeight;
    self.maskView.frame = CGRectMake(0, top, SCREENW, SCREENH-top);
    [UIView animateKeyframesWithDuration:0.15 delay:0.1 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
        self.maskView.hidden = NO;
        self.maskView.alpha = 1;
    } completion:nil];
    
    // 备份原有数据
    for (NSString *ss in @[@"范围", @"领域", @"子领域", @"轮次", @"地区", @"亮点"]) {
        NSMutableArray *arr = [NSMutableArray arrayWithArray:[self arrWithTitle:ss]];
        [self.oldSelectedDict setValue:arr forKey:ss];
    }
    
    if (self.sLingyu1Data.count > 0) {
        NSDictionary *section = [self.filterData objectAtIndex:1];
        
        NSMutableArray *ma = [NSMutableArray array];
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"子领域" forKey:@"title"];
        for (NSString  *title in self.sLingyu1Data) {
            [ma addObjectsFromArray:[self fixLingyu2:title]];
        }
        [dict setValue:ma forKey:@"datas"];
        
        if ([section[@"title"] isEqualToString:@"子领域"]) {
            [self.filterData removeObjectAtIndex:1];
        }
        [self.filterData insertObject:dict atIndex:1];
    }
    
}
- (void)hideWithAnimate:(BOOL)animate {
    if ([self.delegate respondsToSelector:@selector(hideHomeFilterView:)]) {
        [self.delegate hideHomeFilterView:self];
    }
    self.hidden = YES;
    if (animate) {
        [UIView animateWithDuration:0.2 animations:^{
            self.transform = CGAffineTransformMakeTranslation(0, -kHomeFilterViewMaxHeight-45);
            self.maskView.alpha = 0.00001;
            
        } completion:^(BOOL finished) {
            self.maskView.hidden = YES;
        }];
    } else {
        self.transform = CGAffineTransformMakeTranslation(0, -kHomeFilterViewMaxHeight-45);
        self.maskView.alpha = 0.00001;
        self.maskView.hidden = YES;
    }
}
- (void)hideWithNoConfirmAnimate:(BOOL)animate {
    [self hideWithAnimate:NO];
    for (NSString *key in self.oldSelectedDict.allKeys) {
        NSMutableArray *array = [self arrWithTitle:key];
        
        NSArray *unselectTure = [array filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT (SELF in %@)", [self.oldSelectedDict objectForKey:key]]];
        NSArray *unselectTure1 = [[self.oldSelectedDict objectForKey:key] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT (SELF in %@)", array]];
        for (NSString *str in unselectTure) {
            [array removeObject:str];
        }
        for (NSString *str in unselectTure1) {
            [array addObject:str];
        }
        
        [self.contentView reloadData];
    }
    if ([self.delegate respondsToSelector:@selector(hideNoConfirmHomeFilterView:)]) {
        [self.delegate hideNoConfirmHomeFilterView:self];
    }
}
- (void)hideWithNoConfirm {
    [self hide];
    for (NSString *key in self.oldSelectedDict.allKeys) {
        NSMutableArray *array = [self arrWithTitle:key];
        
        NSArray *unselectTure = [array filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT (SELF in %@)", [self.oldSelectedDict objectForKey:key]]];
        NSArray *unselectTure1 = [[self.oldSelectedDict objectForKey:key] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT (SELF in %@)", array]];
        for (NSString *str in unselectTure) {
            [array removeObject:str];
        }
        for (NSString *str in unselectTure1) {
            [array addObject:str];
        }
        
        [self.contentView reloadData];
    }
    if ([self.delegate respondsToSelector:@selector(hideNoConfirmHomeFilterView:)]) {
        [self.delegate hideNoConfirmHomeFilterView:self];
    }
}
- (void)reload {
    [self.contentView reloadData];
}
- (void)scrollToSection:(NSInteger)section animated:(BOOL)animated {
    if (section+1 > self.filterData.count) {
        return;
    }

    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:1 inSection:section];
    UICollectionViewLayoutAttributes *attributes = [self.contentView layoutAttributesForItemAtIndexPath:indexPath];
    CGRect frameForFirstCell = attributes.frame;
    frameForFirstCell = attributes.frame;
    CGPoint topOfHeader = CGPointMake(-self.contentView.contentInset.left, frameForFirstCell.origin.y-self.contentView.contentInset.top-42);
    
    [self.contentView setContentOffset:topOfHeader animated:animated];
    
    _currentSection = section;
    [self.contentView reloadData];
}
- (void)scrollToSectionTitle:(NSString *)sectionTitle animated:(BOOL)animated {
    NSInteger section = 0;
    for (NSDictionary *dict in self.filterData) {
        if ([dict[@"title"] isEqualToString:sectionTitle]) {
            [self scrollToSection:section animated:animated];
            break;
        }
        section++;
    }
}
#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.filterData.count;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSDictionary *sectionData = self.filterData[section];
    
    NSNumber *n = self.exploreConfig[sectionData[@"title"]];
    BOOL b = [n boolValue];
    
    NSArray *data = sectionData[@"datas"];
    NSInteger count = data.count;
    if (!b) {
        count = MIN(count, 16);
    }
    return count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UICollectionViewCellID" forIndexPath:indexPath];
//    cell.contentView.backgroundColor = [UIColor redColor];
    
    UILabel *label = [cell.contentView viewWithTag:110];
    if (!label) {
        label = [[UILabel alloc] init];
        label.tag = 110;
        label.frame = CGRectMake(0, 0, (SCREENW-16*2-3*15)/4, 28);
        label.textColor = COLOR2D343A;
        label.font = [UIFont systemFontOfSize:12];// weight:UIFontWeightLight];
        label.textAlignment = NSTextAlignmentCenter;
        [cell.contentView addSubview:label];
    }
    
    NSDictionary *sectionData = self.filterData[indexPath.section];
    NSArray *data = sectionData[@"datas"];
    label.text = data[indexPath.row];
    label.font = [UIFont systemFontOfSize:(label.text.length > 5 ?10:12)];// weight:UIFontWeightLight];

    NSArray *arr = self.selectedData[indexPath.section];
     NSString *sectionTitle = self.filterData[indexPath.section][@"title"];
    arr = [self arrWithTitle:sectionTitle];
    
    cell.contentView.layer.borderWidth = 1;
    cell.contentView.layer.cornerRadius = 2.0;
    cell.contentView.clipsToBounds = YES;
    if (arr && [arr containsObject:label.text]) { // 选中
        label.textColor = HTColorFromRGB(0x006EDA);
        cell.contentView.backgroundColor = [UIColor whiteColor];
        
        cell.contentView.layer.borderColor = [HTColorFromRGB(0x006EDA) CGColor];
    } else {
//        cell.contentView.layer.borderColor = [[UIColor clearColor] CGColor];
        cell.contentView.layer.borderColor = [COLOR737782 CGColor];
        label.textColor = COLOR2D343A;
//        cell.contentView.backgroundColor = H568COLOR;
    }
    
    
    return cell;
}
- (UICollectionReusableView *) collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        
        UILabel *label = [headerView viewWithTag:110];
        if (!label) {
            label = [[UILabel alloc] init];
            label.tag = 110;
            label.frame = CGRectMake(0, 18, 200, 20);
            label.textColor = HTColorFromRGB(0x555555);
            if (@available(iOS 8.2, *)) {
                label.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];// systemFontOfSize:14];
            }else{
                label.font = [UIFont systemFontOfSize:16];// systemFontOfSize:14];
            }
            [headerView addSubview:label];
        }
        NSDictionary *sectionData = self.filterData[indexPath.section];
        
        label.text = sectionData[@"title"];
        label.textColor =  _currentSection == indexPath.section ? HTColorFromRGB(0x006EDA) : NV_TITLE_COLOR;
        
        
        UIButton *button = [headerView viewWithTag:111];
        if (!button) {
            button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.tag = 111;
            button.frame = CGRectMake(SCREENW-34-55, 0, 55, 40);
            button.centerY = label.centerY;
            button.titleLabel.font = [UIFont systemFontOfSize:14];
            [button setTitle:@"展开" forState:UIControlStateNormal];
            [button setTitle:@"收起" forState:UIControlStateSelected];
            [button setImage:[UIImage imageNamed:@"filter_view_arrow_down"] forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:@"filter_view_arrow_up"] forState:UIControlStateSelected];
            [button setTitleColor:H9COLOR forState:UIControlStateNormal];
            [button addTarget:self action:@selector(sectionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            [headerView addSubview:button];
            
            [button.titleLabel sizeToFit];
            button.imageEdgeInsets = UIEdgeInsetsMake(0, button.titleLabel.width+4, 0, -button.titleLabel.width-4);
            button.titleEdgeInsets = UIEdgeInsetsMake(0, -button.imageView.width-4, 0, button.imageView.width+4);
        }
        
        NSNumber *n = self.exploreConfig[label.text];
        button.selected = [n boolValue];
        
        [button setTitle:label.text forState:UIControlStateDisabled];
        
        button.hidden = ![self.exploreConfig.allKeys containsObject:label.text];
        
        NSString *sectionTitle = self.filterData[indexPath.section][@"title"];
        if ([sectionTitle isEqualToString:@"子领域"]) {
            NSMutableDictionary *section = [self.filterData objectAtIndex:1];
            NSArray *arr = section[@"datas"];
            button.hidden = (arr.count <= 16);
        }
        
        
        reusableview = headerView;
    }
    
    
    return reusableview;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(SCREENW, 50);
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeMake(0, 0);
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    
    UILabel *label = [cell.contentView viewWithTag:110];
    NSString *title = label.text;
    
    NSString *sectionTitle = self.filterData[indexPath.section][@"title"];
    
//    NSString *round = [self.sRoundData firstObject];
//    BOOL foreign = [self.sDiquData containsObject:@"国外"];
    
    NSMutableArray *sArr = [self arrWithTitle:sectionTitle];
    if ([sArr containsObject:title]) {
        if (![sectionTitle isEqualToString:@"范围"]) {
            [sArr removeObject:title];
            label.textColor = COLOR2D343A;
//            cell.contentView.backgroundColor = H568COLOR;
//            cell.contentView.layer.borderColor = [[UIColor clearColor] CGColor];
            cell.contentView.layer.borderColor = [COLOR737782 CGColor];
        }
        
        if ([sectionTitle isEqualToString:@"领域"]) {
            NSMutableDictionary *section = [self.filterData objectAtIndex:1];
            if ([section[@"title"] isEqualToString:@"子领域"]) {
                if (sArr.count > 0) {
                    NSMutableArray *mArr = [NSMutableArray array];
                    for (NSString *s in sArr) {
                        [mArr addObjectsFromArray:[NSMutableArray arrayWithArray:[self fixLingyu2:s]]];
                    }
                    [section setValue:mArr forKey:@"datas"];
                } else {
                    [self.filterData removeObjectAtIndex:1];
                }
            }
            
            [self.contentView reloadData];
            [self fixSelectLingyu2WithTitle:title];
        }
        
    } else {
        if ([sectionTitle isEqualToString:@"范围"]) {
            [sArr removeAllObjects];
//            if ([title isEqualToString:@"国外"]) {
//                [self.sDiquData removeAllObjects];
//            }
            [self.contentView reloadData];
            
            [sArr addObject:title];
            
            label.textColor = HTColorFromRGB(0x006EDA);
            cell.contentView.backgroundColor = [UIColor whiteColor];
            cell.contentView.layer.borderWidth = 1;
            cell.contentView.layer.borderColor = [HTColorFromRGB(0x006EDA) CGColor];
        } else {
            
//            if (foreign) {
//                if (![title isEqualToString:@"国外"] && [sectionTitle isEqualToString:@"地区"]) {
//                    [PublicTool showMsg:@"国外不能和地区同选"];
//                    return;
//                }
//            } else {
//                if ([title isEqualToString:@"国外"] && self.sDiquData.count > 0) {
//                    [PublicTool showMsg:@"国外不能和地区同选"];
//                    return;
//                }
//            }
//
//            if ([round isEqualToString:@"国外"] && [sectionTitle isEqualToString:@"地区"]) {
//                [PublicTool showMsg:@"国外暂不支持地区"];
//            } else {
//                [sArr addObject:title];
                [sArr insertObject:title atIndex:0];
                
                label.textColor = HTColorFromRGB(0x006EDA);
                cell.contentView.backgroundColor = [UIColor whiteColor];
                cell.contentView.layer.borderWidth = 1;
                cell.contentView.layer.borderColor = [HTColorFromRGB(0x006EDA) CGColor];
//            }
            
            
            if ([sectionTitle isEqualToString:@"领域"]) {
                NSDictionary *section = [self.filterData objectAtIndex:1];
                if ([section[@"title"] isEqualToString:@"子领域"]) {
                    NSMutableArray *mu = section[@"datas"];
                    
                    NSArray *arr = [self fixLingyu2:title];
                    [mu insertObjects:arr atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, arr.count)]];
//                     [mu addObjectsFromArray:[self fixLingyu2:title]];
                } else {
                    NSMutableDictionary *sec = [NSMutableDictionary dictionary];
                    [sec setValue:@"子领域" forKey:@"title"];
                    [sec setValue:[NSMutableArray arrayWithArray:[self fixLingyu2:title]] forKey:@"datas"];
                    [self.filterData insertObject:sec atIndex:1];
                }
                [self.contentView reloadData];
            }
        }
    }
    
    
    
    if ([self.delegate respondsToSelector:@selector(homeFilterView:cellClick:section:)]) {
        [self.delegate homeFilterView:self cellClick:title section:sectionTitle];
    }

}
- (void)fixSelectLingyu2WithTitle:(NSString *)title {
    NSArray *arr = [self fixLingyu2:title];
    for (NSString *tt in arr) {
        if ([self.sLingyu2Data containsObject:tt]) {
            [self.sLingyu2Data removeObject:tt];
        }
    }
    
}
- (NSArray *)fixLingyu2:(NSString *)title {
    NSMutableArray *arr = [NSMutableArray array];
    for (NSDictionary *dict in self.lingyu2[title]) {
        [arr addObject:dict[@"name"]];
    }
    return arr;
}
- (NSMutableArray *)arrWithTitle:(NSString *)sectionTitle {
    if ([sectionTitle isEqualToString:@"范围"]) {
        return self.sRoundData;
    } else if ([sectionTitle isEqualToString:@"领域"]) {
        
        return self.sLingyu1Data;
    } else if ([sectionTitle isEqualToString:@"子领域"]) {
        
        return self.sLingyu2Data;
    } else if ([sectionTitle isEqualToString:@"轮次"]) {
        
        return self.sLunciData;
    } else if ([sectionTitle isEqualToString:@"地区"]) {
        
        return self.sDiquData;
    } else  {//([sectionTitle isEqualToString:@"亮点"])
        return self.sLiangdianData;
    }
}
#pragma mark - Event
- (void)resetButtonClick {
    for (NSString *ss in @[@"范围", @"领域", @"子领域", @"轮次", @"地区", @"亮点"]) {
        NSMutableArray *arr = [self arrWithTitle:ss];
        [arr removeAllObjects];
    }
    
    if (self.filterData.count > 1) {
        NSDictionary *section = [self.filterData objectAtIndex:1];
        if ([section[@"title"] isEqualToString:@"子领域"]) {
            [self.filterData removeObjectAtIndex:1];
        }
    }
    
    [self.contentView reloadData];
    if ([self.delegate respondsToSelector:@selector(resetHomeFilterView:)]) {
        [self.delegate resetHomeFilterView:self];
    }
}
- (void)confirmButtonClick {
    if ([self.delegate respondsToSelector:@selector(homeFilterView:confirmButtonClick:)]) {
        [self.delegate homeFilterView:self confirmButtonClick:nil];
    }
}
- (void)sectionButtonClick:(UIButton *)button {
    NSString *key = [button titleForState:UIControlStateDisabled];
    NSNumber *n = self.exploreConfig[key];
    BOOL b = [n boolValue];
    [self.exploreConfig setValue:[NSNumber numberWithBool:!b] forKey:key];
    
    [self.contentView reloadData];
}
#pragma mark - Getter
- (UICollectionView *)contentView {
    if (!_contentView) {
        CGFloat marginH = 15;
        CGFloat marginV = 16;
        CGFloat left = 16;
        CGFloat itemW = (SCREENW-left*2-3*marginH)/4;
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(itemW, 28);
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.minimumLineSpacing = marginV;
        layout.minimumInteritemSpacing = marginH;
        self.layout = layout;
        
        
        CGRect rect = CGRectMake(0, 0, SCREENW, kHomeFilterViewMaxHeight-45);
        _contentView = [[UICollectionView alloc] initWithFrame:rect collectionViewLayout:layout];
        _contentView.showsHorizontalScrollIndicator = NO;
        _contentView.contentInset = UIEdgeInsetsMake(0, left, 32, left);
        _contentView.backgroundColor = [UIColor whiteColor];
        _contentView.dataSource = self;
        _contentView.delegate = self;
        
        if (@available(iOS 11.0, *)) {
            _contentView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        
        [_contentView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCellID"];
        [_contentView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView"];
    }
    return _contentView;
}
- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] init];
        _bottomView.frame = CGRectMake(0, kHomeFilterViewMaxHeight-45, SCREENW, 45);
        
        UIButton *button1 = [[UIButton alloc] init];
        button1.frame = CGRectMake(0, 0, SCREENW/2.0, 45);
        button1.backgroundColor = [UIColor whiteColor];
        button1.titleLabel.font = [UIFont systemFontOfSize:16];
        [button1 setTitle:@"重置" forState:UIControlStateNormal];
        [button1 setTitleColor:HTColorFromRGB(0x555555) forState:UIControlStateNormal];
        [_bottomView addSubview:button1];
        [button1 addTarget:self action:@selector(resetButtonClick) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *button2 = [[UIButton alloc] init];
        button2.frame = CGRectMake(SCREENW/2.0, 0, SCREENW/2.0, 45);
        button2.backgroundColor = HTColorFromRGB(0x006EDA);
        button2.titleLabel.font = [UIFont systemFontOfSize:16];
        [button2 setTitle:@"确定" forState:UIControlStateNormal];
        [button2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_bottomView addSubview:button2];
        
        [button2 addTarget:self action:@selector(confirmButtonClick) forControlEvents:UIControlEventTouchUpInside];
        
        UIImageView *line = [[UIImageView alloc] init];
        line.frame = CGRectMake(0, 0, SCREENW, 0.5);
        line.backgroundColor = LIST_LINE_COLOR;
        [_bottomView addSubview:line];
    }
    return _bottomView;
}
- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc] init];
        _maskView.backgroundColor = RGBa(0, 0, 0, 0.3);
        _maskView.frame = CGRectMake(0, 0, SCREENW, 0);
        _maskView.alpha = 0.000001;
        UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideWithNoConfirm)];
        [_maskView addGestureRecognizer:tapGest];
    }
    return _maskView;
}
- (NSMutableArray *)filterData {
    if (!_filterData) {
        _filterData = [NSMutableArray array];
    }
    return _filterData;
}
- (NSMutableArray *)selectedData {
    if (!_selectedData) {
        _selectedData = [NSMutableArray array];
        
        for (int i = 0; i < 10; i++) {
            [_selectedData addObject:[NSMutableArray array]];
        }
    }
    return _selectedData;
}
- (NSMutableDictionary *)exploreConfig {
    if (!_exploreConfig) {
        _exploreConfig = [NSMutableDictionary dictionary];
        [_exploreConfig setValue:@(0) forKey:@"领域"];
        [_exploreConfig setValue:@(0) forKey:@"子领域"];
        [_exploreConfig setValue:@(0) forKey:@"地区"];
    }
    return _exploreConfig;
}
- (NSMutableDictionary *)oldSelectedDict {
    if (!_oldSelectedDict) {
        _oldSelectedDict = [NSMutableDictionary dictionary];
    }
    return _oldSelectedDict;
}
#pragma mark - haha
- (NSMutableArray *)sRoundData {
    if (!_sRoundData) {
        _sRoundData = [NSMutableArray array];
    }
    return _sRoundData;
}
- (NSMutableArray *)sLingyu1Data {
    if (!_sLingyu1Data) {
        _sLingyu1Data = [NSMutableArray array];
    }
    return _sLingyu1Data;
}
- (NSMutableArray *)sLingyu2Data {
    if (!_sLingyu2Data) {
        _sLingyu2Data = [NSMutableArray array];
    }
    return _sLingyu2Data;
}
- (NSMutableArray *)sLunciData {
    if (!_sLunciData) {
        _sLunciData = [NSMutableArray array];
    }
    return _sLunciData;
}
- (NSMutableArray *)sDiquData {
    if (!_sDiquData) {
        _sDiquData = [NSMutableArray array];
    }
    return _sDiquData;
}
- (NSMutableArray *)sLiangdianData {
    if (!_sLiangdianData) {
        _sLiangdianData = [NSMutableArray array];
    }
    return _sLiangdianData;
}
@end


/*****************************************************************************/

@interface HomeFilterHeaderView()
@end
@implementation HomeFilterHeaderView
- (instancetype)init {
    self = [super init];
    if (self) {
        
//        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, kHomeFilterHeaderViewHeight, SCREENW,0.5)];
//        line.backgroundColor = LIST_LINE_COLOR;
//        [self addSubview:line];
        
        CALayer *layer = [[CALayer alloc] init];
        layer.frame = CGRectMake(0, kHomeFilterHeaderViewHeight, SCREENW,0.5);
        layer.backgroundColor = [LIST_LINE_COLOR CGColor];
        [self.layer addSublayer:layer];
    }
    return self;
}
- (instancetype)initWithTitles:(NSArray *)titles {
    self = [self init];
    if (self) {
        self.titles = titles;
    }
    return self;
}

- (void)itemButtonClick:(UIButton *)button {
    if (![ToLogin canEnterDeep]) {
        [ToLogin accessEnterDeep];
        return;
    }
    
    // 认证限制
    if (![PublicTool userisCliamed]) {
        if ([WechatUserInfo shared].claim_type.integerValue != 1) {
            [QMPEvent event:@"personku_noclaim_alert"];
        }
        return;
    }
    
    BOOL needRefresh = NO;
    
    BOOL oldStatus = self.filterViewIsShow;
    if (self.filterViewIsShow) { // 展开状态，
        if (self.currentButton == button) {
            // 隐藏
            self.filterViewIsShow = NO;
            button.selected = NO;
            self.currentButton = nil;
        } else { 
            self.currentButton.selected = NO;
            button.selected = YES;
            self.currentButton = button;
        }
        
    } else {
        button.selected = YES;
        self.currentButton = button;
        self.filterViewIsShow = YES;
    }
    
    needRefresh = oldStatus != self.filterViewIsShow;
    
    if ([self.delegate respondsToSelector:@selector(homeFilterHeaderView:itemButtonClick:needRefresh:)]) {
        [self.delegate homeFilterHeaderView:self itemButtonClick:button needRefresh:needRefresh];
    }
}
- (void)setTitles:(NSArray *)titles {
    _titles = titles;
    
    [self refreshViews];
}
- (void)refreshViews {
    
    NSInteger max = self.titles.count;
    CGFloat w = SCREENW / max;
    for (NSInteger i = 0; i < max; i++) {
        UIButton *button = [[UIButton alloc] init];
        button.frame = CGRectMake(w*i, 0, w, kHomeFilterHeaderViewHeight-0.5);
        button.titleLabel.font = [UIFont systemFontOfSize:15];
        button.tag = i;
        [button setTitle:self.titles[i] forState:UIControlStateNormal];
        [button setTitleColor:COLOR2D343A forState:UIControlStateNormal];
        [button setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateSelected];
        [button setImage:[UIImage imageNamed:@"tmp_filter_arrow"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"tmp_filter_arrow_up"] forState:UIControlStateSelected];
        [button addTarget:self action:@selector(itemButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        button.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        
        [button.titleLabel sizeToFit];
        button.imageEdgeInsets = UIEdgeInsetsMake(0, button.titleLabel.width+2, 0, -button.titleLabel.width-2);
        button.titleEdgeInsets = UIEdgeInsetsMake(0, -button.imageView.width-2, 0, button.imageView.width+2);
        
        [self addSubview:button];
    }
    
}
@end

