//
//  CardExchangeListController.m
//  qmp_ios
//
//  Created by QMP on 2018/6/6.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "CardExchangeListController.h"
#import "CardListCell.h"
#import "CardToContactController.h"
#import "ProductContactDetailVC.h"

@interface CardExchangeListController ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>
{
    NSInteger _searchCurrentPage;
}
@property(nonatomic,assign)BOOL isSearch;
@property(nonatomic,strong)UISearchBar *mySearchBar;
@property(nonatomic,strong) NSMutableArray *searchArr;
@property(nonatomic,strong) NSMutableArray *listArr;
@property(nonatomic,strong)UIButton *cancleSearchBtn;
@property(nonatomic,strong)UIView *tableHeaderView;
@property(nonatomic,strong)UIView *bottomView;
@property(nonatomic,assign)CGFloat originOffsetY;

@end

@implementation CardExchangeListController
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.tableView.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"通讯录";
    [self setUI];
    _searchCurrentPage = 1;
    self.numPerPage = 20;
    self.currentPage = 1;
    [self showHUD];
    [self requestData];
    [self keyboardManager];
    
    if ([WechatUserInfo shared].exchange_card_count.integerValue) {
        
        [AppNetRequest updateUnreadCountWithKey:@"exchange_card_count" type:@"交换的名片" completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
            
        }];
    }
    
}


-(void)keyboardManager{
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    //设置成NO表示当前控件响应后会传播到其他控件上，默认为YES。
    tapGestureRecognizer.cancelsTouchesInView = NO;
    
    [self.view addGestureRecognizer:tapGestureRecognizer];
    self.view.userInteractionEnabled = YES;
}

- (void)keyboardHide:(UITapGestureRecognizer *)tap{
    
    if (tap.view != self.mySearchBar) {
        if (self.isSearch && [self.mySearchBar.text isEqualToString:@""]) {
            [self cancleSearch];
        }
        else{
            [self.mySearchBar resignFirstResponder];
        }
    }
}


- (void)setUI{
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH - kScreenTopHeight) style:UITableViewStyleGrouped];
    [self.view addSubview:self.tableView];
    
    self.tableView.backgroundColor = TABLEVIEW_COLOR;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"headerView"];
    self.tableView.mj_header = self.mjHeader;
    [self.tableView setSectionIndexBackgroundColor:[UIColor clearColor]];
    [self.tableView setSectionIndexColor:[UIColor darkGrayColor]];
    
    
    CGFloat height = 44.f;
    
    _tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, height)];
    _tableHeaderView.backgroundColor = [UIColor whiteColor];
    
    _mySearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(7, 0, SCREENW-14, height)];
    [_mySearchBar setBackgroundImage:[UIImage imageFromColor:[UIColor whiteColor] andSize:_mySearchBar.size]];
    //设置背景色
    [_mySearchBar setBackgroundColor:[UIColor whiteColor]];
    [_mySearchBar setSearchFieldBackgroundImage:[BundleTool imageNamed:@"card_search_bg"] forState:UIControlStateNormal];
    [_mySearchBar setSearchTextPositionAdjustment:UIOffsetMake(10, 0)];
    UITextField *tf = [_mySearchBar valueForKey:@"_searchField"];
    tf.font = [UIFont systemFontOfSize:14];
    NSString *str = @"搜索姓名、公司、职务等";
    tf.attributedPlaceholder = [[NSAttributedString alloc]initWithString:str attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13],NSForegroundColorAttributeName:H999999}];
    
    _mySearchBar.delegate = self;
    [_tableHeaderView addSubview:_mySearchBar];
    
    CGFloat width = 60.f;
    _cancleSearchBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    [_cancleSearchBtn setTitle:@"取消" forState:UIControlStateNormal];
    _cancleSearchBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [_cancleSearchBtn setTitleColor:HTColorFromRGB(0x555555) forState:UIControlStateNormal];
    [_cancleSearchBtn addTarget:self action:@selector(pressCancleSearchBtn:) forControlEvents:UIControlEventTouchUpInside];
    _cancleSearchBtn.frame = CGRectMake(SCREENW - width - 1, (_tableHeaderView.frame.size.height - height)/2, width, height);
    
}


#pragma mark --Event--
- (void)addfriendNoti{
    [self.tableView.mj_header beginRefreshing];
}
- (void)friendDeleteNoti{
    [self.tableView.mj_header beginRefreshing];
}


#pragma mark --Data
-(void)pullDown{
    
    [super pullDown];
}

