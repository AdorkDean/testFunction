//
//  OneSourceViewController.m
//  qmp_ios
//
//  Created by Molly on 2016/11/9.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import "OneSourceViewController.h"
#import "NewsWebViewController.h"
#import "NewsTableViewCell.h"

#import "NewsModel.h"
#import "CustomAlertView.h"


@interface OneSourceViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) ManagerHud *hudTool;
@property (strong, nonatomic) ToLogin *toLoginTool;
@property (strong, nonatomic) GetSizeWithText *getSizeTool;

@end

@implementation OneSourceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initTableView];
    
    self.currentPage = 1;
    self.numPerPage = 20;
    [self buildRightBarButtonItem];
    [self showHUD];
    if ([self.action isEqualToString:@"CompanyView"]) {
        self.title = self.companyItem.product;
        [self requestCompanyNews];
        
    }else{
        self.title = self.organizeItem.name;
        [self downPullOrganizeNews];
    }
}


#pragma mark - FeedbackResultDelegate

- (void)FeedbackResultSuccess{
    [ShowInfo showInfoOnView:self.view withInfo:@"感谢您的反馈"];
}

#pragma mark - UITableView
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
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.newsMArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.newsMArr.count > 0) {
        //投资新闻
        return 57;

        
    }else{
        
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.newsMArr.count > 0) {
        
        //投资新闻
        static NSString *cellIdentifier = @"NewsTableViewCellID";
        NewsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        NewsModel *newsModel = self.newsMArr[indexPath.row];
        cell.newsModel = newsModel;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        NSInteger lastCell = self.newsMArr.count > 5 ? 4:self.newsMArr.count-1;
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
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (![TestNetWorkReached networkIsReached:self]) {
        
        return;
    }else{
        if ([self.action isEqualToString:@"CompanyView"]) {
        }
        NewsModel *urlItem = self.newsMArr[indexPath.row];
        URLModel *urlModel = [[URLModel alloc] init];
        urlModel.urlId = urlItem.news_id;
        urlModel.url = urlItem.news_detail?urlItem.news_detail:urlItem.link;
        
        NewsWebViewController *webView = [[NewsWebViewController alloc] initWithUrlModel:urlModel withAction:@"recommand"];
        webView.cellId = indexPath.row;
        webView.hidesBottomBarWhenPushed = YES;
        webView.feedbackFlag = self.companyItem ? @"项目":(self.organizeItem?@"机构":(self.person?@"人物":@""));
        if (self.companyItem) {
            webView.company = @{@"product":self.companyItem.product,@"company":self.companyItem.company};
        }else if (self.organizeItem) {
            webView.jigou = @{@"name":self.organizeItem.name?self.organizeItem.name:[PublicTool nilStringReturn:self.organizeItem.name]};
        }else if (self.person) {
            webView.jigou = @{@"id":self.person.personId?self.person.personId:[PublicTool nilStringReturn:self.person.person_id],@"name":self.person.person_name ? self.person.person_name:self.person.name};
        }
        [self.navigationController pushViewController:webView animated:YES];
    }
}


#pragma mark - 请求公司详情新闻
- (void)requestCompanyNews{
    
    if ([TestNetWorkReached networkIsReached:self]) {
        NSMutableDictionary *param = [NSMutableDictionary dictionaryWithDictionary:self.requestDict];
        if ([self.tableView.mj_header isRefreshing]) {
            [param setValue:@"1" forKey:@"debug"];
        }
        [param setValue:@(self.currentPage) forKey:@"page"];
        [param setValue:@(self.numPerPage) forKey:@"num"];

        [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"News/productNews" HTTPBody:param completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
            [self hideHUD];
            [self.tableView.mj_header endRefreshing];
            [self.tableView.mj_footer endRefreshing];

            if (resultData && [resultData isKindOfClass:[NSDictionary class]]) {
                //公司新闻
                NSMutableArray *newsMArr = [[NSMutableArray alloc] initWithCapacity:0];
                NSArray *newsArr = resultData[@"list"];
                for (NSDictionary *newDict in newsArr) {
                    NewsModel *item = [[NewsModel alloc] init];
                    [item setValuesForKeysWithDictionary:newDict];
                    
                    [newsMArr addObject:item];
                }
                if (self.currentPage == 1) {
                    [self.newsMArr removeAllObjects];
                }
                [self.newsMArr addObjectsFromArray:newsMArr];
                
                [self refreshFooter:newsArr];
            }
            [self.tableView reloadData];

        }];
        
    }else{
        [self.tableView.mj_header endRefreshing];
    }
    
}


