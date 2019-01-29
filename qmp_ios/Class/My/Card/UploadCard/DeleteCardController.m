//
//  DeleteCardController.m
//  qmp_ios
//
//  Created by QMP on 2018/4/10.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "DeleteCardController.h"
#import "LeadCardCell.h"

#define CardCellIdenti @"LeadCardCellID"

@interface DeleteCardController ()<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate,UISearchBarDelegate>
{
    BOOL _isSearching;
    UIView *_bottomView;
    UIButton *_deleteBtn;
    UIButton *_allSelectBtn;

    BOOL _isAllSelect;
}


@property (strong, nonatomic) NSMutableArray *tableData;

@property (strong, nonatomic) ManagerHud *hudTool;
@property (strong, nonatomic) GetSizeWithText *sizeTool;
@property (nonatomic,strong) UIView *searchBgView;
@property (nonatomic,strong) UISearchBar *searchBar;
@property (nonatomic,strong) UIButton *cancleBtn;

@property (strong, nonatomic) NSMutableArray *searchData;
@property (nonatomic,strong) UITapGestureRecognizer *tapCancelSearch;
@property (nonatomic,strong)UIProgressView *progressView;

@end

@implementation DeleteCardController

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.tableView.backgroundColor = [UIColor whiteColor];
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = @"批量删除";
   
    [self initTableView];
    [self initBottomView];
    [self buildRightBarButtonItem];
    
    [self showHUD];
    [self requestData];
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
    
    [self.tableView removeGestureRecognizer:self.tapCancelSearch];
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _isSearching ? (self.searchData.count ? self.searchData.count:1) : (self.tableData.count ? self.tableData.count:1);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (_isSearching && _searchData.count == 0) {
        
        return SCREENH - kScreenTopHeight;
    }
    
    if (self.tableData.count == 0) {
        return SCREENH - kScreenTopHeight;
    }
    return 50.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (_isSearching) {
        if (self.searchData.count > 0) {
            LeadCardCell *cardCell = [tableView dequeueReusableCellWithIdentifier:CardCellIdenti forIndexPath:indexPath];
            if (self.type == 0) {
                cardCell.cardItem = self.searchData[indexPath.row];
            }else{
                [cardCell refreshContactInfo:self.searchData[indexPath.row]];
            }
            cardCell.selectBtn.tag = 1000 + indexPath.row;
            [cardCell.selectBtn addTarget:self action:@selector(cardCellSelectBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            cardCell.selectionStyle = UITableViewCellSelectionStyleNone;

            return cardCell;
            
        }
        
        
    }else{
        if (self.tableData.count > 0) {
            LeadCardCell *cardCell = [tableView dequeueReusableCellWithIdentifier:CardCellIdenti forIndexPath:indexPath];
            if (self.type == 0) {
                cardCell.cardItem = self.tableData[indexPath.row];
            }else{
                [cardCell refreshContactInfo:self.tableData[indexPath.row]];
            }
            cardCell.selectBtn.tag = 1000 + indexPath.row;
            [cardCell.selectBtn addTarget:self action:@selector(cardCellSelectBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            cardCell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cardCell;
            
        }
        
    }
    
    return [self nodataCellWithInfo:REQUEST_DATA_NULL tableView:tableView];
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
    [self refreshDeleteBtn];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if([self noDataIsAllowSelectedTbVw:tableView withIndexPaht:indexPath]){return;}
    
    if (_isSearching) {
        CardItem *cardItem = self.searchData[indexPath.row];
        cardItem.selected = !cardItem.selected;
        
    }else{
        CardItem *cardItem = self.tableData[indexPath.row];
        cardItem.selected = !cardItem.selected;
    }
    
    //        [self.tableView reloadData];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
    [self refreshDeleteBtn];
}

- (void)refreshDeleteBtn{
    NSInteger delNum = 0;
    if (_isSearching) {
        for (CardItem *card in self.searchData) {
            if (card.selected) {
                delNum++;
            }
        }
        
    }else{
        for (CardItem *card in self.tableData) {
            if (card.selected) {
                delNum++;
            }
        }
    }
    NSMutableAttributedString *attText;
    if (delNum) {
        
        attText = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"删除(%ld)",delNum]];
        [attText addAttributes:@{NSForegroundColorAttributeName:BLUE_TITLE_COLOR} range:NSMakeRange(2, attText.length - 2)];
    }else{
        attText = [[NSMutableAttributedString alloc]initWithString:@"删除"];
    }
    [_deleteBtn setAttributedTitle:attText forState:UIControlStateNormal];
    _isAllSelect = NO;
    if (_isSearching && (self.searchData.count == delNum)) {
        _isAllSelect = YES;
        
    }else if (!_isSearching && (self.tableData.count == delNum)) {
        _isAllSelect = YES;
    }
    [_allSelectBtn setTitle:_isAllSelect?@"取消全选":@"全选" forState:UIControlStateNormal];
}


#pragma mark --UISearchBarDelegate---
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    
    _isSearching = YES;
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = self.searchBar.frame;
        frame.size.width = SCREENW - 58;
        self.searchBar.frame = frame;
        self.cancleBtn.hidden = NO;
        
    } completion:nil];
    
    if (!_searchBar.text || _searchBar.text.length == 0) {
        self.tableView.height = self.view.height;
        
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
    [self refreshDeleteBtn];
    
    [PublicTool showHudWithView:KEYWindow];
    [self requestData];
    
    [self.searchBar resignFirstResponder];
    
}

