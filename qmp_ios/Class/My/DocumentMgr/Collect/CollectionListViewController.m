//
//  CollectionListViewController.m
//  QimingpianSearch
//
//  Created by Molly on 16/8/2.
//  Copyright © 2016年 qimingpian. All rights reserved.
//

#import "CollectionListViewController.h"
#import "CollectionListTableViewCell.h"
#import "NewsWebViewController.h"
#import "MainNavViewController.h"
#import "CustomAlertView.h"

#import "URLModel.h"


static NSString *const AppGroupId = @"group.mofang.Qimingpian";

@interface CollectionListViewController ()<UITableViewDelegate,UITableViewDataSource,NewsWebViewDelegate,CustomAlertViewDelegate>{

    NSInteger _localArrNumber;
    ManagerHud *_requestHud;
}

@property (strong, nonatomic) UIView *noCollectionView;
@property (strong, nonatomic) UILabel *infoLbl;

@property (strong, nonatomic) NSMutableArray *tableDataArr;
@property (strong, nonatomic) NSMutableArray *showLocalArr;
@property (strong, nonatomic) NSString *info;

@property (strong, nonatomic) GetSizeWithText *getSizeTool;
@property (strong, nonatomic) ManagerHud *hudTool;

@property (assign, nonatomic) BOOL isLogin;

@end

@implementation CollectionListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"网页收藏";
    [self initTableView];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pressCollectBtnNotification:) name:@"collectUrlFromNewsWebView" object:nil];
    
    self.currentPage = 1;
    self.numPerPage = 30;

    _localArrNumber = 0;
    _isLogin = [ToLogin isLogin];
    
    [self getLocalCollectionUrl];
    
    if (_isLogin) {
        [self showHUD];
        [self requestCollectionList];
    }else{
        self.info = @"请登录后查看";
        self.tableDataArr = nil;
        [self.tableView reloadData];
    }

}
- (void)viewWillDisappear:(BOOL)animated{

    [super viewWillDisappear:animated];
    
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)dealloc{

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UITableView
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [[UIView alloc]init];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return (self.tableDataArr.count == 0 ? 1 : self.tableDataArr.count);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    if (self.tableDataArr.count > 0 ) {
        CGFloat margin = 17.f;
        URLModel *urlModel = self.tableDataArr[indexPath.row];
        NSString *title = [NSString stringWithFormat:@"    %@",urlModel.title];
        CGFloat titleH = [self.getSizeTool calculateSize:title withFont:[UIFont systemFontOfSize:15.f] withWidth:SCREENW - 34].height;
        
        return 10 + titleH + 10 + 20.f + 10 + 20;

    }
    else{
        return SCREENH - kScreenTopHeight;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.tableDataArr.count > 0) {
        static NSString *cellIdentifier = @"CollectionListTableViewCell";
        
        CollectionListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[CollectionListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        URLModel *urlModel = self.tableDataArr[indexPath.row];
        [cell initData:urlModel];
        return cell;

    }
    else{
        
        NSString *title = REQUEST_DATA_NULL;
        return [self nodataCellWithInfo:title tableView:tableView];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if ([TestNetWorkReached networkIsReachedNoAlert]) {
        if(!tableView.mj_header.isRefreshing && !_requestHud && self.tableDataArr.count > 0){
            
            URLModel *urlModel = self.tableDataArr[indexPath.row];
            [self enterWebView:indexPath withUrlModel:urlModel];

        }
    }

}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.tableDataArr.count == 0) {
        return NO;
    }
    else{
        
        return YES;
    }
}

