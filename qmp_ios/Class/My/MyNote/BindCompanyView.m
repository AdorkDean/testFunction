//
//  BindCompanyView.m
//  qmp_ios
//
//  Created by QMP on 2018/4/4.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "BindCompanyView.h"
#import "SearchBindProController.h"
#import "BindCompanyItem.h"

@interface BindCompanyView()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
{
    UILabel *_bindLabel;
    NSMutableArray *_attentProArr;
}
@property(nonatomic,strong)UICollectionView *collectView;
@end


@implementation BindCompanyView


-(instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        [self addView];
    }
    return self;
}

- (void)addView{
    
    UIButton *bindBtn = [[UIButton alloc]initWithFrame:CGRectMake(15, 0, 18, 18)];
    [bindBtn setImage:[UIImage imageNamed:@"note_bindIcon"] forState:UIControlStateNormal];
    [self addSubview:bindBtn];
    bindBtn.centerY = self.height/2.0;
    
    _bindLabel = [[UILabel alloc]initWithFrame:CGRectMake(38, 0, 60, 45)];
    [_bindLabel labelWithFontSize:14 textColor:H5COLOR];
    _bindLabel.text = @"关联项目";
    [self addSubview:_bindLabel];
    _bindLabel.centerY = self.height/2.0;
    _bindLabel.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(bindProductClick)];
    [self addGestureRecognizer:tap];
    
    UIImageView *imgV = [[UIImageView alloc]initWithFrame:CGRectMake(SCREENW - 44, 0, 44, 45)];
    imgV.image = [UIImage imageNamed:@"leftarrow_gray"];
    imgV.contentMode = UIViewContentModeCenter;
    [self addSubview:imgV];
    imgV.tag = 900;
    imgV.centerY = self.height/2.0;

    
    //
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.minimumInteritemSpacing = 0;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
   
    _collectView = [[UICollectionView alloc]initWithFrame:CGRectMake(_bindLabel.right, 5, self.width - _bindLabel.right - 55, self.height-10) collectionViewLayout:layout];
    _collectView.backgroundColor = [UIColor whiteColor];
    [_collectView registerNib:[UINib nibWithNibName:@"BindCompanyItem" bundle:nil] forCellWithReuseIdentifier:@"BindCompanyItemID"];
    _collectView.delegate = self;
    _collectView.dataSource = self;
    [self addSubview:_collectView];
    _collectView.hidden = YES;
    
}

- (void)reloadCollectionData{
    
    if (self.selectedCompArr.count) {
        _collectView.hidden = NO;
        [_collectView reloadData];
    }
}

- (void)setNotShowDelBtn:(BOOL)notShowDelBtn{
    _notShowDelBtn = notShowDelBtn;
    [[self viewWithTag:900] setHidden:_notShowDelBtn];
    if (self.selectedCompArr.count) {
        _collectView.hidden = NO;
        [_collectView reloadData];
    }
}

- (void)bindProductClick{
    
    if (self.selectedCompArr.count == 5) {
        [PublicTool showMsg:@"最多关联5个项目"];
        return ;
    }
    SearchBindProController *searchVC = [[SearchBindProController alloc]init];
    
    __weak typeof(self) weakSelf = self;
    searchVC.selectedProduct = ^(SearchCompanyModel *company) {
        
        for (NSString *selectedName in weakSelf.selectedCompArr) {
            if ([company.product isEqualToString:selectedName]) {
                return;
            }
        }
//        [weakSelf.totalCompanyArr addObject:company];
//        [weakSelf.selectedCompArr addObject:company.product];
//        if (weakSelf.companyCount == 1) {
//            [weakSelf.totalCompanyArr removeAllObjects];
//            [weakSelf.selectedCompArr removeAllObjects];
//
//            [weakSelf.totalCompanyArr addObject:company];
//            [weakSelf.selectedCompArr addObject:company.product];
//
//
//        }
        [weakSelf.totalCompanyArr removeAllObjects];
        [weakSelf.selectedCompArr removeAllObjects];
        
        [weakSelf.totalCompanyArr addObject:company];
        [weakSelf.selectedCompArr addObject:company.product];
        
        weakSelf.collectView.hidden = NO;
        [weakSelf.collectView reloadData];
        [weakSelf.collectView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.selectedCompArr.count-1 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    };
    
    [[PublicTool topViewController].navigationController pushViewController:searchVC animated:NO];
    
}



#pragma mark --UICollectionViewDelegate--
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    
    return 0.1;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    
    return 0.1;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(self.height-10, self.height-10);
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.selectedCompArr.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    BindCompanyItem *companyItem = [collectionView dequeueReusableCellWithReuseIdentifier:@"BindCompanyItemID" forIndexPath:indexPath];
    NSString *productName = self.selectedCompArr[indexPath.item];
    for (SearchCompanyModel *model in self.totalCompanyArr) {
        if ([productName isEqualToString:model.product]) {
            [companyItem.loginView sd_setImageWithURL:[NSURL URLWithString:model.icon] placeholderImage:[UIImage imageNamed:PROICON_DEFAULT]];
        }
        
    }
    companyItem.deleteBtn.tag = 1000 + indexPath.item;
    [companyItem.deleteBtn addTarget:self action:@selector(deleteBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    companyItem.deleteBtn.hidden = self.notShowDelBtn;
    return companyItem;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (void)deleteBtnClick:(UIButton*)btn{
    
    NSInteger index = btn.tag - 1000;
    
    [self.selectedCompArr removeObjectAtIndex:index];
    [_collectView reloadData];
}
@end
