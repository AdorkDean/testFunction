//
//  ProductContactsController.m
//  qmp_ios
//
//  Created by QMP on 2018/5/3.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "ProductContactsController.h"
#import "CardItem.h"
#import "DeleteCardController.h"
#import "CardToContactController.h"
#import "ProductContactDetailVC.h"
#import "CardListCell.h"

@interface ProductContactsController ()<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate,UIImagePickerControllerDelegate,UIAlertViewDelegate,UINavigationControllerDelegate,UISearchBarDelegate>{
    
    NSInteger _currentPage;
    NSInteger _searchNowPage;
    BOOL _isSearching;

}

@property (nonatomic, strong) UIImagePickerController *imagePickerVc;
@property (nonatomic, strong) UIView *addBtn;

@property (strong, nonatomic) UILabel *rightLbl;

@property (strong, nonatomic) CardItem *card;

@property (strong, nonatomic) NSMutableArray *tableData;
@property (nonatomic,strong) UIView *searchBgView;
@property (nonatomic,strong) UIButton *cancleBtn;

@property (strong, nonatomic) NSMutableArray *searchData;
@property (nonatomic,strong) UITapGestureRecognizer *tapCancelSearch;
@property (nonatomic,strong)UIProgressView *progressView;

@property (nonatomic, strong) UIView * bottomView;
@property (nonatomic, assign) CGFloat originOffsetY;
@end

@implementation ProductContactsController

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    self.tableView.backgroundColor = [UIColor whiteColor];
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"委托联系";
    _currentPage = 1;
    self.numPerPage = 20;
    _searchNowPage = 1;
        
    
    [self initTableView];
    
    [self showHUD];
    [self requestData];
}