-(UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    URLModel *urlModel = [self.tableDataArr objectAtIndex:indexPath.row];
    NSString *urlId = urlModel.urlId;
    NSString *urlStr = urlModel.url;   

    UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"删除" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {

        //请求取消收藏接口
        [self requestDelCollectUrl:indexPath inTableView:tableView ofUrlId:urlId ofUrl:urlStr];
    }];
    deleteAction.backgroundColor = RED_TEXTCOLOR;
    UIContextualAction *feedbackAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"反馈" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        //信息流
        
        //有产品 有团队 有融资 有相似项目 有机构
        NSMutableArray *mArr = [NSMutableArray arrayWithCapacity:0];//反馈的选项
        [mArr addObject:@"有产品"];
        [mArr addObject:@"有团队"];
        [mArr addObject:@"有融资"];
        [mArr addObject:@"有相似项目"];
        [mArr addObject:@"有机构"];
        [mArr addObject:@"其他"];
        CGFloat  height = 65 +((mArr.count-1)/2+1)*35 + 55;//40是选项按钮高度,间隙为5
        
        NSMutableDictionary *infoDic = [NSMutableDictionary dictionaryWithCapacity:0];//反馈所在模块的信息
        [infoDic setValue:urlStr forKey:@"weburl"];
        CGRect frame = CGRectMake(0, 0, 200, 40);
        [infoDic setValue:@"网页信息" forKey:@"title"];
        CustomAlertView *alert = [[CustomAlertView alloc] initWithAlertViewHeight:mArr frame:frame WithAlertViewHeight:height infoDic:(NSDictionary *)infoDic viewcontroller:self moduleNum:0 isFeeds:YES];
        
        alert.delegate = self;
    }];
    
    feedbackAction.backgroundColor = [UIColor orangeColor];
 
    UISwipeActionsConfiguration *action = [UISwipeActionsConfiguration configurationWithActions:@[deleteAction,feedbackAction]];
    action.performsFirstActionWithFullSwipe = NO;
    return action;
}


- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (iOS11_OR_HIGHER) {
        return @[];
        
    }
    URLModel *urlModel = [self.tableDataArr objectAtIndex:indexPath.row];
    NSString *urlId = urlModel.urlId;
    NSString *urlStr = urlModel.url;
    
    
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        //请求取消收藏接口
        [self requestDelCollectUrl:indexPath inTableView:tableView ofUrlId:urlId ofUrl:urlStr];
    }];
    
    UITableViewRowAction *feedbackAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"反馈" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        //信息流
        
        //有产品 有团队 有融资 有相似项目 有机构
        NSMutableArray *mArr = [NSMutableArray arrayWithCapacity:0];//反馈的选项
        [mArr addObject:@"有产品"];
        [mArr addObject:@"有团队"];
        [mArr addObject:@"有融资"];
        [mArr addObject:@"有相似项目"];
        [mArr addObject:@"有机构"];
        [mArr addObject:@"其他"];
        CGFloat  height = 65 +((mArr.count-1)/2+1)*35 + 55;//40是选项按钮高度,间隙为5

        NSMutableDictionary *infoDic = [NSMutableDictionary dictionaryWithCapacity:0];//反馈所在模块的信息
        [infoDic setValue:urlStr forKey:@"weburl"];
        CGRect frame = CGRectMake(0, 0, 200, 40);
        CustomAlertView *alert = [[CustomAlertView alloc] initWithAlertViewHeight:mArr frame:frame WithAlertViewHeight:height infoDic:(NSDictionary *)infoDic viewcontroller:self moduleNum:0 isFeeds:YES];
        
        alert.delegate = self;
    }];
    
    feedbackAction.backgroundColor = [UIColor orangeColor];

    return @[deleteAction,feedbackAction];
    
}
    
#pragma mark - CustomAlertViewDelegate

- (void)feedsUploadSuccess{

    self.tableView.editing = NO;
    [ShowInfo showInfoOnView:self.view withInfo:@"感谢您的反馈"];
}

#pragma mark - NewsWebViewDelegate

- (void)changeCollectUrlTypeToPdfSuccess:(URLModel *)urlModel{
    [self changeType:urlModel];
}

- (void)changeType:(URLModel *)urlModel{
    
    for (int i = 0; i < self.tableDataArr.count; i ++) {
        URLModel *collectdUrlModel =  [self.tableDataArr objectAtIndex:i];
        if ([urlModel.urlId isEqualToString:collectdUrlModel.urlId]) {
            
            urlModel.isRead = @"1";
            urlModel.type = urlModel.type;
            [self.tableDataArr replaceObjectAtIndex:i withObject:urlModel];
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        }
    }
}