-(BOOL)requestData{
    
    if (![super requestData]) {
        
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        
        return NO;
    }
    NSInteger currentPage = _isSearch ? _searchCurrentPage:self.currentPage;
    //后台没分页
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:@(currentPage),@"page",@(self.numPerPage),@"num",self.mySearchBar.text,@"keyword", nil];
    [AppNetRequest getMyfriendListWithParameter:dic completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        [self hideHUD];
        
        if (resultData && [resultData isKindOfClass:[NSArray class]]) {
            
            NSMutableArray *arr = [NSMutableArray array];
            for (NSDictionary *dic in resultData) {
                FriendModel *person = [[FriendModel alloc]initWithDictionary:dic error:nil];
                [PublicTool saveFriendInfo:@[person]];
                [arr addObject:person];
            }
            
            if (_isSearch) {
                [self.searchArr removeAllObjects];
                [self.searchArr addObjectsFromArray:arr];
                
            }else{
                if (self.currentPage == 1) {
                    [self.listArr removeAllObjects];
                }
                if (arr.count) {
                    [self.listArr addObjectsFromArray:arr];
                }
                
            }
            [self refreshFooter:arr];
            
        }

        if (self.listArr.count != 0) {
           
            if(!self.tableView.tableHeaderView){
                self.tableView.tableHeaderView = _tableHeaderView;
            }
            [self initBottomView];
        }
        [self.tableView reloadData];
    }];
    
    return YES;
}

#pragma mark - 底部工具
- (void)initBottomView{
    if ([self.bottomView isDescendantOfView:self.view]) {
        
    }else{
        [self.view addSubview:self.bottomView];
    }
}


- (void)refreshFooter:(NSArray *)arr{
    NSInteger currentPage = _isSearch ? _searchCurrentPage:self.currentPage;
    self.tableView.mj_footer = self.mjFooter;
    
    if (arr.count < self.numPerPage) {
        if (currentPage) {
            self.mjFooter.stateLabel.hidden = YES;
            self.mjFooter.state = MJRefreshStateNoMoreData;
            [self.mjFooter endRefreshingWithNoMoreData];
            
        }else{
            self.mjFooter.stateLabel.hidden = NO;
            self.mjFooter.state = MJRefreshStateNoMoreData;
            [self.mjFooter endRefreshingWithNoMoreData];
        }
    }else{
        self.mjFooter.stateLabel.hidden = YES;
        self.mjFooter.state = MJRefreshStateIdle;
    }
}


- (void)cleanConverstaion{
    
    //删除非好友 除掉 从人物详情页联系的对话
    NSArray *conversations = [[EMClient sharedClient].chatManager getAllConversations];
    
    for (EMConversation *conversation in conversations) { //    chatVC.conversation.ext = @{@"from":@"investor"};
        
        BOOL canDelete = YES;
        if ((conversation.ext.allKeys.count && [conversation.ext[@"from"] isEqualToString:@"investor"]) || [conversation.lastReceivedMessage.ext.allKeys containsObject:@"fromInvestor"]) { //来自人物详情页
            canDelete = NO;
            
        }else{
            
            if ([conversation.conversationId isEqualToString:QMPHelperUserCode]) {
                canDelete = NO;
            }else{
                for (FriendModel *friend1 in self.listArr) {
                    if ([conversation.conversationId isEqualToString:friend1.usercode]) {
                        canDelete = NO;
                    }
                }
            }
        }
        
        if (canDelete == YES) { //删除该会话
            [[EMClient sharedClient].chatManager deleteConversation:conversation.conversationId isDeleteMessages:YES
                                                         completion:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"conversationListRefresh" object:nil];
        }
    }
}

- (void)pressCancleSearchBtn:(UIButton *)sender{
    [self cancleSearch];
}


- (void)cancleSearch{
    
    
    self.isSearch = NO;
    [self.searchArr removeAllObjects];
    self.mySearchBar.text = @"";
    [self.mySearchBar resignFirstResponder];
    CGRect frame = self.mySearchBar.frame;
    frame.size.width = SCREENW - 14;
    self.mySearchBar.frame = frame;
    [self.cancleSearchBtn removeFromSuperview];
    
    [self.tableView reloadData];
}

//导入到通讯录
- (void)leadBtnClick{
    
    if (self.listArr.count == 0) {
        [PublicTool showMsg:@"没有数据"];
        return;
    }
    [QMPEvent event:@"me_card_leadBtnClick"];
    CardToContactController *contactVC = [[CardToContactController alloc]init];
    contactVC.cardFrom = CardStyleFromExchange;
    [self.navigationController pushViewController:contactVC animated:YES];
    
}


#pragma mark - UISearchBar
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    
    self.mjFooter.stateLabel.hidden = YES;
    
    if (!self.isSearch) {
        
        self.isSearch = YES;
        CGRect frame = searchBar.frame;
        frame.size.width = SCREENW - 58;
        searchBar.frame = frame;
        
        
        [self.tableHeaderView addSubview:self.cancleSearchBtn];
        
        self.searchArr = [[NSMutableArray alloc] initWithCapacity:0];
        [self.tableView reloadData];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    self.isSearch = YES;
    
    [self.tableView.mj_footer resetNoMoreData];
    
    if ([searchBar.text isEqualToString:@""]) {
        self.searchArr = [[NSMutableArray alloc] initWithCapacity:0];
        [self.tableView reloadData];
    }
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    if (![searchBar.text isEqualToString:@""]) {
        _isSearch = YES;
        _searchCurrentPage = 1;
        [self requestData];
        [self.mySearchBar resignFirstResponder];
    }
}

