//
//  HomeIPOViewController.m
//  qmp_ios
//
//  Created by QMP on 2018/11/22.
//  Copyright © 2018 WSS. All rights reserved.
//

#import "HomeIPOViewController.h"
#import "QMPRecentEventCell2.h"
#import "SmarketEventModel.h"
@interface HomeIPOViewController ()
@property (nonatomic, strong) NSMutableArray *data;
@end

@implementation HomeIPOViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.numPerPage = 10;
    
    [self setupViews];
    
    CGFloat top = -self.scrollView.contentOffset.y-120;
    [self showHUDAtTop:top];
    
    
    //    if (self.type.length == 0) {
    [self requestData];
    //    }
    
    
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestData) name:@"UserPostActivitySuccess" object:nil];
    //
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestData) name:NOTIFI_LOGIN object:nil];
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestData) name:NOTIFI_QUITLOGIN object:nil];
    
}

- (void)setupViews {
    
}

- (BOOL)requestData {
    if (![super requestData]) {
        return NO;
    }
//    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
//    [paramDict setValue:@(self.currentPage) forKey:@"page"];
//    [paramDict setValue:@(self.numPerPage) forKey:@"num"];
//    [paramDict setValue:self.type forKey:@"type"];
//
//    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"recentHappen/getRecentHappened" HTTPBody:paramDict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
//        [self hideHUD];
//        [self.tableView.mj_footer endRefreshing];
//        [self.tableView.mj_header endRefreshing];
//        if (resultData && [resultData isKindOfClass:[NSArray class]]) {
//            NSArray *arr = resultData;
//            NSMutableArray *mArr = [NSMutableArray array];
//            for (NSDictionary *dict in arr) {
//                QMPRecentEvent *e = [[QMPRecentEvent alloc] initWithDict:dict all:(self.type.length == 0)];
//
//                [mArr addObject:e];
//            }
//
//            if (self.currentPage == 1) {
//                self.data = mArr;
//
//            } else {
//                [self.data addObjectsFromArray:mArr];
//
//            }
//            [self refreshFooter:mArr];
//            [self.tableView reloadData];
//
//        }
//
//    }];
    
    /*
     @property (nonatomic, copy) NSString *ticket_id;
     @property (nonatomic, copy) NSString *ticket;
     
     @property (nonatomic, copy) NSString *subType;
     
     
     @property (nonatomic, copy) NSString *icon;
     @property (nonatomic, copy) NSString *name;
     @property (nonatomic, copy) NSString *desc;
     @property (nonatomic, copy) NSString *meta;
     @property (nonatomic, copy) NSString *type;
     @property (nonatomic, assign) BOOL hasBP;
     
     @property (nonatomic, assign) CGFloat cellHeight;
     @property (nonatomic, assign) CGFloat typeWidth;
     
     - (instancetype)initWithDict:(NSDictionary *)event;
     - (instancetype)initWithDict:(NSDictionary *)event all:(BOOL)isAll;
     
     @property (nonatomic, assign) BOOL isAll;
     
     */
    NSMutableDictionary *reqDict = [NSMutableDictionary dictionaryWithDictionary:@{@"page":@(self.currentPage),@"page_num":@(self.numPerPage), @"event":@"上市事件"}];
    
    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"SMarket/financing" HTTPBody:reqDict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        
        [self hideHUD];
        [self.mjHeader endRefreshing];
        [self.mjFooter endRefreshing];
        
        if (resultData) {
//            
            NSDictionary *dict = resultData;
            NSArray *arr = dict[@"list"];
            
            if (self.currentPage == 1) {
                [self.data removeAllObjects];
            }
            
            for (NSDictionary *dic in arr) {
                NSError *error = nil;
                SmarketEventModel *eventModel = [[SmarketEventModel alloc]initWithDictionary:dic error:&error];
                QMPRecentEvent2 *e = [[QMPRecentEvent2 alloc] initWithSmarketEventModel:eventModel];
                [self.data addObject:e];
            }
            
            [self.tableView reloadData];
            
            [self refreshFooter:arr];
//
            //            isFilter = NO;
        }
    }];

    return YES;
}
#pragma mark - UITableViewDataSource & Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return MAX(1,self.data.count);
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"123"];
    if (self.data.count == 0) {
        return [self nodataCellWithInfo:REQUEST_DATA_NULL tableView:tableView];
    }
    QMPRecentEventCell2 *cell = [QMPRecentEventCell2 cellWithTableView:tableView];
    cell.event = self.data[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //    return self.activityData[indexPath.row].cellHeight;
    if (self.data.count == 0) {
        return tableView.height;
    }
    QMPRecentEvent2 *event = self.data[indexPath.row];
    return event.cellHeight;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.0001;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *sectionView = [[UIView alloc] init];
    return sectionView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.00001;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] init];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![ToLogin canEnterDeep]) {
        [ToLogin accessEnterDeep];
        return;
    }
    if (self.data.count == 0) {
        return;
    }
    //    NSDictionary *event = self.data[indexPath.row];
    //    NSDictionary *contentEvent = event[@"content"];
    QMPRecentEvent2 *event = self.data[indexPath.row];
    if (![PublicTool isNull:event.subType]) {
        if ([event.subType isEqualToString:@"product"]) {
            NSDictionary *dic = @{@"id":event.ticket_id?:@"",@"ticket":event.ticket?:@""};
            [[AppPageSkipTool shared] appPageSkipToProductDetail:dic];
            
        } else if ([event.subType isEqualToString:@"jigou"]) {
            NSDictionary *urlDict = @{@"id":event.ticket_id?:@"",@"ticket":event.ticket?:@""};
            [[AppPageSkipTool shared] appPageSkipToJigouDetail:urlDict];
            
        }
    }
}
- (NSMutableArray *)data {
    if (!_data) {
        _data = [NSMutableArray array];
    }
    return _data;
}
@end