- (void)getUrlTitleWithOldModel:(URLModel *)oldUrlModel{
    
    
    for (int i = 0; i < self.tableDataArr.count; i ++) {
        
        URLModel *collectdUrlModel =  [self.tableDataArr objectAtIndex:i];
        if ([collectdUrlModel.urlId isEqualToString:oldUrlModel.urlId]) {

            collectdUrlModel.title = oldUrlModel.title;
            collectdUrlModel.url = oldUrlModel.url;//如果不加这句话, 从收藏列表跳到中文链接,然后收藏该, 马上从收藏列表打开这个中文链接,就会出问题
            [self.tableDataArr replaceObjectAtIndex:i withObject:collectdUrlModel];
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        }
    }
}

#pragma mark - HasLocalCollectDelegate
- (void)uploadLocalCollection:(NSMutableArray *)arrMSites{

    if (_isLogin) {
        self.showLocalArr = arrMSites;
        
        if (self.showLocalArr.count > 0) {
            
            _localArrNumber = self.showLocalArr.count;
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self.tableView.mj_header beginRefreshing];
                NSMutableArray *tempArr = [NSMutableArray arrayWithArray:self.showLocalArr];
                for (NSDictionary *collectDict in tempArr) {
                    [self requestCollectURLWith:self.showLocalArr ofObj:collectDict];
                }
            });
        }
    }
}

- (void)changeTitleOfHistory:(NSDictionary *)newDict{
    [self.tableDataArr enumerateObjectsUsingBlock:^(URLModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.url isEqualToString:newDict[@"url"]]) {
            obj.title = newDict[@"title"];
            *stop = YES;
        }
    }];
    [self.tableView reloadData];
}
#pragma mark - collectSuccessDelegate

- (void)collectUrlFromLocalSuccess{
    
    [self.tableView.mj_header beginRefreshing];
}


#pragma mark - 请求获取收藏列表

/**
 *  请求获取收藏的url
 */
- (void)requestCollectionList{

    self.info = @"";
    if ([TestNetWorkReached networkIsReachedNoAlert]) {
        NSDictionary *param = @{@"page":[NSString stringWithFormat:@"%ld",(long)self.currentPage],@"num":[NSString stringWithFormat:@"%ld",(long)self.numPerPage]};
        [[NetworkManager sharedMgr]RequestWithMethod:kHTTPPost URLString:@"d/collectedClipboards" HTTPBody:param completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
            
            [self hideHUD];
            [self.tableView.mj_footer endRefreshing];
            [self.tableView.mj_header endRefreshing];
            if (resultData && [resultData isKindOfClass:[NSArray class]]) {
                NSArray *dataArr = resultData;
                NSMutableArray *urlModelArr = [[NSMutableArray alloc] initWithCapacity:0];
                
                for (int i = 0; i < dataArr.count; i ++) {
                    
                    NSDictionary *urlDict = dataArr[i];
                    
                    URLModel *urlModel = [[URLModel alloc] init];
                    urlModel.title = [urlDict objectForKey:@"title"];
                    urlModel.url = [urlDict objectForKey:@"url"];
                    urlModel.collect_time = [urlDict objectForKey:@"collect_time"];
                    urlModel.urlId = [urlDict objectForKey:@"id"];
                    urlModel.isRead = [NSString stringWithFormat:@"%@",[urlDict objectForKey:@"isread"]];
                    urlModel.isCollect = @"1";
                    urlModel.isRecommend = [NSString stringWithFormat:@"%@",[urlDict objectForKey:@"recommend_flag"]];
                    urlModel.type = [urlDict objectForKey:@"collect_type"];
                    [urlModelArr addObject:urlModel];
                }
                
                if (self.currentPage == 1) {
                    self.tableDataArr = urlModelArr;
                }else{
                    
                    for (URLModel *urlModel in urlModelArr) {
                        
                        [self.tableDataArr addObject:urlModel];
                    }
                }
                [self refreshFooter:urlModelArr];
                if (self.tableDataArr.count == 0) {
                    self.info = @"暂无收藏";
                }
                [self.tableView reloadData];
                
            }
        }];
        
    }else{
    
        self.info = @"请检查网络连接设置";
        [self.tableView reloadData];
        
        [self hideHUD];
        [self.tableView.mj_footer endRefreshing];
        [self.tableView.mj_header endRefreshing];

    }
}

