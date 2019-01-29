//
//  CompanySimilarViewController.m
//  qmp_ios
//
//  Created by Molly on 2016/12/17.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import "CompanySimilarViewController.h"
#import "CompanyDetailSimilarCell.h"
#import "CustomAlertView.h"
#import "TagsFrame.h"
#import "SimilarFilterCell.h"

@interface CompanySimilarViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    BOOL _isPart;
    BOOL _showOnFirst;
    TagsFrame *_tagFrame;
}
@property (strong, nonatomic) ManagerHud *hudTool;
@property (nonatomic, copy)NSString *selectedTag;
@property(nonatomic,strong)NSMutableArray *listArr;

@property(nonatomic,strong)SimilarFilterCell *lazyCell;

@end

@implementation CompanySimilarViewController
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.lazyCell.frame = CGRectMake(0, 90, SCREENW, 50);
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    _showOnFirst = NO;
    _isPart = YES;
    _selectedTag = @"综合";
    [self.tagArr insertObject:@"综合" atIndex:0];
    [self.view addSubview:self.lazyCell];
    self.lazyCell.tagsArr = [NSArray arrayWithArray:self.tagArr];
    
    [self showHUD];
    [self requestData];
    //只显示2行
    TagsFrame *tagframe = [self getHeightFromArr:self.tagArr];
    NSMutableArray *tagsArr = [NSMutableArray array];
    for (int i=0; i<tagframe.tagsArray.count; i++) {
        CGRect frame = CGRectFromString(tagframe.tagsFrames[i]);
        
        if (frame.origin.y >= (12+(12+24)*2)) { //第三行y
            break;
        }
        [tagsArr addObject:tagframe.tagsArray[i]];
        
    }
    
    _tagFrame = [self getHeightFromArr:tagsArr];
    
    
    [self buildRightBarButtonItem];
    [self initTableView];
    self.title = @"相似项目";
    
    if (self.listArr.count > 1) {
        [self showFeedbackAlert];
    }
}


- (TagsFrame *)getHeightFromArr:(NSArray *)tagsArr{
    
    TagsFrame *frame = [[TagsFrame alloc] init];
    if (tagsArr.count>0) {
        frame.tagsArray = tagsArr;
    }
    
    return frame;
}



#pragma mark - FeedbackResultDelegate

- (void)FeedbackResultSuccess{
    [ShowInfo showInfoOnView:self.view withInfo:@"感谢您的反馈"];
}

