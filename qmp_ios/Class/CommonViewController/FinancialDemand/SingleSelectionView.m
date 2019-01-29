//
//  SingleSelectionView.m
//  qmp_ios
//
//  Created by QMP on 2018/5/30.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "SingleSelectionView.h"


@interface SingleSelectionView()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property(nonatomic,strong)UICollectionView *collectionV;

@property(nonatomic,copy)NSString *keyTitle;
@property(nonatomic,copy)NSString *selectedTitle;
@property(nonatomic,strong)NSArray *titleArr;
@property (copy, nonatomic) void(^selectedTitleEvent)(NSString *title);

@end


@implementation SingleSelectionView

-(instancetype)initWithTitle:(NSString*)keyTitle selectionTitles:(NSArray*)titlesArr selectedTitle:(NSString*)selectedTitle selectedEvent:(void (^)(NSString *))selectedEvent{
    if (self = [super initWithFrame:KEYWindow.bounds]) {
        self.titleArr = titlesArr;
        self.keyTitle = keyTitle;
        self.selectedTitle = selectedTitle;
        self.selectedTitleEvent = selectedEvent;
        [self addView];
    }
    return self;
}

- (void)addView{
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(20, (kScreenTopHeight+40)*ratioWidth, SCREENW-40, SCREENH-(kScreenTopHeight+40)*ratioWidth-60*ratioWidth)];
    bgView.backgroundColor = [UIColor whiteColor];
    bgView.layer.cornerRadius = 10;
    bgView.layer.masksToBounds = YES;
    [self addSubview:bgView];
    
    CGFloat left  = 15;
    
    //KeyTitle
    UILabel *keyTitleLab = [[UILabel alloc]initWithFrame:CGRectMake(left, 0, 100, 60)];
    [keyTitleLab labelWithFontSize:16 textColor:NV_TITLE_COLOR];
    keyTitleLab.text = self.keyTitle;
    [bgView addSubview:keyTitleLab];
    
    UIButton *chaBtn = [[UIButton alloc]initWithFrame:CGRectMake(bgView.width-40, 0, 40, 50)];
    [chaBtn setImage:[UIImage imageNamed:@"web_close"] forState:UIControlStateNormal];
    [chaBtn addTarget:self action:@selector(removeFromSuperview) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:chaBtn];
    
    CGFloat itemW = (bgView.width - 15*2 - 15*4)/4;
    CGFloat itemH = 30;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.itemSize = CGSizeMake(itemW, itemH);
    layout.minimumLineSpacing = 15;
    layout.minimumInteritemSpacing = 15;
    layout.sectionInset = UIEdgeInsetsMake(5, left, 10, left);
    self.collectionV = [[UICollectionView alloc]initWithFrame:CGRectMake(0, keyTitleLab.bottom, bgView.width, bgView.height-keyTitleLab.bottom) collectionViewLayout:layout];
    self.collectionV.backgroundColor = [UIColor whiteColor];
    [self.collectionV registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"collectionViewCell"];
    self.collectionV.delegate = self;
    self.collectionV.dataSource = self;
    [bgView addSubview:self.collectionV];

    [KEYWindow addSubview:self];
    [self.collectionV reloadData];

}


#pragma mark --CollectionView--
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.titleArr.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"collectionViewCell" forIndexPath:indexPath];
    
    UILabel *lab = [cell viewWithTag:1000];
    if (!lab) {
        lab = [[UILabel alloc]initWithFrame:cell.bounds];
        lab.font = [UIFont systemFontOfSize:12];
        lab.textAlignment = NSTextAlignmentCenter;
        lab.numberOfLines = 2;
        lab.layer.cornerRadius = 4.f;
        lab.layer.borderColor = [BLUE_TITLE_COLOR CGColor];
        lab.layer.borderWidth = 0.5;

        lab.clipsToBounds = YES;
        lab.tag = 1000;
        [cell addSubview:lab];
    }
    NSString *labTitle = self.titleArr[indexPath.item];
    lab.text = labTitle;

    if ([self.selectedTitle isEqualToString:labTitle]) {
        lab.layer.borderColor = [BLUE_TITLE_COLOR CGColor];
        lab.backgroundColor = [UIColor whiteColor];
        lab.textColor = BLUE_TITLE_COLOR;
        
    }else{
        lab.layer.borderColor = [[UIColor clearColor] CGColor];
        lab.backgroundColor = HTColorFromRGB(0xf5f5f5);
        lab.textColor = H5COLOR;
    }
    return cell;
}



- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSString *labTitle = self.titleArr[indexPath.item];
    self.selectedTitle = labTitle;
    self.selectedTitleEvent(labTitle);
    [UIView performWithoutAnimation:^{
        [self.collectionV reloadData];
        
    }];

    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end