#pragma mark - 请求上传本地收藏URl
- (void)requestCollectURLWith:(NSMutableArray *)collectionArr ofObj:(NSDictionary *)collectionDict{
    
    if ([TestNetWorkReached networkIsReachedNoAlert]) {
        
        NSDictionary *param = @{@"url":[[collectionDict objectForKey:@"URL"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding],@"title":[collectionDict objectForKey:@"title"]?[collectionDict objectForKey:@"title"]:@"",@"time":[collectionDict objectForKey:@"collectTime"]};
        [[NetworkManager sharedMgr]RequestWithMethod:kHTTPPost URLString:@"d/collectClipboard" HTTPBody:param completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
            
            if (resultData && [resultData isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dict = resultData;
                NSString *total_count = [NSString stringWithFormat:@"%@",(NSNumber *)[dict objectForKey:@"total_count"]];
                
                if ([total_count integerValue] >= 1){
                    
                    [collectionArr removeObject:collectionDict];
                    [sharedUserDefaults setValue:collectionArr forKey:@"SharedExtension"];
                    
                    NSMutableArray *urlMArr = [NSMutableArray arrayWithArray:[sharedUserDefaults valueForKey:@"urlMArr"]];
                    [urlMArr removeObject:[collectionDict objectForKey:@"URL"]];
                    
                    [sharedUserDefaults setValue:urlMArr forKey:@"urlMArr"];
                    
                    [sharedUserDefaults synchronize];
                    
                    if (collectionArr.count == 0) {
                        [self requestCollectionList];
                        
                        if (_localArrNumber > 0) {
                            NSString *info = [NSString stringWithFormat:@"本次上传了%ld条收藏到云端",(long)_localArrNumber];
                            
                            [ShowInfo showInfoOnViewTop:self.view withInfo:info];
                        }
                    }
                }
            }
        }];
        
    }
    
}

#pragma mark - 请求删除收藏接口
/**
 *  请求删除收藏的url的接口
 */
- (void)requestDelCollectUrl:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView ofUrlId:(NSString *)urlId ofUrl:(NSString *)urlStr{
    
    [[NetworkManager sharedMgr]RequestWithMethod:kHTTPPost URLString:@"d/uncollectClipboard" HTTPBody:@{@"id":urlId} completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        if (resultData) {
            URLModel *model = [self.tableDataArr objectAtIndex:indexPath.row];
            [self.tableDataArr removeObjectAtIndex:indexPath.row];
            if (!self.tableDataArr||self.tableDataArr.count == 0) {
                self.info = @"暂无收藏";
            }
            [PublicTool deleteShortUrlToLocal:model.url];
            [self.tableView reloadData];
        }
    }];

}


#pragma mark - public

/**
 *  下拉刷新数据
 */
- (void)pullDown{
    
    if (self.tableView.mj_footer.state == MJRefreshStateNoMoreData) {
        [self.tableView.mj_footer resetNoMoreData];
        
    }
    
    self.currentPage = 1;
    
    _isLogin = [ToLogin isLogin];
    
    [self getLocalCollectionUrl];
    
    if (_isLogin) {
        
        [self requestCollectionList];
    }
    else{
        self.info = @"请登录后查看";
        [self.tableView.mj_header endRefreshing];
        [self.tableView reloadData];
    }
}
- (void)pullUp{
    
    self.currentPage ++;
    [self requestCollectionList];
}


