//
//  QMPDataGraphViewController.m
//  qmp_ios_v2.0
//
//  Created by QMP on 2018/9/6.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "QMPDataGraphViewController.h"
#import "QMPTagDetailViewController.h"
@interface QMPDataGraphViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *tagData;
@end

@implementation QMPDataGraphViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"图谱";
    [self.view addSubview:self.collectionView];
    
    [self showHUD];
    [self requestData];
}
    
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)refreshCallback:(void (^)(void))refreshComplated {
    self.refreshComplated = refreshComplated;
    [self requestData];
}
- (BOOL)requestData {
    if (![super requestData]) {
        return NO;
    }
    
    NSDate *date = [NSDate dateYesterday];
    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    f.dateFormat = @"yyyy-MM-dd";
    NSString *d = [f stringFromDate:date];
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setValue:d forKey:@"date"];
    
    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"Rank/getTupuTagRankByField1" HTTPBody:param completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        [self hideHUD];
        if (self.refreshComplated) {
            self.refreshComplated();
        }
        if (resultData && [resultData isKindOfClass:[NSArray class]]) {
            self.tagData = [NSMutableArray arrayWithArray:resultData];
            [self.collectionView reloadData];
        }
    }];
    
    return YES;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.tagData.count;
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UICollectionViewCellID" forIndexPath:indexPath];
    
    cell.contentView.backgroundColor = H568COLOR;
    
    NSDictionary *dict = self.tagData[indexPath.row];
    
    CGFloat w = (SCREENW - 32 - 28) / 3.0;
    
    UILabel *label = [cell.contentView viewWithTag:123];
    if (!label) {
        label = [[UILabel alloc] init];
        label.frame = CGRectMake(10, 11, w-20, 17);
        label.font = [UIFont systemFontOfSize:13];
        label.textColor = H3COLOR;
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
        rateLabel.textColor = H3COLOR;
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
    
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dict = self.tagData[indexPath.row];
    if ([PublicTool isNull:dict[@"tag"]]) {
        return;
    }
    QMPTagDetailViewController *vc = [[QMPTagDetailViewController alloc] init];
    vc.name = dict[@"tag"];
    vc.count = dict[@"count"];
    [[PublicTool topViewController].navigationController pushViewController:vc animated:YES];
}
#pragma mark - Getter
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        CGFloat w = (SCREENW - 32 - 28) / 3.0;
        layout.itemSize = CGSizeMake(w, w * 60 / 105.0);
        layout.minimumLineSpacing = 14;
        layout.minimumInteritemSpacing = 14;
        
        CGRect rect = CGRectMake(0, 0, SCREENW, SCREENH - kScreenTopHeight);
        _collectionView = [[UICollectionView alloc] initWithFrame:rect collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.contentInset = UIEdgeInsetsMake(17, 16, 17, 16);

        _collectionView.backgroundColor = [UIColor whiteColor];
        
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCellID"];
        
    }
    return _collectionView;
}

@end

