//
//  InvestementFilterView.m
//  qmp_ios
//
//  Created by Molly on 2016/12/1.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import "InvestementFilterView.h"

#import "DrawerViewCollectionViewCell.h"

#import "IndustryItem.h"
 
#import "ManagerHud.h"
#import "TestNetWorkReached.h"


@interface InvestementFilterView()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>{
    
    NSString *_tableName;
    NSString *_lunciTableName;
    NSString *dbPath;
    
}

@property (strong, nonatomic) UIView *backgroundView;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UIButton *resetBtn;
@property (strong, nonatomic) UIButton *confirmBtn;
@property (strong, nonatomic) NSMutableDictionary *requestDict;

@property (strong, nonatomic) FMDatabase *db;
@property (strong, nonatomic) NSArray *industryArr;
@property (strong, nonatomic) NSMutableArray *selectedMArr;

@property (strong, nonatomic) NSArray *lunciArr;
@property (strong, nonatomic) NSMutableArray *selectedLunciMArr;
@property (strong, nonatomic) NSString *cellIdentifier;

@property (strong, nonatomic) ManagerHud *hud;

@end

@implementation InvestementFilterView

- (void)dealloc{
    
    if (_db) {
        [_db close];
    }
}

+ (InvestementFilterView *)initWithFrame:(CGRect)frame withSelectMArr:(NSMutableArray *)selectMArr withHangyeArr:(NSArray *)hangyeArr{
    
    InvestementFilterView *drawerView = [[InvestementFilterView alloc] initWithFrame:frame];
    drawerView.industryArr = [NSMutableArray arrayWithArray:hangyeArr];
    drawerView.selectedMArr = [NSMutableArray arrayWithArray:selectMArr];
    [drawerView initView];
    [drawerView.collectionView reloadData];
    
    return drawerView;
}

+ (InvestementFilterView *)initWithFrame:(CGRect)frame withSelectMArr:(NSMutableArray *)selectMArr withHangyeArr:(NSArray *)hangyeArr withSelectLunciMArr:(NSMutableArray*)selectLunciMArr withLunciArr:(NSArray*)lunciArr{
    
    InvestementFilterView *drawerView = [[InvestementFilterView alloc] initWithFrame:frame];
    drawerView.industryArr = [NSMutableArray arrayWithArray:hangyeArr];
    drawerView.selectedMArr = [NSMutableArray arrayWithArray:selectMArr];
    drawerView.lunciArr = [NSMutableArray arrayWithArray:lunciArr];
    drawerView.selectedLunciMArr = [NSMutableArray arrayWithArray:selectLunciMArr];
    [drawerView initView];
    [drawerView.collectionView reloadData];
    
    return drawerView;
}

+ (InvestementFilterView *)initWithFrame:(CGRect)frame withSelectMArr:(NSMutableArray *)selectMArr withRequestDict:(NSMutableDictionary *)dict{
    
    InvestementFilterView *drawerView = [[InvestementFilterView alloc] initWithFrame:frame];
    drawerView.selectedMArr = selectMArr;
    drawerView.requestDict = dict;
    
    [drawerView initView:dict withSelectMArr:selectMArr];
    return drawerView;
}

- (void)initView:(NSMutableDictionary *)dict withSelectMArr:(NSMutableArray *)selectMArr{
    
    [self initView];
    
    [self requestIndustryWithDict:dict withSelectMArr:selectMArr];
}