/**
 机构新闻
 */
- (void)downPullOrganizeNews{
    
    if ([TestNetWorkReached networkIsReached:self]){
        
        NSMutableDictionary *param = [NSMutableDictionary dictionaryWithDictionary:self.requestDict];
        if ([self.tableView.mj_header isRefreshing]) {
            [param setValue:@"1" forKey:@"debug"];
        }
        [param setValue:@(self.currentPage) forKey:@"page"];
        [param setValue:@(self.numPerPage) forKey:@"num"];
        
        [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"AgencyDetail/agencyNews" HTTPBody:param completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
            
            [self hideHUD];
            [self.tableView.mj_header endRefreshing];
            [self.tableView.mj_footer endRefreshing];
            if (resultData && [resultData isKindOfClass:[NSDictionary class]]) {
                //公司新闻
                NSMutableArray *newsMArr = [[NSMutableArray alloc] initWithCapacity:0];
                NSArray *newsArr = resultData[@"list"];
                for (NSDictionary *newDict in newsArr) {
                    NewsModel *item = [[NewsModel alloc] init];
                    [item setValuesForKeysWithDictionary:newDict];
                    
                    [newsMArr addObject:item];
                }
                if (self.currentPage == 1) {
                    [self.newsMArr removeAllObjects];
                }
                [self.newsMArr addObjectsFromArray:newsMArr];

                [self refreshFooter:newsArr];
            }
            [self.tableView reloadData];
            
        }];
        
    }else{
        
        [self.tableView.mj_header endRefreshing];
    }
}



#pragma mark - pubic

/**
 长按新闻复制
 
 @param longPress
 */
- (void)longPressJianjieLbl:(UILongPressGestureRecognizer *)longPress{
    UILabel *lbl = (UILabel *)longPress.view;
    
    
    NSString *urlStr = _organizeItem ? _organizeItem.short_url:_companyItem.short_url;
    if ([urlStr hasPrefix:@"http://"]||[urlStr hasPrefix:@"https://"]) {
        
        [PublicTool storeShortUrlToLocal:urlStr];
        
    }
    
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    pboard.string = [NSString stringWithFormat:@"%@ 来自@企名片%@",lbl.text,urlStr];
    
    NSString *info = @"复制成功";
    [ShowInfo showInfoOnView:KEYWindow withInfo:info];
}