- (void)searchResignFirseResponder{
    _isSearching = NO;
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
    self.tableView.height = self.view.height - 44;
    self.tableView.mj_footer.state = MJRefreshStateIdle;
    [self.tableView reloadData];
    
    [self refreshDeleteBtn];
    
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
    
}



#pragma mark - 请求名片列表
- (BOOL)requestData{
    if (![super requestData]) {
        return NO;
    }
    
    if (self.type == 0) {
        [self requestMyCard];

    }else{
        [self requestContacts];
    }
    return YES;
}

- (void)requestMyCard{
    
    NSInteger page = 1;
    
    NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:[WechatUserInfo  shared].unionid,@"unionid",@"qmp_ios",@"ptype",VERSION,@"version",@(page),@"page",@(10000),@"page_num",self.searchBar.text,@"keyword", nil];
    
    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"Card/cardList" HTTPBody:param completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        [self hideHUD];
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        if (resultData && [resultData[@"list"] isKindOfClass:[NSArray class]]) {
            
            NSMutableArray *retMArr = [[NSMutableArray alloc] initWithCapacity:0];
            
            for (NSDictionary *cardsDict in resultData[@"list"]) {
                CardItem *item = [[CardItem alloc] init];
                item.cardId = cardsDict[@"card_id"];
                [item setValuesForKeysWithDictionary:cardsDict];
                [retMArr addObject:item];
            }
            [self dealData:retMArr];
        }
        
    }];
}

- (void)requestContacts{
    
    NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:[WechatUserInfo  shared].unionid,@"unionid",@"qmp_ios",@"ptype",VERSION,@"version",@(1),@"page",@(10000),@"page_num",self.searchBar.text,@"keyword", nil];
    
    [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:@"Contact/getContactList" HTTPBody:param completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        [self hideHUD];
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        [PublicTool dismissHud:KEYWindow];

        if (resultData && [resultData[@"msg"] isKindOfClass:[NSArray class]]) {
            NSMutableArray *retMArr = [[NSMutableArray alloc] initWithCapacity:0];
            
            for (NSDictionary *dic in resultData[@"msg"]) {
                CardItem *cardItem = [[CardItem alloc] init];
                [cardItem setValuesForKeysWithDictionary:dic];
                [retMArr addObject:cardItem];
            }
            [self dealData:retMArr];
        }
        
    }];

}

- (void)dealData:(NSArray*)retMArr{
    
    [self.tableView.mj_header endRefreshing];
    [self.tableView.mj_footer endRefreshing];
    
    if (_isSearching) {
        self.searchData = [NSMutableArray arrayWithArray:retMArr];

        [self refreshFooter:@[]];
        [self.tableView reloadData];
        
        return;
    }
    
    self.tableData = [NSMutableArray arrayWithArray:retMArr];
    [self refreshFooter:@[]];
    [self.tableView reloadData];
    
}


