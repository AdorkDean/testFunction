//
//  NewsResultController.m
//  CommonLibrary
//
//  Created by QMP on 2018/12/17.
//  Copyright © 2018 WSS. All rights reserved.
//

#import "NewsResultController.h"
#import "NewsWebViewController.h"
#import "SearchNewsCell.h"

#import "NewsModel.h"
#import "CustomAlertView.h"

@interface NewsResultController ()<UITableViewDataSource, UITableViewDelegate, CustomAlertViewDelegate> {
    NSString *_totalCount;
}


@end

@implementation NewsResultController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    _totalCount = @"0";
    [self initTableView];
    
    self.currentPage = 1;
    self.numPerPage = 20;
    [self requestData];
}


- (void)initTableView {

    //    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH - kScreenTopHeight-45) style:UITableViewStyleGrouped];
    [self.tableView registerClass:[SearchNewsCell class] forCellReuseIdentifier:@"SearchNewsCellID"];
    self.tableView.frame = CGRectMake(0, 0, SCREENW, SCREENH - kScreenTopHeight - 45);
}

- (BOOL)requestData {
    
    if (![super requestData]) {
        return NO;
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:@{}];
    NSString *w = [self.keyword stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]; // 注意考虑特殊字符
    [dic setValue:w forKey:@"keywords"];
    
    [dic setValue:@"7" forKey:@"type"];
    [dic setValue:@(self.currentPage) forKey:@"page"];
    [dic setValue:@(self.numPerPage) forKey:@"num"];
    
    if (self.dataArr.count == 0) {
        [self showHUD];
    }
    
    
    [AppNetRequest mainSearchWithParameter:dic completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        [self hideHUD];
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        
        NSMutableArray *arr = [NSMutableArray array];
        
        if (resultData && [resultData[@"list"] isKindOfClass:[NSArray class]]) {
            
            if (self.currentPage == 1) {
                _totalCount = resultData[@"count"];
            }
            for (NSDictionary *dic in resultData[@"list"]) {
                NewsModel *product = [[NewsModel alloc]init];
                [product setValuesForKeysWithDictionary:dic];
                if (product.title.length > 60) {
                    product.title = [product.title substringToIndex:60];
                    product.title = [product.title stringByAppendingString:@"..."];
                }
                [arr addObject:product];
            }
            if (self.currentPage == 1) {
                [self.dataArr removeAllObjects];
            }
            
            [self.dataArr addObjectsFromArray:arr];
            
        }else{
            if (self.currentPage == 1) {
                _totalCount = @"0";
            }
        }
        [self.tableView reloadData];
        [self refreshFooter:arr];
        
    }];
    
    return YES;
}

- (void)feedbackSuccessHandle {
    self.feedbackBtn.selected = YES;
}