-(void)buildRightBarButtonItem{
    UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 47.f, 20.f)];
    [rightBtn setTitle:@"反馈" forState:UIControlStateNormal];
    rightBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:15.f];
    [rightBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(feedbackDetail:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = item;
    
}

- (void)feedbackDetail:(UIButton *)sender{
    
    if (![TestNetWorkReached networkIsReached:self]) {
        return;
    }else{
        id first = objc_getAssociatedObject(sender, "feedbackDetail");
        UIView *view = (UIView *)first;
        CGRect frame = view.frame;
        CGFloat height = 65;
        NSMutableArray *mArr = [NSMutableArray arrayWithCapacity:0];
        NSMutableDictionary *infoDic = [NSMutableDictionary dictionaryWithCapacity:0];//反馈所在模块的信息
        NSInteger moduleNum = 0;
        
        if (self.companyItem) {
            [infoDic setValue:@"新闻列表" forKey:@"module"];//模块
            [infoDic setValue:@"公司新闻列表" forKey:@"title"];

            if (_companyItem.product&&![_companyItem.product isEqualToString:@""]) {
                [infoDic setValue:_companyItem.product forKey:@"product"];
            }else{
                [infoDic setValue:@"" forKey:@"product"];
            }
            if (_companyItem.company&&![_companyItem.company isEqualToString:@""]) {
                [infoDic setValue:_companyItem.company forKey:@"company"];
            }else{
                [infoDic setValue:@"" forKey:@"company"];
            }
        }else if (self.organizeItem){
            [infoDic setValue:@"机构新闻" forKey:@"module"];//模块
            [infoDic setValue:@"机构新闻列表" forKey:@"title"];

            if (self.organizeItem.name&&![self.organizeItem.name isEqualToString:@""]) {
                [infoDic setValue:self.organizeItem.name forKey:@"product"];
            }else{
                [infoDic setValue:@"" forKey:@"product"];
            }
            if (self.organizeItem.name&&![self.organizeItem.name isEqualToString:@""]) {
                [infoDic setValue:self.organizeItem.name forKey:@"company"];
            }else{
                [infoDic setValue:@"" forKey:@"company"];
            }
        }
        
        if (_newsMArr) {
            if (_newsMArr.count>0) {
                [mArr addObject:@"链接失效"];
                [mArr addObject:@"新闻不相关"];
                [mArr addObject:@"新闻重复"];
                [mArr addObject:@"新闻不全"];
                if (self.companyItem) {
                    [mArr addObject:@"新闻内有融资"];
                }else if (self.organizeItem){
                    [mArr addObject:@"新闻内有投资"];
                }
                moduleNum = _newsMArr.count;
            }
        }
        if (_newsMArr.count<=0||!_newsMArr||![_newsMArr isKindOfClass:[NSArray class]]) {
            [mArr addObject:@"新闻缺失"];
            moduleNum = 0;
        }
        if (mArr.count>0) {
            height += ((mArr.count-1)/2+1)*35 + 55.f;
        }
        
        [self feedbackAlertView:mArr frame:frame WithAlertViewHeight:height moduleDic:infoDic moduleNum:moduleNum];
    }
}

- (void)feedbackAlertView:(NSMutableArray *)mArr frame:(CGRect)frame WithAlertViewHeight:(CGFloat)height moduleDic:(NSDictionary *)infoDic moduleNum:(NSInteger)num{
    
    CustomAlertView *alert = [[CustomAlertView alloc] initWithAlertViewHeight:mArr frame:frame WithAlertViewHeight:height infoDic:(NSDictionary *)infoDic viewcontroller:self moduleNum:num isFeeds:NO];
}

- (void)initTableView{
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH - kScreenTopHeight ) style:UITableViewStyleGrouped];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[NewsTableViewCell class] forCellReuseIdentifier:@"NewsTableViewCellID"];
    
    self.tableView.mj_header = self.mjHeader;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
}

- (void)pullDown{
    self.currentPage = 1;
    self.mjFooter = nil;

    if ([self.action isEqualToString:@"OrganizesView"]) {
        //机构新闻跳转过来的
        [self  downPullOrganizeNews];
    }
    else if ([self.action isEqualToString:@"CompanyView"]) {
        //项目新闻跳转过来的
        [self requestCompanyNews];
    }
}

- (void)pullUp{
    
    self.currentPage++;
    if ([self.action isEqualToString:@"OrganizesView"]) {
        //机构新闻跳转过来的
        [self  downPullOrganizeNews];
    }
    else if ([self.action isEqualToString:@"CompanyView"]) {
        //项目新闻跳转过来的
        [self requestCompanyNews];
    }
}
#pragma mark - 懒加载
- (NSMutableArray *)newsMArr{
    
    if (!_newsMArr) {
        _newsMArr = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _newsMArr;
}

- (ManagerHud *)hudTool{
    
    if(!_hudTool){
        _hudTool = [[ManagerHud alloc] init];
    }
    return _hudTool;
}

- (ToLogin *)toLoginTool{
    
    if (!_toLoginTool) {
        _toLoginTool = [[ToLogin alloc] init];
    }
    
    return _toLoginTool;
}

- (GetSizeWithText *)getSizeTool{
    
    if (!_getSizeTool) {
        _getSizeTool = [[GetSizeWithText alloc] init];
    }
    return _getSizeTool;
}

@end
