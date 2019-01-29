//
//  QMPTagDetailViewController.m
//  qmp_ios
//
//  Created by QMP on 2018/9/12.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "QMPTagDetailViewController.h"
#import "HapMapAreaModel.h"
#import "TuPuDetailController.h"
@interface QMPTagDetailViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *sections;

@end

@implementation QMPTagDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.collectionView];
    [self showHUD];
    [self requestData];

    self.navigationItem.title = self.name;
    
    UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 20)];
    [rightButton setTitle:[NSString stringWithFormat:@"项目(%@)", self.count] forState:UIControlStateNormal];
    rightButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    rightButton.titleLabel.font = [UIFont systemFontOfSize:14.f];
    [rightButton setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(rightButtonClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = item;

}
- (void)rightButtonClick {
    TuPuDetailController *vc = [[TuPuDetailController alloc] init];
    vc.tagStr = self.name;
    [[PublicTool topViewController].navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)requestData{
    if (![super requestData]) {
        return NO;
    }
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:-24*60*60];
    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    f.dateFormat = @"yyyy-MM-dd";
    NSString *d = [f stringFromDate:date];
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setValue:d forKey:@"date"];
    [param setValue:self.name forKey:@"tag"];
    
    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"Rank/getTupuTagRankByField2" HTTPBody:param completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        [self hideHUD];
        [self.collectionView.mj_header endRefreshing];
        if (resultData && [resultData isKindOfClass:[NSArray class]]) {
            self.sections = [NSMutableArray arrayWithArray:resultData];
            [self.collectionView reloadData];
        }
        
    }];
    
    return YES;
}
#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.sections.count;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSDictionary *dict = self.sections[section];
    NSArray *arr = dict[@"list"];
    return arr.count;
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UICollectionViewCellID" forIndexPath:indexPath];
    
    cell.contentView.backgroundColor = H568COLOR;
    
    NSDictionary *sectionDict = self.sections[indexPath.section];
    NSArray *arr = sectionDict[@"list"];
    NSDictionary *dict = arr[indexPath.row];
    
    CGFloat w = (SCREENW - 32 - 28) / 3.0;
    
    UILabel *label = [cell.contentView viewWithTag:123];
    if (!label) {
        label = [[UILabel alloc] init];
        label.frame = CGRectMake(10, 11, w-20, 17);
        label.font = [UIFont systemFontOfSize:13];
        label.textColor = COLOR2D343A;
        label.tag = 123;
        [cell.contentView addSubview:label];
    }
    label.text = dict[@"tag"];

    
    UILabel *rateLabel = [cell.contentView viewWithTag:456];
    if (!rateLabel) {
        rateLabel = [[UILabel alloc] init];
        rateLabel.frame = CGRectMake(10, 35, w-20, 13);
        if (@available(iOS 8.2, *)) {
            rateLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
        }else{
            rateLabel.font = [UIFont systemFontOfSize:13];
        }
        rateLabel.textColor = COLOR2D343A;
        rateLabel.tag = 456;
        [cell.contentView addSubview:rateLabel];
    }
//    rateLabel.text = [NSString stringWithFormat:@"%u.%u", arc4random()%20+70, arc4random()%9];
    rateLabel.text = dict[@"hot_index"];
    
    BOOL flag = arc4random()%10 > 5;
    flag = [dict[@"hot_change"] hasPrefix:@"-"];
    rateLabel.textColor = flag? HTColorFromRGB(0x06AF4C) : HTColorFromRGB(0xEA4756);
    
    
    [rateLabel sizeToFit];
    rateLabel.frame = CGRectMake(10, 35, rateLabel.width, 13);
    
    UIImageView *iconView = [cell.contentView viewWithTag:789];
    if (!iconView) {
        iconView = [[UIImageView alloc] init];
        iconView.frame = CGRectMake(0, 0, 18, 10);
        iconView.tag = 789;
        [cell.contentView addSubview:iconView];
    }
    iconView.image = [UIImage imageNamed:flag?@"tag_down":@"tag_up"];
    iconView.left = rateLabel.right + 3;
    iconView.centerY = rateLabel.centerY;
    
    
    UILabel *countLabel = [cell.contentView viewWithTag:666];
    if (!countLabel) {
        countLabel = [[UILabel alloc] init];
        countLabel.frame = CGRectMake(10, 56, w-20, 10);
        countLabel.font = [UIFont systemFontOfSize:10];
        countLabel.textColor = H9COLOR;
        countLabel.tag = 666;
        [cell.contentView addSubview:countLabel];
    }
    countLabel.text = [NSString stringWithFormat:@"%@项目", dict[@"count"]];
    
    return cell;
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if (kind == UICollectionElementKindSectionHeader) {
        
        
        UICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"123" forIndexPath:indexPath];
        
        
        CGFloat h = 55;
        
        NSDictionary *sectionDict = self.sections[indexPath.section];
        
        UIImageView *aView = [view viewWithTag:987];
        if (!aView) {
            aView = [[UIImageView alloc] init];
            aView.frame = CGRectMake(16, (h-15)/2.0, 2, 15);
            aView.tag = 987;
            aView.backgroundColor = HTColorFromRGB(0x006EDA);
            [view addSubview:aView];
        }
        
        UIImageView *bView = [view viewWithTag:654];
        if (!bView) {
            bView = [[UIImageView alloc] init];
            bView.frame = CGRectMake(SCREENW-16-10, (h-16)/2.0, 10, 16);
            bView.tag = 654;
            bView.image = [UIImage imageNamed:@"leftarrow_gray"];
            [view addSubview:bView];
        }
        
        
        UILabel *label = [view viewWithTag:123];
        if (!label) {
            label = [[UILabel alloc] init];
            label.frame = CGRectMake(10, 11, 20, 17);
            if (@available(iOS 8.2, *)) {
                label.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
            }else{
                label.font = [UIFont systemFontOfSize:14];
            }
            label.textColor = COLOR2D343A;
            label.tag = 123;
            [view addSubview:label];
        }
        label.text = sectionDict[@"tag"];
        [label sizeToFit];
        label.frame = CGRectMake(24, (h-17)/2.0, label.width, 17);
        
        UILabel *rateLabel = [view viewWithTag:456];
        if (!rateLabel) {
            rateLabel = [[UILabel alloc] init];
            rateLabel.frame = CGRectMake(10, 35, 20, 13);
            if (@available(iOS 8.2, *)) {
                rateLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
            }else{
                rateLabel.font = [UIFont systemFontOfSize:13];
            }
            rateLabel.textColor = COLOR2D343A;
            rateLabel.tag = 456;
            [view addSubview:rateLabel];
        }
