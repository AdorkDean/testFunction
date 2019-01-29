//
//  QMPMyActivityCommentViewController.m
//  qmp_ios
//
//  Created by QMP on 2018/9/3.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "QMPMyActivityCommentViewController.h"
#import "QMPMyCommentCell.h"
@interface QMPMyActivityCommentViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSMutableArray *data;
@end

@implementation QMPMyActivityCommentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"我的评论";
    
    [self setupViews];
    [self showHUD];
    [self requestData];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(pullDown) name:NOTIFI_ACTCOMMENTDEL object:nil];
}

- (void)setupViews {
    CGRect rect = CGRectMake(0, 0, SCREENW, SCREENH-kScreenTopHeight);
    self.tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    if (@available(iOS 11, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.mj_header = self.mjHeader;
    self.tableView.mj_footer = self.mjFooter;
    self.tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
    
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)requestData {
    if (![super requestData]) {
        return NO;
    }
    if (self.tableView.mj_header.isRefreshing) {
        self.currentPage = 1;
    }
    
    NSDictionary *dict = @{@"page":@(self.currentPage), @"num":@(self.numPerPage)};
    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"activity/commentList" HTTPBody:dict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        [self hideHUD];
        [self.tableView.mj_footer endRefreshing];
        [self.tableView.mj_header endRefreshing];
        if (resultData && [resultData isKindOfClass:[NSDictionary class]]) {
            if (self.currentPage == 1) {
                [self.data removeAllObjects];
            }
            
            NSArray *list = resultData[@"list"];
            NSMutableArray *arr = [NSMutableArray array];
            for (NSDictionary *dict in list) {
                QMPMyComment *comment = [[QMPMyComment alloc] initWithCommentDict:dict];
                [arr addObject:comment];
            }
            
            [self.data addObjectsFromArray:arr];
            [self.tableView reloadData];
        }
        
    }];
    return YES;
}

#pragma mark - UITabelViewDataSource & Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.data.count?:1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.data.count == 0) {
        return [self nodataCellWithInfo:REQUEST_DATA_NULL tableView:tableView];
    }
    
    QMPMyCommentCell *cell = [QMPMyCommentCell myCommentCellWithTableView:tableView];
    cell.comment = self.data[indexPath.row];
    __weak typeof(self) weakSelf = self;
    cell.commentDidDeleted = ^{
        [weakSelf.data removeObjectAtIndex:indexPath.row];
        [weakSelf.tableView reloadData];
    };
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.data.count == 0) {
        return tableView.height;
    }
    QMPMyComment *comment = self.data[indexPath.row];
    return comment.cellHeight;
}
- (NSMutableArray *)data {
    if (!_data) {
        _data = [NSMutableArray array];
    }
    return _data;
}

@end