#pragma mark ----批量操作
- (void)initBottomView{
    if (_bottomView) {
        return;
    }
    _bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, SCREENH - kScreenTopHeight - kScreenBottomHeight, SCREENW, kScreenBottomHeight)];
    _bottomView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_bottomView];
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 0.5)];
    line.backgroundColor = LINE_COLOR;
    [_bottomView addSubview:line];
    
    
    UIButton *delBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, SCREENW/2.0, kShortBottomHeight)];
    [delBtn setTitle:@"删除" forState:UIControlStateNormal];
    [delBtn setImage:[UIImage imageNamed:@"workFlowDel"] forState:UIControlStateNormal];
    [delBtn setTitleColor:H5COLOR forState:UIControlStateNormal];
    delBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [delBtn layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleLeft imageTitleSpace:7];
    [delBtn addTarget:self  action:@selector(deleteBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:delBtn];
    
    
    UIButton *leadBtn = [[UIButton alloc]initWithFrame:CGRectMake(SCREENW/2.0, 0, SCREENW/2.0, kShortBottomHeight)];
    [leadBtn setImage:[UIImage imageNamed:@"leadToAlbumIcon"] forState:UIControlStateNormal];
    [leadBtn setTitle:@"导出至手机通讯录" forState:UIControlStateNormal];
    [leadBtn layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleLeft imageTitleSpace:7];
    [leadBtn setTitleColor:H5COLOR forState:UIControlStateNormal];
    leadBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [leadBtn addTarget:self  action:@selector(leadBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:leadBtn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    
    if (_isSearching && _searchBar.text.length > 0&& _searchData.count == 0)  {
        [self.tableView removeGestureRecognizer:self.tapCancelSearch];
        
        return 1;
    }
    
    [self.tableView removeGestureRecognizer:self.tapCancelSearch];
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _isSearching ? (self.searchData.count ? self.searchData.count:([PublicTool isNull:_searchBar.text] ? 0 : 1)) : (self.tableData.count ? self.tableData.count:1);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return _isSearching ? (self.searchData.count ? 75:SCREENH - kScreenTopHeight) : (self.tableData.count ? 75:SCREENH - kScreenTopHeight);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (_isSearching) {
        if (self.searchData.count > 0) {
            CardListCell *cell = [CardListCell cellWithTableView:tableView];
            cell.cardItem = self.searchData[indexPath.row];
            cell.area = CardStyleFromEntrust;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
    }else{
        if (self.tableData.count > 0) {
            CardListCell *cell = [CardListCell cellWithTableView:tableView];
            cell.cardItem = self.tableData[indexPath.row];
            cell.area = CardStyleFromEntrust;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
    }
    
    NSString *title = _isSearching ? REQUEST_SEARCH_NULL : REQUEST_DATA_NULL;
    return [self nodataCellWithInfo:title tableView:tableView];
}

- (void)cardCellSelectBtnClick:(UIButton*)btn{
    
    NSInteger index = btn.tag - 1000;
    if (_isSearching) {
        CardItem *cardItem = self.searchData[index];
        cardItem.selected = !cardItem.selected;
        
    }else{
        CardItem *cardItem = self.tableData[index];
        cardItem.selected = !cardItem.selected;
    }
    
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if([self noDataIsAllowSelectedTbVw:tableView withIndexPaht:indexPath]){return;}
    
    if (_isSearching) {
        if (self.searchData.count > 0) {
            CardItem *cardItem = self.searchData[indexPath.row];
            ProductContactDetailVC *detailVC = [[ProductContactDetailVC alloc]init];
            detailVC.card = cardItem;
            [self.navigationController pushViewController:detailVC animated:YES];
        }
        
    }else{
        
        if (self.tableData.count > 0) {
            
            CardItem *cardItem = self.tableData[indexPath.row];
            ProductContactDetailVC *detailVC = [[ProductContactDetailVC alloc]init];
            detailVC.card = cardItem;
            [self.navigationController pushViewController:detailVC animated:YES];
            
        }
    }
    
}

#pragma mark --UISearchBarDelegate---
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    
    _isSearching = YES;
    self.addBtn.hidden = YES;
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = self.searchBar.frame;
        frame.size.width = SCREENW - 58;
        self.searchBar.frame = frame;
        self.cancleBtn.hidden = NO;
        
    } completion:nil];
    
    if (!_searchBar.text || _searchBar.text.length == 0) {
        [_searchData removeAllObjects];
        [self.tableView reloadData];
        [self.tableView addGestureRecognizer:self.tapCancelSearch];
    }
    self.tableView.backgroundColor = [UIColor whiteColor];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    
    if (!_searchBar.text || _searchBar.text.length == 0) {
        [_searchData removeAllObjects];
        self.tableView.backgroundColor = [UIColor whiteColor];
        [self.tableView reloadData];
        //        [self setMj_footer];
        [self.tableView addGestureRecognizer:self.tapCancelSearch];
    }
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [PublicTool showHudWithView:KEYWindow];
    _currentPage = 1;
    [self requestData];
    
    [self.searchBar resignFirstResponder];
    
}

- (void)beginSearch:(NSString*)keyword{
//    _isSearching = YES;
//    
//    _searchBar.text = keyword;
//    _currentPage = 1;
//    [self requestData];
//    
//    [self.searchBar resignFirstResponder];
}

- (void)searchResignFirseResponder{
    _isSearching = NO;
    self.addBtn.hidden = NO;
    _searchBar.text = @"";
    [self.tableView.mj_header endRefreshing];
    [UIView animateWithDuration:0.3 animations:^{
        [self.searchBar resignFirstResponder];
        
        CGRect frame = self.searchBar.frame;
        frame.size.width = SCREENW-14;
        self.searchBar.frame = frame;
        self.cancleBtn.hidden = YES;
        
    } completion:^(BOOL finished) {
    }];
    self.tableView.mj_footer.state = MJRefreshStateIdle;
    [self.tableView reloadData];
    
    if (self.tableData.count == 0) {
        [self requestData];
    }
    
}
- (void)cancleBtnTouched
{
    [self searchResignFirseResponder];
}

- (void)tabelViewTapGesture{
    
    if (_isSearching && self.searchData.count == 0) {
        [self searchResignFirseResponder];
        
    }
}
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (_isSearching && (_searchBar.text.length == 0 || !_searchBar.text)) {
        [self searchResignFirseResponder];
        
    }else if(_isSearching && _searchBar.text.length >0 && self.searchData.count){
        [self.searchBar resignFirstResponder];
    }
    if (self.tableView == scrollView) {
        self.originOffsetY = scrollView.contentOffset.y;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (self.tableView == scrollView) {
        CGFloat VH = SCREENH - kScreenTopHeight;
        if (self.originOffsetY >= 0) {
            if (self.originOffsetY > scrollView.contentOffset.y) {//手指往下滑，显示 +
                if (self.bottomView.frame.origin.y == VH - kScreenBottomHeight) {
                    return;
                }
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
#pragma mark - 请求名片列表
- (BOOL)requestData{
    if (![super requestData]) {
        return NO;
    }
    
    NSInteger page = 0;
    
    if (_isSearching) {
        page = _searchNowPage;
    }else{
        page = _currentPage;
    }
    
    NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:[WechatUserInfo  shared].unionid,@"unionid",@"qmp_ios",@"ptype",VERSION,@"version",@(page),@"page",@(self.numPerPage),@"page_num",self.searchBar.text,@"keywords", nil];
    
    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"Entrust/entrustList" HTTPBody:param completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        [self hideHUD];
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        [PublicTool dismissHud:KEYWindow];
        
        if (resultData && [resultData[@"list"] isKindOfClass:[NSArray class]]) {
            NSMutableArray *retMArr = [[NSMutableArray alloc] initWithCapacity:0];

            for (NSDictionary *dic in resultData[@"list"]) {
                CardItem *cardItem = [[CardItem alloc] init];
                [cardItem setValuesForKeysWithDictionary:dic];
                [retMArr addObject:cardItem];
            }
            [self dealData:retMArr];
        }
        
        if (self.tableData.count == 0) {
            self.tableView.tableHeaderView = nil;
        }else{
            [self initBottomView];
        }
        
    }];

    return YES;
}

- (void)dealData:(NSArray*)retMArr{
    
    [self.tableView.mj_header endRefreshing];
    [self.tableView.mj_footer endRefreshing];
    
    
    self.tableView.mj_footer = self.mjFooter;
    [self refreshFooter:retMArr];
    
    if (_isSearching) {
        
        if (_searchNowPage == 1) {
            self.searchData = [NSMutableArray arrayWithArray:retMArr];
            
        }else{
            [self.searchData addObjectsFromArray:retMArr];
        }
        
        [self.tableView reloadData];
        return;
    }
    
    //非搜索
    if (_currentPage == 1) {
        self.tableData = [NSMutableArray arrayWithArray:retMArr];
    }else{
        [self.tableData addObjectsFromArray:retMArr];
    }
    
    [self.tableView reloadData];
}


#pragma mark - public
//删除名片
- (void)deleteBtnClick{
    
    if (self.tableData.count == 0) {
        return;
    }
    
    DeleteCardController *deleteVC = [[DeleteCardController alloc]init];
    deleteVC.type = 1;
    __weak typeof(self) weakSelf = self;
    deleteVC.deleteCardHandle = ^{
        [weakSelf.tableView.mj_header beginRefreshing];
    };
    [self.navigationController pushViewController:deleteVC animated:YES];
}

//导入到通讯录
- (void)leadBtnClick{

    if (self.tableData.count == 0) {
        [PublicTool showMsg:@"没有数据"];
        return;
    }
    [QMPEvent event:@"me_card_leadBtnClick"];
    CardToContactController *contactVC = [[CardToContactController alloc]init];
    contactVC.cardFrom = CardStyleFromEntrust;
    [self.navigationController pushViewController:contactVC animated:YES];
    
}


- (void)initTableView{
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH - kScreenTopHeight) style:UITableViewStylePlain];
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.mj_header = self.mjHeader;
    self.tableView.mj_footer = self.mjFooter;
    self.tableView.tableHeaderView = self.searchBgView;
    
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    
}