//        rateLabel.text = [NSString stringWithFormat:@"%u.%u", arc4random()%20+70, arc4random()%9];
        rateLabel.text = sectionDict[@"hot_index"];
        
        BOOL flag = arc4random()%10 > 5;
        flag = [sectionDict[@"hot_change"] hasPrefix:@"-"];
        rateLabel.textColor = flag? HTColorFromRGB(0x06AF4C) : HTColorFromRGB(0xEA4756);
        
        [rateLabel sizeToFit];
        rateLabel.frame = CGRectMake(label.right+8, (h-13)/2.0, rateLabel.width, 13);
        
        UIImageView *iconView = [view viewWithTag:789];
        if (!iconView) {
            iconView = [[UIImageView alloc] init];
            iconView.frame = CGRectMake(0, 0, 18, 10);
            iconView.tag = 789;
            [view addSubview:iconView];
        }
        iconView.image = [UIImage imageNamed:flag?@"tag_down":@"tag_up"];
        iconView.left = rateLabel.right + 3;
        iconView.centerY = rateLabel.centerY;
        
        UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sectionHeaderViewTap:)];
        [view addGestureRecognizer:tapGest];
        view.tag = indexPath.section;
        return view;
    }
    UICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"123" forIndexPath:indexPath];
    view.backgroundColor = TABLEVIEW_COLOR;
    return view;
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    NSDictionary *sectionDict = self.sections[section];
    NSArray *arr = sectionDict[@"list"];
    if (arr.count > 0) {
        return UIEdgeInsetsMake(0, 16, 20, 16);
    }
    return UIEdgeInsetsMake(0, 16, 0, 16);
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *sectionDict = self.sections[indexPath.section];
    NSArray *arr = sectionDict[@"list"];
    NSDictionary *dict = arr[indexPath.row];
    
    TuPuDetailController *vc = [[TuPuDetailController alloc] init];
    vc.tagStr = dict[@"tag"];
    [[PublicTool topViewController].navigationController pushViewController:vc animated:YES];
}
- (void)sectionHeaderViewTap:(UITapGestureRecognizer *)tapGest {

    NSDictionary *sectionDict = self.sections[tapGest.view.tag];
    TuPuDetailController *vc = [[TuPuDetailController alloc] init];
    vc.tagStr = sectionDict[@"tag"];
    [[PublicTool topViewController].navigationController pushViewController:vc animated:YES];
}
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        CGFloat w = (SCREENW - 32 - 28) / 3.0;
        layout.itemSize = CGSizeMake(w, w * 80 / 105.0);
        layout.minimumLineSpacing = 14;
        layout.minimumInteritemSpacing = 14;
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        
        layout.headerReferenceSize = CGSizeMake(SCREENW, 55);
        layout.footerReferenceSize = CGSizeMake(SCREENW, 10);
        
        CGRect rect = CGRectMake(0, 0, SCREENW, SCREENH - kScreenTopHeight);
        _collectionView = [[UICollectionView alloc] initWithFrame:rect collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor whiteColor];
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCellID"];
        [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"123"];
        [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"123"];
    }
    return _collectionView;
}

@end