#pragma mark - UITableView

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [[UIView alloc]init];
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc]init];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.listArr.count+1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_showOnFirst) {
        if (indexPath.row == 0) {
            NSString *lastFrame = _tagFrame.tagsFrames.lastObject;
            if (CGRectFromString(lastFrame).origin.y < 84) {
                return _tagFrame.tagsHeight+75;
            }else{
                return _isPart ? 170 : self.lazyCell.tagsCollecView.contentSize.height+90;
            }
        }else{
            return 76.f;
        }
    }
    
    if ([_selectedTag isEqualToString:@"综合"]) {  //不是第一个
        if (((indexPath.row == 15) && (self.listArr.count > 15)) || ((indexPath.row == self.listArr.count) && (self.listArr.count <= 15))) {
            
            NSString *lastFrame = _tagFrame.tagsFrames.lastObject;
            if (CGRectFromString(lastFrame).origin.y < 84) {
                return _tagFrame.tagsHeight+75;
            }else{
                return _isPart ? 170 : self.lazyCell.tagsCollecView.contentSize.height+90;

            }
            
        }else{
                return 76.f;
            
        }
    }
    return 76.f;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (_showOnFirst) {
        
        if (indexPath.row == 0) {
            static NSString *cellIdentifier = @"SimilarFilterCellID";
            SimilarFilterCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (!cell) {
                cell = [[SimilarFilterCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            cell.selectedTag = _selectedTag;
            [self initTagFrame];
            cell.tagsArr = _tagFrame.tagsArray;
            
            __weak typeof(self) weakSelf = self;

            cell.clickTag = ^(NSString *tag) {
                NSString *selected = tag;
                if ([selected isEqualToString:_selectedTag]) {
                    return ;
                }
                
                _showOnFirst = YES;
                _isPart = YES;
                NSMutableArray *arr = [NSMutableArray arrayWithArray:_tagFrame.tagsArray];
                [arr removeObject:selected];
                [arr insertObject:selected atIndex:0];
                weakSelf.selectedTag = selected;
                _tagFrame.tagsArray = arr;
                if (![selected isEqualToString:@"综合"]) {
                    [arr removeObject:@"综合"];
                    [arr insertObject:@"综合" atIndex:1];
                }
                [weakSelf.tableView.mj_header beginRefreshing];

           };
            
            NSString *lastFrame = [self lastTagFrame];
            if (CGRectFromString(lastFrame).origin.y < 80) {
                cell.showAllBtn.hidden = YES;
            }else{
                if (!_isPart) {
                    cell.showAllBtn.hidden = YES;
                }else{
                    cell.showAllBtn.hidden = NO;
                    [cell.showAllBtn addTarget:self action:@selector(filterShowAllBtnClick) forControlEvents:UIControlEventTouchUpInside];
                }
            }
            
            if (_showOnFirst) {
                cell.titleLab.text = @"相似项目维度:";
            }else{
                cell.titleLab.text = @"试试其他维度吧";
            }            
            return cell;
            
        }else{
            //相似项目
            static NSString *cellIdentifier = @"SimilarCell";
            CompanyDetailSimilarCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (!cell) {
                cell = [[CompanyDetailSimilarCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            cell.moreBtn.hidden = YES;
            SearchCompanyModel *model = _listArr[indexPath.row-1];;
           
            [cell refreshUI:model];
            cell.iconColor = RANDOM_COLORARR[indexPath.row%6];
            return cell;
            
        }
    }
    
    if ([_selectedTag isEqualToString:@"综合"]) {  //不是第一个
        if (((indexPath.row == 15) && (self.listArr.count > 15)) || ((indexPath.row == self.listArr.count) && (self.listArr.count <= 15))) {

            static NSString *cellIdentifier = @"SimilarFilterCellID";
            SimilarFilterCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (!cell) {
                cell = [[SimilarFilterCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            cell.selectedTag = _selectedTag;
            [self initTagFrame];
            cell.tagsArr = _tagFrame.tagsArray;
            __weak typeof(self) weakSelf = self;
            cell.clickTag = ^(NSString *tag) {
                NSString *selected = tag;
                if ([selected isEqualToString:_selectedTag]) {
                    return ;
                }
                _showOnFirst = YES;
                _isPart = YES;
                NSMutableArray *arr = [NSMutableArray arrayWithArray:_tagFrame.tagsArray];
                [arr removeObject:selected];
                [arr insertObject:selected atIndex:0];
                weakSelf.selectedTag = selected;
                _tagFrame.tagsArray = arr;
                
                [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];

                if (![selected isEqualToString:@"综合"]) {
                    [arr removeObject:@"综合"];
                    [arr insertObject:@"综合" atIndex:1];
                }
                [weakSelf.tableView.mj_header beginRefreshing];

            };

            NSString *lastFrame = [self lastTagFrame];
            if (CGRectFromString(lastFrame).origin.y < 80) {
                cell.showAllBtn.hidden = YES;
            }else{
                if (!_isPart) {
                    cell.showAllBtn.hidden = YES;
                }else{
                    cell.showAllBtn.hidden = NO;
                    [cell.showAllBtn addTarget:self action:@selector(filterShowAllBtnClick) forControlEvents:UIControlEventTouchUpInside];
                }
            }
            if (_showOnFirst) {
                cell.titleLab.text = @"相似项目维度:";
            }else{
                cell.titleLab.text = @"试试其他维度吧";
            }
            return cell;
            
        }else{
           
            //相似项目
            static NSString *cellIdentifier = @"SimilarCell";
            CompanyDetailSimilarCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (!cell) {
                cell = [[CompanyDetailSimilarCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            cell.moreBtn.hidden = YES;
            SearchCompanyModel *model;
            if(indexPath.row > 15){
                model = _listArr[indexPath.row-1];
            }else{
                model = _listArr[indexPath.row];
            }
            [cell refreshUI:model];
            cell.iconColor = RANDOM_COLORARR[indexPath.row%6];

            return cell;
            
        }
    }
    return [[UITableViewCell alloc]init];
}

- (NSString*)lastTagFrame{
    NSMutableArray *tagsArr = [NSMutableArray arrayWithArray:self.tagArr];
    [tagsArr removeObject:_selectedTag];
    [tagsArr insertObject:_selectedTag atIndex:0];
    if (![_selectedTag isEqualToString:@"综合"]) {
        [tagsArr removeObject:@"综合"];
        [tagsArr insertObject:@"综合" atIndex:1];
    }
    _tagFrame = [self getHeightFromArr:tagsArr];
    return [_tagFrame.tagsFrames lastObject];
}

- (void)initTagFrame{
    
    if (_isPart) { //只显示部分，随着顺序改变，展示的个数也会变
        NSMutableArray *tagsArr = [NSMutableArray array];
        for (int i=0; i<_tagFrame.tagsArray.count; i++) {
            CGRect frame = CGRectFromString(_tagFrame.tagsFrames[i]);
            
            if (frame.origin.y >= (12+(12+24)*2)) {
                break;
            }
            [tagsArr addObject:_tagFrame.tagsArray[i]];
        }
        
        _tagFrame = [self getHeightFromArr:tagsArr];
        
    }else{
        
        NSMutableArray *tagsArr = [NSMutableArray arrayWithArray:self.tagArr];
        [tagsArr removeObject:_selectedTag];
        [tagsArr insertObject:_selectedTag atIndex:0];
        _tagFrame = [self getHeightFromArr:tagsArr];
    }
    
}
- (void)filterShowAllBtnClick{
    _isPart = NO;
    NSMutableArray *arr = [NSMutableArray arrayWithArray:self.tagArr];
    [arr removeObject:_selectedTag];
    [arr insertObject:_selectedTag atIndex:0];
    _tagFrame = [self getHeightFromArr:arr];
    [self.tableView reloadData];

//    if (_showOnFirst) {
//        [self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
////        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
//
//    }else{
//        if (self.listArr.count > 15 && self.tagArr.count > 15) {
//            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:15 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:YES];
//
//        }else if(self.tagArr.count > 15){
//            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.listArr.count inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:YES];
//
//        }
//    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (_showOnFirst) {
        if (indexPath.row == 0) {
            return;
        }else{
            //相似项目
            SearchCompanyModel *model = _listArr[indexPath.row-1];;
            
            NSDictionary *urlDict = [PublicTool toGetDictFromStr:model.detail];
            [[AppPageSkipTool shared] appPageSkipToProductDetail:urlDict];
            return;
        }
    }
    
    if ([_selectedTag isEqualToString:@"综合"]) {  //不是第一个
        if (((indexPath.row == 15) && (self.listArr.count > 15)) || ((indexPath.row == self.listArr.count) && (self.listArr.count <= 15))) {
        
            return;

        }else{
            
            //相似项目
            SearchCompanyModel *model;
            if(indexPath.row > 15){
                model = _listArr[indexPath.row-1];
            }else{
                model = _listArr[indexPath.row];
            }
            //相似项目
            NSDictionary *urlDict = [PublicTool toGetDictFromStr:model.detail];
            [[AppPageSkipTool shared] appPageSkipToProductDetail:urlDict];

            [QMPEvent event:@"pro_similarCellClick"];
            return;
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([[tableView cellForRowAtIndexPath:indexPath] isKindOfClass:[CompanyDetailSimilarCell class]]) {
        return YES;
    }
    return NO;
}

-(UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath{
    //相似项目
    NSString *actionText = @"";
    
    SearchCompanyModel *model;
    if (_showOnFirst) {
        if (indexPath.row == 0) {
            return nil;
        }else{
            //相似项目
            model = _listArr[indexPath.row-1];;
        }
    }
    
    if ([_selectedTag isEqualToString:@"综合"]) {  //不是第一个
        if (((indexPath.row == 15) && (self.listArr.count > 15)) || ((indexPath.row == self.listArr.count) && (self.listArr.count <= 15))) {
            
            return nil;
            
        }else{
            
            //相似项目
            if(indexPath.row > 15){
                model = _listArr[indexPath.row-1];
            }else{
                model = _listArr[indexPath.row];
            }
            
            
        }
    }
    
    if (model.isFeedback.boolValue) {
        actionText = @"已反馈";
    }else{
        actionText = @"不是相似项目";
    }
    UIContextualAction *isReadAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:actionText handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        
        //提交快速单个相似项目反馈
        [self singleImmediateFeedbackUs:model];
        
    }];
    
    if (model.isFeedback) {
        isReadAction.backgroundColor = [UIColor lightGrayColor];
    }else{
        isReadAction.backgroundColor = RED_TEXTCOLOR;
    }
    
    UISwipeActionsConfiguration *action = [UISwipeActionsConfiguration configurationWithActions:@[isReadAction]];
    action.performsFirstActionWithFullSwipe = NO;
    return action;

}


- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (iOS11_OR_HIGHER) {
        return @[];
        
    }
    //相似项目
    NSString *actionText = @"";
    
    SearchCompanyModel *model;
    if (_showOnFirst) {
        if (indexPath.row == 0) {
            return nil;
        }else{
            //相似项目
            model = _listArr[indexPath.row-1];;
        }
    }
    
    if ([_selectedTag isEqualToString:@"综合"]) {  //不是第一个
        if (((indexPath.row == 15) && (self.listArr.count > 15)) || ((indexPath.row == self.listArr.count) && (self.listArr.count <= 15))) {
            
            return nil;
            
        }else{
            
            //相似项目
            if(indexPath.row > 15){
                model = _listArr[indexPath.row-1];
            }else{
                model = _listArr[indexPath.row];
            }
            
            
        }
    }
    if (model.isFeedback.boolValue) {
        actionText = @"已反馈";
    }else{
        actionText = @"不是相似项目";
    }
    
    UITableViewRowAction *isReadAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:actionText handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        //提交快速单个相似项目反馈
        [self singleImmediateFeedbackUs:model];
    }];
    
    if (model.isFeedback) {
        isReadAction.backgroundColor = [UIColor lightGrayColor];
    }else{
        isReadAction.backgroundColor = RED_TEXTCOLOR;
    }
    
    return @[isReadAction];
}
#pragma mark - 请求相似项目信息
- (BOOL)requestData{
    if (![super requestData]) {
        return NO;
    }
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setValue:@(self.numPerPage) forKey:@"num"];
    [param setValue:@(self.currentPage) forKey:@"page"];
    [param setValue:[_selectedTag isEqualToString:@"综合"]?@"":_selectedTag forKey:@"tag_similar"];
    [param setValue:self.requestDict[@"ticket"] forKey:@"ticket"];

    [AppNetRequest getCompanySimilarWithParameter:param completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {

        [self hideHUD];
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        if (resultData && [resultData isKindOfClass:[NSDictionary class]] && [resultData[@"list"] isKindOfClass:[NSArray class]]) {
            NSMutableArray *marr = [NSMutableArray array];
            for (NSDictionary *info in resultData[@"list"]) {
                SearchCompanyModel *news = [[SearchCompanyModel alloc] initWithDictionary:info error:nil];
                [marr addObject:news];
            }
            if (self.currentPage == 1) {
                [self.listArr removeAllObjects];
            }
            [self.listArr addObjectsFromArray:marr];
            [self refreshFooter:marr];
            [self.tableView reloadData];
            if (self.currentPage == 1) {
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
            }

        }
    }];
    return YES;
}
- (void)showFeedbackAlert{
    BOOL haveAlert = [USER_DEFAULTS boolForKey:[NSString stringWithFormat:@"showFeedbackAlert%@",NSStringFromClass([self class])]];
    if (!haveAlert) {
        [PublicTool alertActionWithTitle:@"提示" message:@"向左滑动可反馈错误信息" btnTitle:@"确定" action:^{
            [USER_DEFAULTS setValue:@(YES) forKey:[NSString stringWithFormat:@"showFeedbackAlert%@",NSStringFromClass([self class])]];
        }];
    }
    
}
#pragma mark - public

/**
 *  点击左侧返回按钮
 */
- (void)pressLeftButtonItem:(id)sender{
    
    self.refreshCompanySimilarInfoBlock(self.listArr);
    [self.navigationController popViewControllerAnimated:YES];
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
        [infoDic setValue:@"竞品" forKey:@"module"];//模块
        
        if (![PublicTool isNull:_companyItem.product]) {
            [infoDic setValue:_companyItem.product forKey:@"product"];
        }else{
            [infoDic setValue:@"" forKey:@"product"];
        }
        if (![PublicTool isNull:_companyItem.company]) {
            [infoDic setValue:_companyItem.company forKey:@"company"];
        }else{
            [infoDic setValue:@"" forKey:@"company"];
        }
        
        if (_listArr) {
            if (_listArr.count>0) {
                [mArr addObject:@"相似项目不全"];
                [mArr addObject:@"相似项目不准"];
                moduleNum = _listArr.count;
            }
        }
        if (_listArr.count<=0||!_listArr||![_listArr isKindOfClass:[NSArray class]]) {
            [mArr addObject:@"相似项目缺失"];
            moduleNum = 0;
        }
        
        if (mArr.count>0) {
            //                        height+=((mArr.count+1)/2*40+(mArr.count-1)/2*5);//40是选项按钮高度,间隙为5
            height += ((mArr.count-1)/2+1)*35 + 55.f;
        }
        [infoDic setValue:@"相似项目列表信息" forKey:@"title"];

        [self feedbackAlertView:mArr frame:frame WithAlertViewHeight:height moduleDic:infoDic moduleNum:moduleNum];
    }
}

- (void)feedbackAlertView:(NSMutableArray *)mArr frame:(CGRect)frame WithAlertViewHeight:(CGFloat)height moduleDic:(NSDictionary *)infoDic moduleNum:(NSInteger)num{
    
    CustomAlertView *alert = [[CustomAlertView alloc] initWithAlertViewHeight:mArr frame:frame WithAlertViewHeight:height infoDic:(NSDictionary *)infoDic viewcontroller:self moduleNum:num isFeeds:NO];
}

- (void)initTableView{

    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH - kScreenTopHeight) style:UITableViewStyleGrouped];
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor whiteColor];

    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.mj_header = self.mjHeader;
    self.tableView.mj_footer = self.mjFooter;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.mjFooter.stateLabel.hidden = NO;
    self.mjFooter.state = MJRefreshStateNoMoreData;
    [self.mjFooter endRefreshingWithNoMoreData];
    
    UIView *footV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENH, kScreenBottomHeight)];
    footV.backgroundColor = TABLEVIEW_COLOR;
    self.tableView.tableFooterView = footV;
    
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
}

- (void)pullDown{
    _isPart = YES;
    self.currentPage = 1;
    [self requestData];
}

-(void)pullUp{
    self.currentPage++;
    [self requestData];
}

/**
 单个相似项目立即反馈
 
 @param similarModel
 */
- (void)singleImmediateFeedbackUs:(SearchCompanyModel *)similarModel{
    
    if (similarModel.isFeedback.boolValue) {
        return;
    }
    if (![TestNetWorkReached networkIsReached:self]) {
        return;
    }else{
        
        NSArray *similarArr = self.listArr;
        
        NSMutableDictionary *mDict = [[NSMutableDictionary alloc] initWithCapacity:0];
        [mDict setValue:@"竞品" forKey:@"type"];
        [mDict setValue:@"" forKey:@"c1"];
        [mDict setValue:[NSString stringWithFormat:@"%ld",(unsigned long)similarArr.count] forKey:@"c2"];
        [mDict setValue:similarModel.product forKey:@"c3"];
        [mDict setValue:self.companyItem.company forKey:@"company"];
        [mDict setValue:self.companyItem.product forKey:@"product"];
        [mDict setValue:@"不是相似项目" forKey:@"desc"];
        
        [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:@"h/editcommonfeedback" HTTPBody:mDict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
            
        }];
        
        [self.tableView setEditing:NO];
        
        similarModel.isFeedback = @(YES);
        [self.hudTool showHudOnViewAutoHide:self.view withInfo:@"感谢您的反馈"];
        
    }
}


#pragma mark - 懒加载
- (ManagerHud *)hudTool{
    
    if (!_hudTool) {
        _hudTool = [[ManagerHud alloc] init];
    }
    return _hudTool;
}

-(NSMutableArray *)listArr{
    if (!_listArr) {
        _listArr = [NSMutableArray array];
    }
    return _listArr;
}

-(SimilarFilterCell *)lazyCell{
    if (!_lazyCell) {
        _lazyCell = [[SimilarFilterCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SimilarFilterCellIDID"];
        _lazyCell.tagsCollecView.width = SCREENW;

    }
    return _lazyCell;
}

@end