- (void)initView{
    
    CGFloat viewW = self.frame.size.width;
    CGFloat viewH = self.frame.size.height;
    self.backgroundColor = [UIColor clearColor];
    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(removeFilterVWhenSwipe:)];
    swipe.numberOfTouchesRequired = 1;
    swipe.direction = UISwipeGestureRecognizerDirectionRight;
    [self addGestureRecognizer:swipe];
    
    _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewW, viewH)];
    _backgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeFilterV:)];
    [_backgroundView addGestureRecognizer:tap];
    
    [self addSubview:_backgroundView];
    
    CGFloat rightViewX = 75.f;
    CGFloat righrViewW = viewW - rightViewX;
    _rightView = [[UIView alloc] initWithFrame:CGRectMake(SCREENW, 0, righrViewW, viewH)];
    _rightView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_rightView];
    
    CGFloat margin = 20.f;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    _collectionView =[ [UICollectionView alloc] initWithFrame:CGRectMake(0, 0, righrViewW, viewH -49) collectionViewLayout:layout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = [UIColor whiteColor];
    _cellIdentifier = @"DrawerViewCollectionViewCell";
    [_collectionView registerClass:[DrawerViewCollectionViewCell class] forCellWithReuseIdentifier:_cellIdentifier];
    [_rightView addSubview:_collectionView];
    
    [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headerViewID"];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, viewH - 50, viewW, 1)];
    lineView.backgroundColor = RGBLineGray;
    [_rightView addSubview:lineView];
    
    CGFloat btnH = 49.f;
    _resetBtn = [[UIButton alloc] initWithFrame:CGRectMake(0,lineView.frame.origin.y+0.5 , (SCREENW-85*ratioWidth)/2.0, btnH)];
    _resetBtn.backgroundColor = [UIColor whiteColor];
    [_resetBtn setTitle:@"重置" forState:UIControlStateNormal];
    [_resetBtn setTitleColor:H5COLOR  forState:UIControlStateNormal];
    [_resetBtn addTarget:self action:@selector(pressResetBtn:) forControlEvents:UIControlEventTouchUpInside];
    [_rightView addSubview:_resetBtn];
    
    _confirmBtn = [[UIButton alloc] initWithFrame:CGRectMake(_resetBtn.right, lineView.frame.origin.y, (SCREENW-85*ratioWidth)/2.0, btnH)];
    _confirmBtn.backgroundColor = BLUE_TITLE_COLOR;
    [_confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
    [_confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_confirmBtn addTarget:self action:@selector(pressConfirmBtn:) forControlEvents:UIControlEventTouchUpInside];
    [_rightView addSubview:_confirmBtn];
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        CGRect rightFrame = _rightView.frame;
        rightFrame.origin.x = rightViewX;
        _rightView.frame = rightFrame;
        
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark -请求行业
- (void)requestIndustryWithDict:(NSMutableDictionary *)dict withSelectMArr:(NSMutableArray *)selectMArr{
    
    if ([TestNetWorkReached networkIsReachedAlertOnView:self]) {
        
        [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:@"d/tzpic" HTTPBody:dict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
           
            if (resultData && [resultData isKindOfClass:[NSDictionary class]]) {
               
                NSMutableArray *retMArr = [NSMutableArray array];
               
                NSArray *dataArr = [[[resultData objectForKey:@"hangye"] objectForKey:@"pie"] objectForKey:@"data"];
                
                for (NSArray *oneData in dataArr) {
                    IndustryItem *item = [[IndustryItem alloc] init];
                    item.name = oneData[0];
                    
                    if (selectMArr && [selectMArr containsObject:item.name]) {
                        item.selected = @"1";
                    }
                    else{
                        
                        item.selected = @"0";
                    }
                    [retMArr addObject:item];
                    
                }
                
                self.industryArr = [NSMutableArray arrayWithArray:retMArr];
                [self.collectionView reloadData];
            }
        }];
    }
}

- (void)pressResetBtn:(UIButton *)sender{
    [QMPEvent event:@"filter_reset_click"];

    [self.selectedMArr removeAllObjects];
    for (int i = 0 ; i < self.industryArr.count; i++) {
        IndustryItem *item = self.industryArr[i];
        if ([item.selected isEqualToString:@"1"]) {
            item.selected = @"0";
        }
    }
    [self.selectedLunciMArr removeAllObjects];
    for (int i = 0 ; i < self.lunciArr.count; i++) {
        IndustryItem *item = self.lunciArr[i];
        if ([item.selected isEqualToString:@"1"]) {
            item.selected = @"0";
        }
    }
    
    [self.collectionView reloadData];
}


- (void)removeFilterV:(UITapGestureRecognizer *)tap{
    [self removeViewWithAni];
    [self confirmFilter];
}

- (void)removeFilterVWhenSwipe:(UISwipeGestureRecognizer *)tap{
    
    [UIView animateWithDuration:0.5 delay:0.2 options:UIViewAnimationOptionCurveEaseOut animations:^{
        _backgroundView.alpha = 0;
        
        CGRect rightFrame = _rightView.frame;
        rightFrame.origin.x = SCREENW ;
        _rightView.frame = rightFrame;
        
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        
    }];
    [self confirmFilter];
}

- (void)removeViewWithAni{
    
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [_backgroundView removeFromSuperview];
        
        CGRect rightFrame = _rightView.frame;
        rightFrame.origin.x = SCREENW ;
        _rightView.frame = rightFrame;
        
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        
    }];
    
}
- (void)pressConfirmBtn:(UIButton *)sender{
    
    [self removeViewWithAni];
    [self confirmFilter];
    
}

- (void)confirmFilter{
    
    if ([self.delegate respondsToSelector:@selector(updateRongziNews:lunciArr:)]) {
        
        [self.delegate updateRongziNews:self.selectedMArr lunciArr:self.selectedLunciMArr];
    }
}

