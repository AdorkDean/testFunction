

//
//  InvestorNewsController.m
//  qmp_ios
//
//  Created by QMP on 2017/11/27.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "InvestorNewsController.h"
#import "NewsWebViewController.h"
#import "NewsTableViewCell.h"
#import "CustomAlertView.h"

@interface InvestorNewsController ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation InvestorNewsController


- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"人物新闻";
    [self buildRightBarButtonItem];
    [self initTableView];
    
//    [self showHUD];
//    [self requestData];
}

- (BOOL)requestData{
    if (![super requestData]) {
        return NO;
    }
    NSString *isDEBUG = self.tableView.mj_header.isRefreshing ? @"1":@"0";
    NSDictionary *dic = @{@"debug":isDEBUG,@"page":@(self.currentPage),@"num":@(self.numPerPage)};
    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"" HTTPBody:dic completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
    }];
    return YES;
}

- (void)buildRightBarButtonItem{
    
    UIButton *rightBtn = [[UIButton alloc] initWithFrame:RIGHTBARBTNFRAME];
    [rightBtn setTitle:@"反馈" forState:UIControlStateNormal];
    rightBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:15.f];
    [rightBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(feedbackDetail) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)feedbackDetail{
    NSMutableArray *mArr = [NSMutableArray arrayWithCapacity:0];
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionaryWithCapacity:0];//反馈所在模块的信息
    [infoDic setValue:@"人物信息" forKey:@"module"];
    
    if (![PublicTool isNull:self.person.name]) {
        [infoDic setValue:self.person.name forKey:@"company"];
    }else{
        [infoDic setValue:@"" forKey:@"company"];
    }
    
    
    [infoDic setValue:self.person.personId forKey:@"product"];
    [infoDic setValue:@"人物新闻" forKey:@"title"];
    
    [mArr addObject:@"链接失效"];
    [mArr addObject:@"新闻不相关"];
    [mArr addObject:@"新闻重复"];
    [mArr addObject:@"新闻不全"];
    
    CustomAlertView *alert = [[CustomAlertView alloc] initWithAlertViewHeight:mArr frame:CGRectZero WithAlertViewHeight:50 infoDic:(NSDictionary *)infoDic viewcontroller:self moduleNum:0 isFeeds:NO];
}
- (void)initTableView{
    
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH-kScreenTopHeight) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = TABLEVIEW_COLOR;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[NewsTableViewCell class] forCellReuseIdentifier:@"NewsTableViewCellID"];
    [self.view addSubview:self.tableView];
    
}



#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _listArr.count ? _listArr.count : 0;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_listArr.count == 0) {
        return SCREENH-kScreenTopHeight;
    }
    
    return 57;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ( _listArr.count == 0 ) {

        NSString *title = REQUEST_DATA_NULL;
        return [self nodataCellWithInfo:title tableView:tableView];
        
    }
    else{
        NewsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewsTableViewCellID" forIndexPath:indexPath];
        cell.newsModel = _listArr[indexPath.row];
        //长按复制
        UILongPressGestureRecognizer *longNews = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressJianjieLbl:)];
        [cell.titleLbl addGestureRecognizer:longNews];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}

- (void)longPressJianjieLbl:(UILongPressGestureRecognizer *)longPress{
    UILabel *lbl = (UILabel *)longPress.view;
    
    NSString *urlStr = self.person.share_link;
    if ([urlStr hasPrefix:@"http://"]||[urlStr hasPrefix:@"https://"]) {
        
        [PublicTool storeShortUrlToLocal:urlStr];
        
    }
    
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    pboard.string = [NSString stringWithFormat:@"%@ 来自@企名片%@",lbl.text,urlStr];
    
    NSString *info = @"复制成功";
    [ShowInfo showInfoOnView:KEYWindow withInfo:info];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (_listArr.count == 0) {
        
        return;
    }
    else{
        if (![TestNetWorkReached networkIsReached:self]) {
            
            return;
        }else{            
            //新闻
            NewsModel *item = _listArr[indexPath.row];
            URLModel *urlModel = [[URLModel alloc] init];
            urlModel.url = item.link;
            urlModel.title = item.title;
            NewsWebViewController *webView = [[NewsWebViewController alloc] initWithUrlModel:urlModel withAction:@""];
            webView.fromVC = @"公司新闻";
            [self.navigationController pushViewController:webView animated:YES];
            [QMPEvent event:@"person_newsCellClick"];
            [QMPEvent event:@"news_webpage_enter" label:@"新闻_人物"];

            
            webView.feedbackFlag = @"人物";
            webView.person = @{@"id":self.person.personId?:@"",@"name":self.person.name?:@""};
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1;
}
- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [[UIView alloc]init];
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}
- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc]init];
}

@end
