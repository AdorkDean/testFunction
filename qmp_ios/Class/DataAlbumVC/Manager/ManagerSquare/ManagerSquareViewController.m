//
//  ManagerSquareViewController.m
//  qmp_ios
//
//  Created by Molly on 16/9/5.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import "ManagerSquareViewController.h"
#import "OneSquareListViewController.h"
#import "AlbumsListCell.h"
#import "HotMgrListCell.h"
#import "AlbumMultiRowListCell.h"
#import "GroupModel.h"

@interface ManagerSquareViewController ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>{
    
    NSInteger _currentPage;
    NSInteger _num;
    NSInteger _searchCurrentPage;
    NSInteger _searchNum;
}


@property (strong, nonatomic) UIView *tableHeaderView;
@property (strong, nonatomic) UIButton *cancleSearchBtn;

@property (strong, nonatomic) NSMutableArray *groupArr;
@property (strong, nonatomic) NSMutableArray *hotArr;

@property (strong, nonatomic) NSMutableArray *searchArr;
@property (assign, nonatomic) BOOL isSearch;

@property (strong, nonatomic) ManagerHud *hudTool;
@property (strong, nonatomic) MJRefreshAutoNormalFooter *footer;

@end

@implementation ManagerSquareViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self hideNavigationBarLine];
    self.tableView.backgroundColor = [UIColor whiteColor];
    [QMPEvent beginEvent:@"trz_square_timer"];

}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self showNavigationBarLine];
    [IQKeyboardManager sharedManager].enable = YES;
    [self.view endEditing:YES];
    [QMPEvent endEvent:@"trz_square_timer"];

}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveLeaveSquareNotificationCenter) name:@"leaveSquare" object:nil];
   
    
    [self initTableView];
    _currentPage = 1;
    _num = 20;
    
    _searchNum = 20;

    [self keyboardManager];
    
    [self showHUD];
    
    if (self.isTop) {
        self.title = @"榜单";
        [self requestManagerList:_currentPage ofNum:_searchNum];
        
    }else if ([TestNetWorkReached networkIsReachedNoAlert]) {
        self.title = @"专辑库";

        [self requestHotSquareList];
        [self requestManagerList:_currentPage ofNum:_searchNum];

    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
-(void)dealloc{

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UISearchBar
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    
    self.mjFooter.stateLabel.hidden = YES;
    
    _searchCurrentPage = 1;
    
    if (!self.isSearch) {
        
        self.isSearch = YES;
        CGRect frame = searchBar.frame;
        frame.size.width = SCREENW - 58;
        searchBar.frame = frame;
        

        [self.tableHeaderView addSubview:self.cancleSearchBtn];
        
        self.searchArr = [[NSMutableArray alloc] initWithCapacity:0];
        [self.tableView reloadData];
        [QMPEvent event:@"trz_square_searchclick"];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    _searchCurrentPage = 1;
    self.isSearch = YES;

    if (self.tableView.mj_footer.state == MJRefreshStateNoMoreData) {
        [self.tableView.mj_footer resetNoMoreData];
    }
    if ([searchBar.text isEqualToString:@""]) {
        self.searchArr = [[NSMutableArray alloc] initWithCapacity:0];
        [self.tableView reloadData];
    }

}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    if (![searchBar.text isEqualToString:@""]) {
        _searchCurrentPage = 1;
        _isSearch = YES;
        _mySearchBar.text = [_mySearchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        [self requestManagerList:_searchCurrentPage ofNum:_searchNum];
        [self.mySearchBar resignFirstResponder];
    }
}


#pragma mark - UITableView

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
    
    NSInteger count = 0;
    if (self.isSearch) {
        if ([self.mySearchBar.text isEqualToString:@""]) {
            count = 0;
        }
        else{
            if (self.searchArr.count > 0) {
                count = self.searchArr.count;
            }
            else{
                count = 1;
            }
        }
    }
    else{
        
        count = self.hotArr.count + self.groupArr.count > 0 ? (self.hotArr.count + self.groupArr.count) : 1;
    }
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ((_isSearch && ![self.mySearchBar.text isEqualToString:@""] && self.searchArr.count == 0) || self.groupArr.count == 0) {
        
        return SCREENH - kScreenTopHeight - kScreenBottomHeight;
  
    }else{
        if (_isSearch && self.searchArr.count) {
            return 59;
        }
        if (indexPath.row+1 > self.hotArr.count) {
            return 59;
        }else{
            return 105;
        }
        
        return 60;
        
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ((self.groupArr.count == 0 && self.hotArr.count == 0 && !self.isSearch ) || (self.searchArr.count == 0 && self.isSearch)) {
        
        NSString *title = self.isSearch ? REQUEST_SEARCH_NULL : REQUEST_DATA_NULL;
        return [self nodataCellWithInfo:title tableView:tableView];
    }
    else{
        if (self.isSearch) {
            GroupModel *groupModel = self.searchArr[indexPath.row];
            if (_isTop) {
                NSString *groupCellIdentifier = @"AlbumMultiRowListCellID";
                AlbumMultiRowListCell *cell = [tableView dequeueReusableCellWithIdentifier:groupCellIdentifier forIndexPath:indexPath];
                cell.keyword = _isSearch ? _mySearchBar.text : nil;
                cell.groupModel = groupModel;
                
                return cell;
            }else{
                NSString *groupCellIdentifier = @"AlbumsListCellID";
                AlbumsListCell *cell = [tableView dequeueReusableCellWithIdentifier:groupCellIdentifier forIndexPath:indexPath];
                
                cell.keyword = _isSearch ? _mySearchBar.text : nil;
                cell.groupModel = groupModel;
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            }
            return nil;
        }else{
            if (_isTop) {//来源榜单
                QMPLog(@"%@", @"榜单");
                if (indexPath.row+1 > self.hotArr.count) {
                    NSString *groupCellIdentifier = @"AlbumMultiRowListCellID";
                    AlbumMultiRowListCell *cell = [tableView dequeueReusableCellWithIdentifier:groupCellIdentifier forIndexPath:indexPath];
                    GroupModel *groupModel = self.groupArr[indexPath.row-self.hotArr.count];
                    
                    cell.keyword = _isSearch ? _mySearchBar.text : nil;
                    cell.groupModel = groupModel;
                    
                    return cell;
                }
            }else{
                if (indexPath.row+1 > self.hotArr.count) {
                    NSString *groupCellIdentifier = @"AlbumsListCellID";
                    AlbumsListCell *cell = [tableView dequeueReusableCellWithIdentifier:groupCellIdentifier forIndexPath:indexPath];
                    
                    GroupModel *groupModel = self.groupArr[indexPath.row-self.hotArr.count];
                    
                    cell.keyword = _isSearch ? _mySearchBar.text : nil;
                    cell.groupModel = groupModel;
                    
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    return cell;
                    
                }else{
                    HotMgrListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HotMgrListCellID" forIndexPath:indexPath];
                    
                    GroupModel *groupModel = self.hotArr[indexPath.row];
                    cell.groupModel = groupModel;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    return cell;
                }
            }
            
            return nil;
        }       
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   if([self noDataIsAllowSelectedTbVw:tableView withIndexPaht:indexPath]){return;}
    
    if ((self.groupArr.count >0 && !self.isSearch ) || (self.searchArr.count > 0 && self.isSearch)){
      
         //判断网络连接状态
        if (![TestNetWorkReached networkIsReached:self]) {
            return;
        }
        GroupModel *group;
        if (self.isSearch) {
            group = self.searchArr[indexPath.row];
        }else{
            if (indexPath.row+1 > self.hotArr.count) {
                group = self.groupArr[indexPath.row-self.hotArr.count];
                [QMPEvent event:@"trz_square_cellclick"];

            }else{
                group = self.hotArr[indexPath.row];
                [QMPEvent event:@"trz_square_hotcellclick"];
                
            }
        }
        //跳转,请求分组列表
        OneSquareListViewController *listVC = [[OneSquareListViewController alloc] init];
        listVC.groupModel = group;
        listVC.action = @"ManagerSquare";
        listVC.hidesBottomBarWhenPushed = YES;
        if (_isSearch) {
        }else{

        }
        [self.navigationController pushViewController:listVC animated:YES];
    
    }

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if (self.isSearch && [self.mySearchBar.text isEqualToString:@""]) {
        [self cancleSearch];
    }
    else{
        
        if ([self.mySearchBar isFirstResponder]) {
            [self.mySearchBar resignFirstResponder];
        }
        
    }
}

#pragma mark - 请求获取列表
- (void)beginSearch:(NSString*)text{
    
    [self.searchArr removeAllObjects];

    if (!self.isSearch) {
        
        self.isSearch = YES;
        CGRect frame = self.mySearchBar.frame;
        frame.size.width = SCREENW - 58;
        self.mySearchBar.frame = frame;
        
        [self.tableHeaderView addSubview:self.cancleSearchBtn];
        
        [self.tableView reloadData];
    }
    
    self.mySearchBar.text = text;
    _searchCurrentPage = 1;
    _searchNum = 20;
    [self requestManagerList:_searchCurrentPage ofNum:_searchNum];
}


- (void)requestHotSquareList{
    
    [AppNetRequest getHotAlbumWithParameter:@{} completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        if (resultData && resultData[@"hot"]) {
            [self.hotArr removeAllObjects];
            for (NSDictionary *dic in resultData[@"hot"]) {
                GroupModel *model = [[GroupModel alloc]initWithDictionary:dic error:nil];
                [self.hotArr addObject:model];
            }
        }
        if (self.isTop) {
            [self.tableView reloadData];
        }else if (self.groupArr.count) {
            [self.tableView reloadData];
        }
        
    }];

}

- (void)requestManagerList:(NSInteger )page ofNum:(NSInteger )num{
    
    if ([TestNetWorkReached networkIsReached:self]) {
        
        if ([self.mySearchBar.text isEqualToString:@""] && self.searchArr.count > 0) {
            [self.searchArr removeAllObjects];
        }
        
        NSString *type = self.isTop ? @"top":@"";
        NSMutableDictionary *searchDict = [NSMutableDictionary dictionaryWithDictionary:@{@"page":@(page),@"num":@(num),@"type":type}];
        
        ManagerHud *hudTool = [[ManagerHud alloc] init];
        UIView *searchHudView = [[UIView alloc] initWithFrame:CGRectMake(0, 44, SCREENW, SCREENH - 64.f - kScreenBottomHeight - 50.f)];
        if (self.isSearch) {
            [searchDict setValue:self.mySearchBar.text forKey:@"keywords"];
            [searchDict setValue:type forKey:@"type"];
            if (_searchCurrentPage == 1 && ![self.tableView.mj_header isRefreshing]) {
                [hudTool addHud:searchHudView];
                searchHudView.backgroundColor = [UIColor whiteColor];
                [self.view addSubview:searchHudView];
            }
        }

        [AppNetRequest getAlbumListWithParameter:searchDict completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
           
            [self hideHUD];
            [searchHudView removeFromSuperview];
            [self.tableView.mj_header endRefreshing];
            [self.tableView.mj_footer endRefreshing];
            
            if (resultData && resultData[@"list"]) {
                
                NSMutableArray *groupMarr = [NSMutableArray array];
                for (NSDictionary *dic in resultData[@"list"]) {
                    GroupModel *model = [[GroupModel alloc]initWithDictionary:dic error:nil];
                    [groupMarr addObject:model];
                }
                
                if (self.isSearch) {
                    //搜索状态下
                    if (_searchCurrentPage == 1) {
                        self.searchArr = groupMarr;
                    }
                    else{
                        [self.searchArr addObjectsFromArray:groupMarr];
                        
                    }
                }else{
                    
                    //正常状态下包含分页
                    if (_currentPage == 1) {
                        self.groupArr = groupMarr;
                        
                    }else{
                        [self.groupArr addObjectsFromArray:groupMarr];
                        
                    }
                }
                
                [self changeDataFooter:groupMarr];
                if (self.isTop) {
                    [self.tableView reloadData];
                }else if (self.hotArr.count) {
                    [self.tableView reloadData];
                }
            }
        }];
        
    }else{

        [self hideHUD];
        [self.tableView.mj_footer endRefreshing];
        [self.tableView.mj_header endRefreshing];
        
    }
}

#pragma mark - public

- (void)changeDataFooter:(NSMutableArray *)arr{
    
    if (arr.count < _num) {
   
        self.mjFooter.stateLabel.hidden = NO;
        [self.mjFooter endRefreshingWithNoMoreData];
        
    }else{
        self.mjFooter.stateLabel.hidden = YES;
        self.mjFooter.state = MJRefreshStateIdle;

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

- (void)initTableView{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH  - kScreenTopHeight) style:UITableViewStyleGrouped];
    [self.view addSubview:self.tableView];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.mj_header = self.mjHeader;
    self.tableView.mj_footer = self.mjFooter;

    [self.tableView registerNib:[UINib nibWithNibName:@"AlbumsListCell" bundle:[BundleTool commonBundle]] forCellReuseIdentifier:@"AlbumsListCellID"];
    [self.tableView registerNib:[UINib nibWithNibName:@"HotMgrListCell" bundle:[BundleTool commonBundle]] forCellReuseIdentifier:@"HotMgrListCellID"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"AlbumMultiRowListCell" bundle:[BundleTool commonBundle]] forCellReuseIdentifier:@"AlbumMultiRowListCellID"];//多行榜单

    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    
    CGFloat height = 44.f;

    _tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, height)];
    _tableHeaderView.backgroundColor = TABLEVIEW_COLOR;
    self.tableView.tableHeaderView = _tableHeaderView;
    
    _mySearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(7, 0, SCREENW-14, height)];
    [_mySearchBar setBackgroundImage:[UIImage imageFromColor:TABLEVIEW_COLOR andSize:_mySearchBar.size]];