/**
 *  获取收藏的URL
 */
- (void)getLocalCollectionUrl{
    
    sharedUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:AppGroupId];
    arrSites = [NSMutableArray arrayWithArray:[sharedUserDefaults valueForKey:@"SharedExtension"]];
    
    if (arrSites) {
        self.showLocalArr = [NSMutableArray arrayWithArray:arrSites];
        //友盟
        if(self.showLocalArr){
            NSDictionary *dict = @{@"collectionList" :self.showLocalArr};

        }
        if (arrSites.count > 0) {
            
            _localArrNumber = arrSites.count;
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                if (_isLogin) {
                    
                    [self.tableView.mj_header beginRefreshing];
                    
                    NSMutableArray *tempArr = [NSMutableArray arrayWithArray:arrSites];
                    for (NSDictionary *collectDict in tempArr) {
                        if(_isLogin){
                            [self requestCollectURLWith:arrSites ofObj:collectDict];
                        }else{
                            
                            [self.tableView.mj_header endRefreshing];
                        }
                    }

                }
            });
        }
        else{
        
            [self.tableView.mj_header endRefreshing];
        }
    }
}

- (void)initTableView{
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH-kScreenTopHeight) style:UITableViewStyleGrouped];
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.mj_header = self.mjHeader;
    self.tableView.mj_footer = self.mjFooter;
}

/**
 如果是网页,跳转到wkWebView

 @param indexPath
 @param urlModel
 */
- (void)enterWebView:(NSIndexPath *)indexPath withUrlModel:(URLModel *)urlModel{
    
    urlModel.isCollect = @"1";
    //跳转到WebView
    NewsWebViewController *webView = [[NewsWebViewController alloc] initWithUrlModel:urlModel withAction:@"collectList"];
    webView.cellId = indexPath.row;
    webView.delegate = self;
    
    if (indexPath.section == 0 && self.showLocalArr && self.showLocalArr.count > 0) {
        webView.isLocal  = YES;
    }
    else{
        webView.isLocal = NO;
    }
    [self.navigationController pushViewController:webView animated:YES];
    
}

- (void)pressCollectBtnNotification:(NSNotification *)notification{

    URLModel *urlModel = (URLModel *)[notification object];
    
    if (urlModel) {
        if ([urlModel.isCollect isEqualToString:@"1"]){
            if (![self.tableDataArr containsObject:urlModel]) {
                //如果之前没有收藏过,现在再添加进去
                [self requestCollectionList];
            }
        }
    }
}


- (void)receiveQuitLoginNotification:(NSNotification *)notification{

    NSString *receiveStr = (NSString *)[notification object];
    if ([receiveStr isEqualToString:@"0"]) {
        
        self.tableDataArr = [[NSMutableArray alloc] initWithCapacity:0];
        [self.tableView reloadData];
    }
}

- (void)receiveLoginNotification:(NSNotification *)notification{

    BOOL isLogin = [ToLogin isLogin];

    if (isLogin) {
        [self requestCollectionList];
    }
}
#pragma mark - 懒加载

- (UIView *)noCollectionView{
    
    if (!_noCollectionView) {
        _noCollectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, 36)];
        self.infoLbl = [[UILabel alloc] initWithFrame:CGRectMake(16, 20, SCREENW - 32, 20)];
        self.infoLbl.backgroundColor = [UIColor clearColor];
        [_noCollectionView addSubview:self.infoLbl];
    }
    return _noCollectionView;
}

- (NSMutableArray *) tableDataArr{
    
    if (!_tableDataArr) {
        _tableDataArr = [[NSMutableArray alloc] initWithCapacity:0];
    }
    
    return _tableDataArr;
}



- (NSMutableArray *)showLocalArr{

    if (!_showLocalArr) {
        _showLocalArr = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _showLocalArr;
}



- (GetSizeWithText *)getSizeTool{
    
    if (!_getSizeTool) {
        _getSizeTool = [[GetSizeWithText alloc] init];
    }
    return _getSizeTool;
}

@end