#pragma mark --UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [[UIView alloc]init];
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc]init];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;

}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.isSearch) {
        return self.searchArr.count ? self.searchArr.count : ([PublicTool isNull:self.mySearchBar.text] ? 0 : 1);
    }
    
    return self.listArr.count ? self.listArr.count:1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.isSearch) {
        return self.searchArr.count ? 75:SCREENH-kScreenTopHeight;
    }
    return self.listArr.count ? 75:SCREENH-kScreenTopHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.isSearch) {
        if ( self.searchArr.count) {
            FriendModel *friend1 = self.searchArr[indexPath.row];
            CardListCell *cell = [CardListCell cellWithTableView:tableView];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.friendM = friend1;
            cell.area = CardStyleFromExchange;
            return cell;
        }else{
            //没有分组
            NSString *info;
            if (self.isSearch) {
                info = @"无该名片";
            }
            
            return [self nodataCellWithInfo:info tableView:tableView];
        }
    }
    
    
    if (self.listArr.count) {
        
        FriendModel *friend1 = self.listArr[indexPath.row];
        CardListCell *cell = [CardListCell cellWithTableView:tableView];
        cell.friendM = friend1;
        cell.area = CardStyleFromExchange;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        
    }else{
        return [self nodataCellWithInfo:REQUEST_DATA_NULL tableView:tableView];
    }
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.isSearch) {
        if (self.searchArr.count == 0) {
            return;
        }
    }else{
        if (self.listArr.count == 0) {
            return;
        }
    }
    
    
    FriendModel *friend1;
    if (self.isSearch) {
        friend1 = self.searchArr[indexPath.row];
    }else{
       friend1 = self.listArr[indexPath.row];
    }
    if([friend1.usercode isEqualToString:QMPHelperUserCode]){
        return;
    }
    
    ProductContactDetailVC *detailVC = [[ProductContactDetailVC alloc]init];
    detailVC.friend1 = friend1;
    [self.navigationController pushViewController:detailVC animated:YES];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
   
    if (self.tableView == scrollView) {
        self.originOffsetY = scrollView.contentOffset.y;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (self.tableView == scrollView) {
        CGFloat VH = SCREENH - kScreenTopHeight;
        if (self.originOffsetY >= 0) {
            if (self.originOffsetY > scrollView.contentOffset.y) {//手指往下滑，显示 +
                //                if (self.bottomView.frame.origin.y == VH - kScreenBottomHeight) {
                //                    return;
                //                }
                [UIView animateWithDuration:0.25 animations:^{
                    self.bottomView.frame = CGRectMake(0, VH - kScreenBottomHeight, SCREENW, kScreenBottomHeight);
                }];
                
            }else{//手指往上滑，隐藏 -
                if (self.bottomView.top == VH) {
                    return;
                }
                [UIView animateWithDuration:0.25 animations:^{
                    self.bottomView.frame = CGRectMake(0, VH, SCREENW, kScreenBottomHeight);
                }];
            }
        }else{
        }
    }
}

- (void)enterFriendPage:(FriendModel*)friend1{
    
    if (![PublicTool isNull:friend1.person_id]) {
        [[AppPageSkipTool shared] appPageSkipToPersonDetail:friend1.person_id];
        
    }else if (![PublicTool isNull:friend1.unionid]) {
        [[AppPageSkipTool shared] appPageSkipToUserDetail:friend1.unionid];
    }
}



#pragma mark --懒加载
-(NSMutableArray *)listArr{
    if (!_listArr) {
        _listArr = [NSMutableArray array];
    }
    return _listArr;
}


-(NSMutableArray *)searchArr{
    if (!_searchArr) {
        _searchArr = [NSMutableArray array];
    }
    return _searchArr;
}

- (UIView *)bottomView{
    if (_bottomView == nil) {
        _bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, SCREENH - kScreenTopHeight - kScreenBottomHeight, SCREENW, kScreenBottomHeight)];
        _bottomView.backgroundColor = [UIColor whiteColor];
        
        
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 0.5)];
        line.backgroundColor = LINE_COLOR;
        [_bottomView addSubview:line];
        
        UIButton *leadBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, SCREENW, kShortBottomHeight)];
        [leadBtn setImage:[BundleTool imageNamed:@"leadToAlbumIcon"] forState:UIControlStateNormal];
        [leadBtn setTitle:@"导出至手机通讯录" forState:UIControlStateNormal];
        [leadBtn layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleLeft imageTitleSpace:7];
        [leadBtn setTitleColor:H5COLOR forState:UIControlStateNormal];
        leadBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [leadBtn addTarget:self  action:@selector(leadBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:leadBtn];
    }
    return _bottomView;
}

@end