#pragma mark - public
- (void)buildRightBarButtonItem{
    
    
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 80, 44)];
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    [btn setTitleColor:H5COLOR forState:UIControlStateNormal];
    [btn setTitle:@"全选" forState:UIControlStateNormal];
    
    [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [btn addTarget:self action:@selector(pressRightButtonItem:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc]initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = item1;
    _allSelectBtn = btn;
}


- (void)pressRightButtonItem:(id)sender{
    
    _isAllSelect = !_isAllSelect;
    [_allSelectBtn setTitle:_isAllSelect?@"取消全选":@"全选" forState:UIControlStateNormal];
    //全选
    if (_isSearching) {
        for (CardItem *card in self.searchData) {
            card.selected = YES;
        }
    }else{
        for (CardItem *card in self.tableData) {
            card.selected = _isAllSelect;
        }
    }
    [self.tableView reloadData];
    
    [self refreshDeleteBtn];
}

#pragma mark ----批量操作
- (void)initBottomView{
    
    _bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, self.tableView.bottom, SCREENW, kScreenBottomHeight)];
    _bottomView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_bottomView];
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 0.5)];
    line.backgroundColor = LINE_COLOR;
    [_bottomView addSubview:line];
    
    
    UIButton *delBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, SCREENW, kScreenBottomHeight)];
    NSMutableAttributedString *attText = [[NSMutableAttributedString alloc]initWithString:@"删除"];
    [attText addAttributes:@{NSForegroundColorAttributeName:NV_TITLE_COLOR} range:NSMakeRange(0, 2)];
    [delBtn setAttributedTitle:attText forState:UIControlStateNormal];

    delBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [delBtn layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleLeft imageTitleSpace:7];
    [delBtn addTarget:self  action:@selector(deleteBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:delBtn];
    
    _deleteBtn = delBtn;
    
}


//删除名片
- (void)deleteBtnClick{
    if (self.type == 0) {
        [self deleteCards];
        
    }else{  //删除委托联系
        [self deleteContacts];
    }
    
}

- (void)deleteCards{
    
    NSInteger totalDel = 0;
    NSArray *arr = _isSearching ? self.searchData : self.tableData;
    NSMutableArray *deleteArr = [NSMutableArray array];
    NSMutableArray *idArr = [NSMutableArray array];

    for (CardItem *card in arr) {
        
        if (card.selected) {
            totalDel ++;
            [deleteArr addObject:card];
            [idArr addObject:card.cardId];
        }
    }
    
    if (totalDel == 0) {
        [PublicTool showMsg:@"请选择要删除的人"];
        return;
    }
    
    [PublicTool alertActionWithTitle:@"提示" message:[NSString stringWithFormat:@"本次操作选中%ld条人脉\n是否继续删除",totalDel] cancleAction:^{
        
    } sureAction:^{
        
        [PublicTool showHudWithView:KEYWindow];
        
        __block NSInteger deleteIndex = 0;
        [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"card/deleteCard" HTTPBody:@{@"card_id":[idArr componentsJoinedByString:@"|"]} completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
            
            [PublicTool dismissHud:self.view];
            if ([resultData[@"status"] integerValue] == 0) {
                [self delCard:deleteArr];
               
                [PublicTool dismissHud:KEYWindow];
                if (self.deleteCardHandle) {
                    self.deleteCardHandle();
                }
                [_deleteBtn setAttributedTitle:[[NSAttributedString alloc]initWithString:@"删除"] forState:UIControlStateNormal];
                _isAllSelect = NO;
                [_allSelectBtn setTitle:_isAllSelect?@"取消全选":@"全选" forState:UIControlStateNormal];
            }else{
                [PublicTool showMsg:@"删除失败"];
            }
        }];
    }];
}