#pragma mark - UITableView
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 55;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.00001;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *sectionView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 55)];
    sectionView.backgroundColor = TABLEVIEW_COLOR;
    
    UIView *_headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 10, SCREENW, 45)];//表头
    _headerView.backgroundColor = [UIColor whiteColor];
    [sectionView addSubview:_headerView];
    
    UILabel *headerLab = [[UILabel alloc]initWithFrame:CGRectMake(17, 0, 200, 45)];
    headerLab.backgroundColor = [UIColor clearColor];
    [_headerView addSubview:headerLab];
    headerLab.font = [UIFont systemFontOfSize:14];
    headerLab.textColor = H9COLOR;
    NSString *headerStr = [NSString stringWithFormat:@"新闻(%@)",_totalCount];
    headerLab.text = headerStr;
    [_headerView addSubview:headerLab];
    if (self.dataArr.count > 0) {
        UIButton *baiduBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        baiduBtn.frame = CGRectMake(SCREENW-135,0, 72, 45);
        baiduBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        baiduBtn.tag = 100;
        [baiduBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
        [baiduBtn.titleLabel setFont:[UIFont systemFontOfSize:13]];
        [baiduBtn setTitle:@"全网搜索" forState:UIControlStateNormal];
        [baiduBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        [baiduBtn addTarget:self action:@selector(baiduBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_headerView addSubview:baiduBtn];
    }
   
    self.feedbackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.feedbackBtn.frame = CGRectMake(SCREENW-67,0, 50, 45);
    self.feedbackBtn.tag = 100;
    [self.feedbackBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
    [self.feedbackBtn.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [self.feedbackBtn setTitle:@"反馈" forState:UIControlStateNormal];
    [self.feedbackBtn setTitle:@"已反馈" forState:UIControlStateSelected];
    [self.feedbackBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [self.feedbackBtn addTarget:self action:@selector(feedbackAlertView1) forControlEvents:UIControlEventTouchUpInside];
    [_headerView addSubview:self.feedbackBtn];
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 54.5, SCREENW, 0.5)];
    line.backgroundColor = LIST_LINE_COLOR;
    [sectionView addSubview:line];
    
    return sectionView;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] init];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.dataArr.count == 0) {
        return 1;
    }
    return self.dataArr.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.dataArr.count == 0) {
        return SCREENH - kScreenTopHeight - 90;  //未搜索到
    }
    NewsModel *news = self.dataArr[indexPath.row];
    return [tableView fd_heightForCellWithIdentifier:@"SearchNewsCellID" configuration:^(SearchNewsCell *cell) {
        cell.newsModel = news;
    }];
    return 57;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.dataArr.count == 0) {
        NSString *title = REQUEST_DATA_NULL;
        HomeInfoTableViewCell *cell = [self nodataCellWithInfo:title tableView:tableView];
        [cell.createBtn setTitle:@"全网搜索" forState:UIControlStateNormal];
        cell.createBtn.hidden = NO;
        [cell.createBtn addTarget:self action:@selector(baiduBtnClick) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
    
    //新闻
    SearchNewsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchNewsCellID" forIndexPath:indexPath];
    NewsModel *newsModel = self.dataArr[indexPath.row];
    cell.keyword = self.keyword;
    cell.newsModel = newsModel;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSInteger lastCell = self.dataArr.count-1;
    if (indexPath.row == lastCell) {
        cell.bottomLine.hidden = YES;
    }else{
        cell.bottomLine.hidden = NO;
    }
    //长按复制
    UILongPressGestureRecognizer *longNews = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressJianjieLbl:)];
    [cell.titleLbl addGestureRecognizer:longNews];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.dataArr.count == 0) {
        return;
    }
    if (![ToLogin canEnterDeep]) {
        [ToLogin accessEnterDeep];
        return;
    }
    
    NewsModel *urlItem = self.dataArr[indexPath.row];
    URLModel *urlModel = [[URLModel alloc] init];
    urlModel.urlId = urlItem.news_id;
    urlModel.url = urlItem.news_detail?urlItem.news_detail:urlItem.link;
    
    NewsWebViewController *webView = [[NewsWebViewController alloc] initWithUrlModel:urlModel withAction:@"recommand"];
    webView.cellId = indexPath.row;
    [self.navigationController pushViewController:webView animated:YES];
    [QMPEvent event:@"search_newscell_click"];
    [QMPEvent event:@"news_webpage_enter" label:@"新闻_搜索"];
}


/**
 长按新闻复制
 
 @param longPress
 */
- (void)longPressJianjieLbl:(UILongPressGestureRecognizer *)longPress{
    UILabel *lbl = (UILabel *)longPress.view;
    
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    pboard.string = [NSString stringWithFormat:@"%@ 来自@企名片",lbl.text];
    
    NSString *info = @"复制成功";
    [ShowInfo showInfoOnView:KEYWindow withInfo:info];
}


#pragma mark - EVENT
- (void)feedbackAlertView1 {
    NSMutableArray *arr = [NSMutableArray arrayWithObjects:@"有新闻",@"新闻不相关",@"链接失效",@"新闻重复", nil];
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionaryWithDictionary:@{@"module":@"搜索列表详情",@"title":@"搜索"}];
    [infoDic setValue:@"人工信息完善" forKey:@"type"];
    [infoDic setValue:@"急" forKey:@"c4"];
    [infoDic setValue:self.keyword forKey:@"c1"];
    [infoDic setValue:self.keyword forKey:@"company"];
    
    CustomAlertView *alertV = [[CustomAlertView alloc]initWithAlertViewHeight:arr frame:CGRectZero WithAlertViewHeight:10 infoDic:infoDic viewcontroller:self moduleNum:0 isFeeds:NO];
    alertV.delegate = self;
}

#pragma mark - Getter
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

@end
