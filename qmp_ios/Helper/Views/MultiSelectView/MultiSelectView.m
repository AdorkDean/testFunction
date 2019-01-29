//
//  MultiSelectView.m
//  qmp_ios
//
//  Created by QMP on 2018/5/12.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "MultiSelectView.h"
#import "MultiSelectCell.h"
#import "MultiSelectCell.h"

@interface MultiSelectView()<UICollectionViewDelegate,UICollectionViewDataSource>
{
    UICollectionView *_collectionView;
    ConfirmSelected _confirmSelected;
    CGFloat _selectHeight;
}

@property(nonatomic,strong)NSMutableArray *selectedArr;
@property(nonatomic,strong)NSArray *selectionArr;

@end


@implementation MultiSelectView

-(instancetype)initWithSelectionArr:(NSArray *)selectionArr selectedArr:(NSArray*)selectedArr confirmSelect:(ConfirmSelected)confirmSelected{
    
    if (self = [super init]) {
        self.selectionArr = selectionArr;
        self.selectedArr = [NSMutableArray arrayWithArray:selectedArr];
        _confirmSelected = confirmSelected;
        NSInteger row = selectionArr.count/3.0 + (selectionArr.count%3 ? 1:0);
        CGFloat height = row * (36 + 20) + 20 + 65;
        self.frame = KEYWindow.bounds;
        _selectHeight = height;
        [self addView];
    }
    return self;
}


- (void)addView{
    
    CGFloat viewW = self.frame.size.width;
    CGFloat viewH = self.frame.size.height;
    self.backgroundColor = [UIColor clearColor];
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewW, viewH)];
    backgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    backgroundView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeView)];
    [backgroundView addGestureRecognizer:tap];
    
    [self addSubview:backgroundView];
    
    
    //下半部分有用的view,以动画形式展现
    CGFloat chooseH = _selectHeight;
    CGFloat confirmH = 47.f;
    CGFloat collectH = _selectHeight - confirmH;
    
    UIView *chooseView = [[UIView alloc] initWithFrame:CGRectMake(0, viewH, viewW, chooseH)];
    chooseView.backgroundColor = [UIColor whiteColor];
    [self addSubview:chooseView];
    
    
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, confirmH)];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton setTitleColor:RGBblackColor forState:UIControlStateNormal];
    [cancelButton setTitleColor:H9COLOR forState:UIControlStateDisabled];
    cancelButton.titleLabel.font = [UIFont systemFontOfSize:16.f];
    [cancelButton addTarget:self action:@selector(pressCancleBtn:) forControlEvents:UIControlEventTouchUpInside];
    [chooseView addSubview:cancelButton];
    
    UIButton *confirmBtn = [[UIButton alloc] initWithFrame:CGRectMake(viewW - 70, 0, 70, confirmH)];
    [confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
    [confirmBtn setTitleColor:RGBblackColor forState:UIControlStateNormal];
    confirmBtn.titleLabel.font = [UIFont systemFontOfSize:16.f];
    [confirmBtn addTarget:self action:@selector(pressConfirmBtn:) forControlEvents:UIControlEventTouchUpInside];
    [chooseView addSubview:confirmBtn];
   
    CGFloat lineX = 10.f;
    UIView *linveV = [[UIView alloc] initWithFrame:CGRectMake(lineX, confirmH-0.5, viewW  - lineX * 2, 0.5f)];
    linveV.backgroundColor = LIST_LINE_COLOR;
    [chooseView addSubview:linveV];
    
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, confirmH, viewW, collectH) collectionViewLayout:layout];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.backgroundColor = [UIColor whiteColor];
    collectionView.scrollEnabled = NO;
    [chooseView addSubview:collectionView];
    _collectionView = collectionView;
    
    [_collectionView registerClass:[MultiSelectCell class] forCellWithReuseIdentifier:@"MultiSelectCellID"];
    

    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        CGRect frame = chooseView.frame;
        frame.origin.y = viewH - chooseView.height;
        chooseView.frame = frame;
        
    } completion:^(BOOL finished) {
        
    }];
}

- (void)removeView{
    
    [self removeFromSuperview];
}

- (void)pressCancleBtn:(UIButton *)sender{
   
    [self removeFromSuperview];
}


- (void)pressConfirmBtn:(UIButton *)sender{
    
   
    _confirmSelected([self.selectedArr componentsJoinedByString:@"|"]);
    [self removeFromSuperview];
}

- (void)pressWorkFlowBtn:(UIButton *)sender{
    
    NSString *title = sender.titleLabel.text;
    if ([self.selectedArr containsObject:title]) {
        [self.selectedArr removeObject:title];
    }else{
        [self.selectedArr addObject:title];
    }
    
    [UIView performWithoutAnimation:^{
        [_collectionView reloadData];

    }];
}

#pragma mark - collectView
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return self.selectionArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    MultiSelectCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MultiSelectCellID" forIndexPath:indexPath];

    cell.industryBtn.tag = indexPath.item + 1000;
    NSString *title = self.selectionArr[indexPath.item];
    if ([self.selectedArr containsObject:title]) {
        [cell.industryBtn setTitle:title forState:UIControlStateNormal];
        cell.industryBtn.backgroundColor = BLUE_TITLE_COLOR;
        cell.industryBtn.selected = YES;

    }
    else{
        [cell.industryBtn setTitle:title forState:UIControlStateNormal];
        cell.industryBtn.backgroundColor = TABLEVIEW_COLOR;
        cell.industryBtn.selected = NO;
    }

    cell.industryBtn.titleLabel.font = [UIFont systemFontOfSize:14.f];
    [cell.industryBtn addTarget:self action:@selector(pressWorkFlowBtn:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    CGFloat W = (self.width - 20 * 4 ) / 3;
    return CGSizeMake(W, 40.f);
}
- (UIEdgeInsets) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(20, 10, 0, 10);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    
    return 20.f;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    
    return 10.f;
}

@end