- (void)pullDown{
    
    [self.tableView.mj_footer resetNoMoreData];
    
    if (_isSearching) {
        _searchNowPage = 1;
    }else{
        _currentPage = 1;
    }
    
    [self requestData];
}

- (void)pullUp{
    
    [self.tableView.mj_footer beginRefreshing];
    if (_isSearching) {
        _searchNowPage ++;
    }else{
        _currentPage ++;
        
    }
    
    [self requestData];
}



- (void)receiveCardInfoUpdateSuccessNotification:(NSNotification *)notification{
    
    CardItem *updateCard = (CardItem *)notification.object;
    
    NSMutableArray *cardArr = [NSMutableArray arrayWithArray:self.tableData];
    
    for (int i = 0; i < cardArr.count; i ++ ) {
        CardItem *card = cardArr[i];
        if ([card.cardId isEqualToString:updateCard.cardId]) { //更新
            [self.tableData replaceObjectAtIndex:i withObject:updateCard];
            [self.tableView reloadData];
            return;
        }
    }
    
    NSMutableArray *searchCardArr = [NSMutableArray arrayWithArray:self.searchData];
    for (int i = 0; i < searchCardArr.count; i ++ ) {
        
        CardItem *card = self.searchData[i];
        if ([card.cardId isEqualToString:updateCard.cardId]) { //更新
            [self.searchData replaceObjectAtIndex:i withObject:updateCard];
            [self.tableView reloadData];
            
            return;
        }
    }
    
    //新建的 刷新列表
    [self.tableView.mj_header beginRefreshing];
    
}