//    _mySearchBar.backgroundImage = [BundleTool imageNamed:@"nav-lightgray"];
    //设置背景色
    [_mySearchBar setBackgroundColor:TABLEVIEW_COLOR];
    [_mySearchBar setSearchFieldBackgroundImage:[BundleTool imageNamed:@"search_borderTab"] forState:UIControlStateNormal];
    [_mySearchBar setSearchTextPositionAdjustment:UIOffsetMake(10, 0)];
    UITextField *tf = [_mySearchBar valueForKey:@"_searchField"];
    tf.font = [UIFont systemFontOfSize:14];
    NSString *str = self.isTop ? @"搜索榜单" : @"搜索专辑";
    tf.attributedPlaceholder = [[NSAttributedString alloc]initWithString:str attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]}];

    _mySearchBar.delegate = self;
    [_tableHeaderView addSubview:_mySearchBar];
    
    CGFloat width = 60.f;
    _cancleSearchBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    [_cancleSearchBtn setTitle:@"取消" forState:UIControlStateNormal];
    _cancleSearchBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [_cancleSearchBtn setTitleColor:HTColorFromRGB(0x555555) forState:UIControlStateNormal];
    [_cancleSearchBtn addTarget:self action:@selector(pressCancleSearchBtn:) forControlEvents:UIControlEventTouchUpInside];
    _cancleSearchBtn.frame = CGRectMake(SCREENW - width - 1, (_tableHeaderView.frame.size.height - height)/2, width, height);
    