- (void)pressInductryBtn:(UIButton *)sender{ //支持多选
    
    if (sender.tag == 1000) { //行业
        BOOL selected = !sender.selected;
        sender.selected = selected;
        for (int i = 0 ; i < self.industryArr.count; i++) {
            IndustryItem *item = self.industryArr[i];
//            if ([item.selected isEqualToString:@"1"]) {
//                item.selected = @"0";
//            }
            if ([item.name isEqualToString:sender.titleLabel.text]) {
                item.selected = [NSString stringWithFormat:@"%ld",1-item.selected.integerValue];
            }
        }
//        [self.selectedMArr removeAllObjects];
        if (selected) {
            [self.selectedMArr addObject:sender.titleLabel.text];
            
        }else{
            [self.selectedMArr removeObject:sender.titleLabel.text];
        }
        [self.collectionView reloadData];
        
    }else{
        //轮次
        BOOL selected = !sender.selected;
        sender.selected = selected;
        for (int i = 0 ; i < self.lunciArr.count; i++) {
            IndustryItem *item = self.lunciArr[i];
//            if ([item.selected isEqualToString:@"1"]) {
//                item.selected = @"0";
//            }
            if ([item.name isEqualToString:sender.titleLabel.text]) {
                item.selected = [NSString stringWithFormat:@"%ld",1-item.selected.integerValue];
            }
        }
//        [self.selectedLunciMArr removeAllObjects];
        if (selected) {
            [self.selectedLunciMArr addObject:sender.titleLabel.text];
            
        }else{
            [self.selectedLunciMArr removeObject:sender.titleLabel.text];
        }
        [self.collectionView reloadData];
    }
    
}
#pragma mark - collectView
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    return 2;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (section == 0) {
        return self.industryArr.count;
    }
    return self.lunciArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        
        DrawerViewCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:_cellIdentifier forIndexPath:indexPath];
        
        IndustryItem *industryItem = self.industryArr[indexPath.row];
        
        UIColor *titleColor;
        if (self.selectedMArr && [self.selectedMArr containsObject:industryItem.name]) {

            //        cell.industryBtn.backgroundColor = RED_TEXTCOLOR;
            cell.industryBtn.layer.borderColor = [BLUE_TITLE_COLOR CGColor];
            cell.industryBtn.backgroundColor = [UIColor whiteColor];
            titleColor = BLUE_TITLE_COLOR;
            cell.industryBtn.selected = YES;
        }
        else{
            cell.industryBtn.layer.borderColor = [H999999 CGColor];
            cell.industryBtn.selected = NO;
            titleColor = H3COLOR;
            
        }
        [cell.industryBtn setTitleColor:titleColor forState:UIControlStateNormal];
        [cell.industryBtn setTitle:industryItem.name forState:UIControlStateNormal];

        cell.industryBtn.tag = 1000;
        [cell.industryBtn addTarget:self action:@selector(pressInductryBtn:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
        
    }else{
        
        DrawerViewCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:_cellIdentifier forIndexPath:indexPath];
        
        IndustryItem *industryItem = self.lunciArr[indexPath.row];
        
            UIColor *titleColor;
        if (self.selectedLunciMArr && [self.selectedLunciMArr containsObject:industryItem.name]) {

            cell.industryBtn.layer.borderColor = [BLUE_TITLE_COLOR CGColor];
            cell.industryBtn.backgroundColor = [UIColor whiteColor];
            titleColor = BLUE_TITLE_COLOR;
            cell.industryBtn.selected = YES;
        }
        else{
            cell.industryBtn.layer.borderColor = [H999999 CGColor];
            cell.industryBtn.selected = NO;
            titleColor = H3COLOR;
            
        }
        [cell.industryBtn setTitleColor:titleColor forState:UIControlStateNormal];
        [cell.industryBtn setTitle:industryItem.name forState:UIControlStateNormal];

        cell.industryBtn.tag = 2000;

        [cell.industryBtn addTarget:self action:@selector(pressInductryBtn:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    CGFloat W = (_rightView.frame.size.width - 20 * 4 ) / 3-1;

    if (indexPath.section == 0) {
        IndustryItem *industryItem = self.industryArr[indexPath.row];
        CGFloat width = [PublicTool widthOfString:industryItem.name height:CGFLOAT_MAX fontSize:12] + 10;
        if (width <= W) {
            width = W;
        }
        return CGSizeMake(width, 25);
    }
    
    return CGSizeMake(W, 25.f);
}

- (UIEdgeInsets) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 20, 10, 20);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    
    return 12.f;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    
    return 20.f;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    
    return CGSizeMake(SCREENW, 45);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeZero;
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headerViewID" forIndexPath:indexPath];
        UILabel *titleLab = [headerView viewWithTag:1001];
        if (!titleLab) {
            titleLab = [[UILabel alloc]initWithFrame:CGRectMake(17, 0, 90, 45)];
            [titleLab labelWithFontSize:16 textColor:NV_OTHERTITLE_COLOR];
            titleLab.tag = 1001;
            [headerView addSubview:titleLab];
        }
        if (indexPath.section == 0) {
            titleLab.text = @"领域";
        }else {
            titleLab.text = @"轮次";

        }
        return headerView;
    }
    return nil;
}
#pragma mark - 懒加载
- (NSArray *)industryArr{
    
    if (!_industryArr) {
        _industryArr = [[NSArray alloc] init];
    }
    return _industryArr;
}
- (NSMutableArray *)selectedMArr{
    
    if (!_selectedMArr) {
        _selectedMArr = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _selectedMArr;
}

- (NSArray *)lunciArr{
    
    if (!_lunciArr) {
        _lunciArr = [[NSArray alloc] init];
    }
    return _lunciArr;
}

- (NSMutableArray *)selectedLunciMArr{
    
    if (!_selectedLunciMArr) {
        _selectedLunciMArr = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _selectedLunciMArr;
}

@end