- (void)deleteContacts{
    
    NSInteger totalDel = 0;
    NSMutableArray *deleteArr = [NSMutableArray array];
    NSArray *data = _isSearching ? self.searchData : self.tableData;
    
    for (CardItem *card in data) {
        if (card.selected) {
            totalDel ++;
            [deleteArr addObject:card.cardId];
        }
    }
    
    if (totalDel == 0) {
        [PublicTool showMsg:@"请选择要删除的委托联系信息"];
        return;
    }
    
    [PublicTool alertActionWithTitle:@"提示" message:[NSString stringWithFormat:@"本次操作选中%ld条委托联系信息\n是否继续删除",totalDel] cancleAction:^{
        
    } sureAction:^{
        
        [PublicTool showHudWithView:KEYWindow];
        NSString *ids = [deleteArr componentsJoinedByString:@"|"];
        [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:@"Contact/contactsDelete" HTTPBody:@{@"ids":ids} completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
            
            [PublicTool dismissHud:KEYWindow];
            
            if (resultData && [resultData[@"msg"] isEqualToString:@"success"]) {
                [PublicTool showMsg:@"删除成功"];
                if (self.deleteCardHandle) {
                    self.deleteCardHandle();
                }
                [self.tableView.mj_header beginRefreshing];
                [_deleteBtn setAttributedTitle:[[NSAttributedString alloc]initWithString:@"删除"] forState:UIControlStateNormal];
                _isAllSelect = NO;
                [_allSelectBtn setTitle:_isAllSelect?@"取消全选":@"全选" forState:UIControlStateNormal];
            }
        }];
    }];
        
   
}

- (void)delCard:(NSArray *)delCards{
    [self.searchData removeObjectsInArray:delCards];
    [self.tableData removeObjectsInArray:delCards];
    [self.tableView reloadData];
//
//    for (int i = 0; i < self.searchData.count; i ++ ) {
//        CardItem *oldCard = self.searchData[i];
//        if([oldCard.cardId isEqualToString:delCard.cardId]){
//            [self.searchData removeObjectAtIndex:i];
//
//            [self.tableView reloadData];
//            break;
//        }
//
//    }
//
//    for (int i = 0; i < self.tableData.count; i ++ ) {
//        CardItem *oldCard = self.tableData[i];
//        if([oldCard.cardId isEqualToString:delCard.cardId]){
//            [self.tableData removeObjectAtIndex:i];
//
//            [self.tableView reloadData];
//            break;
//
//        }
//
//    }
    
}

- (void)initTableView{
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH - kScreenTopHeight-kScreenBottomHeight) style:UITableViewStylePlain];
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.mj_header = self.mjHeader;
    self.tableView.mj_footer = self.mjFooter;
    [self.tableView registerClass:[LeadCardCell class] forCellReuseIdentifier:CardCellIdenti];
    self.tableView.tableHeaderView = self.searchBgView;
    
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    
}


#pragma mark - 懒加载
- (UIView *)searchBgView
{
    if (!_searchBgView) {
        _searchBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, 44)];
        _searchBgView.backgroundColor = TABLEVIEW_COLOR;
        
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(7, 0, SCREENW-14, 44)];
        [_searchBar setBackgroundImage:[UIImage imageFromColor:TABLEVIEW_COLOR andSize:_searchBar.bounds.size]];
        //设置背景色
        [_searchBar setBackgroundColor:TABLEVIEW_COLOR];
        [_searchBar setSearchFieldBackgroundImage:[UIImage imageNamed:@"search_borderBg"] forState:UIControlStateNormal];
        [_searchBar setSearchTextPositionAdjustment:UIOffsetMake(10, 0)];
        UITextField *tf = [_searchBar valueForKey:@"_searchField"];
        NSString *str = @"搜索姓名、公司、职务等";
        tf.attributedPlaceholder = [[NSAttributedString alloc]initWithString:str attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]}];
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
        
        //底部线条
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, _searchBgView.height - 0.5, SCREENW, 0.5)];
        line.backgroundColor = HTColorFromRGB(0xd2d2d2);
        [_searchBgView addSubview:line];
        
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


- (GetSizeWithText *)sizeTool{
    
    if (!_sizeTool) {
        _sizeTool = [[GetSizeWithText alloc] init];
    }
    return _sizeTool;
}




-(UIStatusBarStyle)preferredStatusBarStyle{
    
    return UIStatusBarStyleDefault;
}



@end