//    //底部线条
//    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, _tableHeaderView.height - 0.5, SCREENW, 0.5)];
//    line.backgroundColor = HTColorFromRGB(0xd2d2d2);
//    [_tableHeaderView addSubview:line];
}

- (void)pullDown{
    
    if (self.tableView.mj_footer.state == MJRefreshStateNoMoreData) {
        [self.tableView.mj_footer resetNoMoreData];
    }

    if (self.isSearch) {
        
        _searchCurrentPage = 1;
        [self requestManagerList:_searchCurrentPage ofNum:_searchNum];
    }
    else{
        
        _currentPage = 1;
        [self requestManagerList:_currentPage ofNum:_searchNum];

    }
}
- (void)pullUp{

    if (self.isSearch) {
        
        _searchCurrentPage ++;
        [self requestManagerList:_searchCurrentPage ofNum:_searchNum];
    }
    else{
        _currentPage ++;
        
        [self requestManagerList:_currentPage ofNum:_searchNum];
    }
}

- (void)pressCancleSearchBtn:(UIButton *)sender{
    [self cancleSearch];
}

- (void)disAppear{  //左右切换

    if (self.mySearchBar.text.length == 0 && self.isSearch) {
        [self cancleSearch];
    }
}

- (void)cancleSearch{
    
    if (self.tableView.mj_footer.state == MJRefreshStateNoMoreData) {
        [self.tableView.mj_footer resetNoMoreData];
    }
    
    self.isSearch = NO;
    [self.searchArr removeAllObjects];
    
    [self.mySearchBar resignFirstResponder];
    CGRect frame = self.mySearchBar.frame;
    frame.size.width = SCREENW - 14;
    self.mySearchBar.frame = frame;
    self.mySearchBar.text = @"";
    
    [self.cancleSearchBtn removeFromSuperview];
    
    [self.tableView reloadData];
    [self changeDataFooter:self.groupArr];
}

- (void)receiveLeaveSquareNotificationCenter{

    if (_isSearch) {
        [self cancleSearch];
    }
}

#pragma mark - 懒加载

- (NSMutableArray *)groupArr{
    
    if (!_groupArr) {
        _groupArr = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _groupArr;
}
- (NSMutableArray *)searchArr{
    
    if (!_searchArr) {
        _searchArr = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _searchArr;
}
- (NSMutableArray *)hotArr{
    
    if (!_hotArr) {
        _hotArr = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _hotArr;
}


-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleDefault;
}

@end