- (void)receiveDelOneCardSuccess:(NSNotification *)notification{
    CardItem *delCard = (CardItem *)notification.object;
    
    [self delCard:delCard];
}

- (void)delCard:(CardItem *)delCard{
    
    for (int i = 0; i < self.searchData.count; i ++ ) {
        CardItem *oldCard = self.searchData[i];
        if([oldCard.cardId isEqualToString:delCard.cardId]){
            [self.searchData removeObjectAtIndex:i];
            
            [self.tableView reloadData];
            break;
        }
        
    }
    
    for (int i = 0; i < self.tableData.count; i ++ ) {
        CardItem *oldCard = self.tableData[i];
        if([oldCard.cardId isEqualToString:delCard.cardId]){
            [self.tableData removeObjectAtIndex:i];
            
            [self.tableView reloadData];
            break;
            
        }
        
    }
    
}


#pragma mark - 懒加载
- (UIView *)searchBgView
{
    if (!_searchBgView) {
        _searchBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, 44)];
        _searchBgView.backgroundColor = [UIColor whiteColor];
        
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(7, 0, SCREENW-14, 44)];
        [_searchBar setBackgroundImage:[UIImage imageFromColor:[UIColor whiteColor] andSize:_searchBar.size]];
        //设置背景色
        [_searchBar setBackgroundColor:[UIColor whiteColor]];
        [_searchBar setSearchFieldBackgroundImage:[UIImage imageNamed:@"card_search_bg"] forState:UIControlStateNormal];
        [_searchBar setSearchTextPositionAdjustment:UIOffsetMake(10, 0)];
        UITextField *tf = [_searchBar valueForKey:@"_searchField"];
        tf.font = [UIFont systemFontOfSize:14];
        NSString *str = @"搜索姓名、公司、职务等";
        tf.attributedPlaceholder = [[NSAttributedString alloc]initWithString:str attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13],NSForegroundColorAttributeName:H999999}];
        tf.font = [UIFont systemFontOfSize:14];
        
        _searchBar.showsCancelButton = NO;
        _searchBar.delegate = self;
        
        [_searchBgView addSubview:_searchBar];
        
        
        _cancleBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREENW - 61, 0, 60, _searchBgView.height)];
        _cancleBtn.backgroundColor = [UIColor clearColor];
        _cancleBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [_cancleBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_cancleBtn setTitleColor:HTColorFromRGB(0x555555) forState:UIControlStateNormal];
        [_searchBgView addSubview:_cancleBtn];
        self.cancleBtn.hidden = YES;
        
        [_cancleBtn addTarget:self action:@selector(cancleBtnTouched) forControlEvents:UIControlEventTouchUpInside];

    }
    return _searchBgView;
}


- (NSMutableArray *)searchData{
    if (!_searchData) {
        _searchData = [NSMutableArray array];
    }
    return _searchData;
}
- (UITapGestureRecognizer *)tapCancelSearch{
    if (!_tapCancelSearch) {
        _tapCancelSearch = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tabelViewTapGesture)];
    }
    return _tapCancelSearch;
}



-(UIStatusBarStyle)preferredStatusBarStyle{
    
    return UIStatusBarStyleDefault;
}


@end
