//
//  TagsManagerViewController.m
//  qmp_ios
//
//  Created by molly on 2017/5/19.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "TagsManagerViewController.h"
#import "AlbumsListCell.h"
#import "OneTagViewController.h"
#import "ManagerAlertView.h"
#import "TagsItem.h"

@interface TagsManagerViewController ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,ManagerAlertDelegate,OneTagViewControllerDelegate>{

    BOOL _isSearch;
    CGFloat _oldY;
    BOOL isShow;
}
//@property (strong, nonatomic) UIButton *searchBtn;
@property (strong, nonatomic) UIView *tableHeaderView;
@property (strong, nonatomic) UIButton *cancleSearchBtn;
@property (strong, nonatomic) UISearchBar *searchBar;

@property (strong, nonatomic) NSMutableArray *searchArr;
@property (strong, nonatomic) NSMutableArray *tagsMArr;
@property (strong, nonatomic) NSMutableArray *nameArr;

@property (strong, nonatomic) NSIndexPath *changeNameIndexPath;


@end

@implementation TagsManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self keyboardManager];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"专辑管理";
    [self buildRightBarButtonItem];
    
    [self initTableView];
    [self changeTableHeaderView];
    
    [self showHUD];
    [self requsetGetTagList];

}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tableView.backgroundColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return  1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    NSInteger count = 0;
    if (_isSearch) {
        if ([self.searchBar.text isEqualToString:@""]) {
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
        
        count = self.tagsMArr.count > 0 ? self.tagsMArr.count : 1;
    }
    return count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CGFloat height = 50.f;
    if (_isSearch) {
        if ([self.searchBar.text isEqualToString:@""]) {
            height = 0.f;
        }else{
            if (self.searchArr.count > 0) {
                height = 50.f;
            }
            else{
                height = SCREENH - kScreenTopHeight;
            }
        }
    }else{
        
        height = self.tagsMArr.count > 0 ? 50.f : SCREENH - kScreenTopHeight;
    }
    
    return height;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ((self.tagsMArr.count == 0 && !_isSearch ) || (self.searchArr.count == 0 && _isSearch)) {
        
        NSString *title = _isSearch ? REQUEST_SEARCH_NULL : @"暂无专辑，点击添加";
        return [self nodataCellWithInfo:title tableView:tableView];
    }
    else{
        NSString *groupCellIdentifier = @"AlbumsTableViewCell";
        AlbumsListCell *cell = [tableView dequeueReusableCellWithIdentifier:groupCellIdentifier];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"AlbumsListCell" owner:nil options:nil] lastObject];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        TagsItem *item  = _isSearch ? self.searchArr[indexPath.row] : self.tagsMArr[indexPath.row];
        
        cell.nameLbl.text = item.tag;
        cell.countLabel.text = [NSString stringWithFormat:@"(%@)",item.product_num];
        cell.topStaL.hidden = YES;
        return cell;
        
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if([self noDataIsAllowSelectedTbVw:tableView withIndexPaht:indexPath]){return;}
    //跳转
    if (!_isSearch && self.tagsMArr.count == 0 && indexPath.section == 0) {
        [self pressRightButtonItem:nil];
//        [self enterSearchVC];
    }else if ((self.tagsMArr.count >0 && !_isSearch ) || (self.searchArr.count > 0 && _isSearch)){
        //跳转,请求分组列表
        
        TagsItem *item = _isSearch ? self.searchArr[indexPath.row]: self.tagsMArr[indexPath.row];
        
        OneTagViewController *listVC = [[OneTagViewController alloc] initWithTagItem:item];
        listVC.delegate = self;
        [self.navigationController pushViewController:listVC animated:YES];
        
    }

}
-(UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UIContextualAction *isPresiceAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"重命名" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        //重命名
        self.changeNameIndexPath = indexPath;
        
        TagsItem *tagItem = self.tagsMArr[indexPath.row];
        ManagerAlertView *alertView = [ManagerAlertView initFrame];
        alertView.tagItem = tagItem;
        alertView.nameArr = [NSMutableArray arrayWithArray:self.nameArr];
        alertView.delegata = self;
        alertView.currentVC = self;
        [alertView initViewWithFolder:alertView.tagItem.tag aTitle:@"重命名"];
        [KEYWindow addSubview:alertView];
    }];

    UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"删除" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        //删除
        
        if ([TestNetWorkReached networkIsReached:self]) {
            
            TagsItem *tagItem = self.tagsMArr[indexPath.row];
            
            [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:@"h/workTagDelete" HTTPBody:@{@"tag_id":tagItem.tag_id} completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
                if (resultData) {
                    for (int i = 0 ; i<self.tagsMArr.count ;i ++) {
                        TagsItem *oldTag = self.tagsMArr[i];
                        if ([oldTag.tag_id isEqualToString:tagItem.tag_id]) {
                            [self.tagsMArr removeObjectAtIndex:i];
                            [self.nameArr removeObjectAtIndex:i];
                            [ShowInfo showInfoOnView:self.view withInfo:@"删除成功"];
                            [self.tableView reloadData];
                            break;
                        }
                    }
                }
            }];
        }
    }];
    deleteAction.backgroundColor = RED_TEXTCOLOR;
    UISwipeActionsConfiguration *action = [UISwipeActionsConfiguration configurationWithActions:@[deleteAction,isPresiceAction]];
    action.performsFirstActionWithFullSwipe = NO;
    return action;
    
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (iOS11_OR_HIGHER) {
        return @[];
        
    }
    
    UITableViewRowAction *changeNameAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"重命名" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        //重命名
        self.changeNameIndexPath = indexPath;
        
        TagsItem *tagItem = self.tagsMArr[indexPath.row];
        ManagerAlertView *alertView = [ManagerAlertView initFrame];
        alertView.tagItem = tagItem;
        alertView.nameArr = [NSMutableArray arrayWithArray:self.nameArr];
        alertView.delegata = self;
        alertView.currentVC = self;
        [alertView initViewWithFolder:alertView.tagItem.tag aTitle:@"重命名"];
        
        [KEYWindow addSubview:alertView];
    }];
    
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        //删除
        
        if ([TestNetWorkReached networkIsReached:self]) {
            
            TagsItem *tagItem = self.tagsMArr[indexPath.row];
            [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:@"h/workTagDelete" HTTPBody:@{@"tag_id":tagItem.tag_id} completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
                if (resultData) {
                    for (int i = 0 ; i<self.tagsMArr.count ;i ++) {
                        TagsItem *oldTag = self.tagsMArr[i];
                        if ([oldTag.tag_id isEqualToString:tagItem.tag_id]) {
                            [self.tagsMArr removeObjectAtIndex:i];
                            [self.nameArr removeObjectAtIndex:i];
                            [ShowInfo showInfoOnView:self.view withInfo:@"删除成功"];
                            [self.tableView reloadData];
                            break;
                        }
                    }
                }
            }];
        }
    }];
    
    return @[deleteAction,changeNameAction];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return (!_isSearch &&self.tagsMArr.count > 0);

}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 0.1f;

}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, 10.f)];
    view.backgroundColor = tableView.backgroundColor;
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return 0.1f;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc]init];
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
    _oldY = scrollView.contentOffset.y;
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if (_isSearch && [self.searchBar.text isEqualToString:@""]){
        [self cancleSearch];
    }
    else{
        
        if ([self.searchBar isFirstResponder]) {
            [self.searchBar resignFirstResponder];
        }
        /** 搜索框收起/显示的效果       */
        CGFloat nowY = scrollView.contentOffset.y;
        
        if (nowY > 0) {
            
            if (nowY <= 25) {
                isShow = YES;
                [self showTableViewHeader];
            }
            else{
                isShow = NO;
                [self hiddenTableViewHeader];
            }
        }else{
            
            isShow = NO;
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    if (isShow ) {
        [self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
        
        NSLog(@"=========scrollToTop ");
    }
}
- (void)showTableViewHeader{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.8 animations:^{
            [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
        } completion:^(BOOL finished) {
        }];
    });
}

- (void)hiddenTableViewHeader{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.8 animations:^{
            [self.tableView setContentInset:UIEdgeInsetsMake(-self.searchBar.frame.size.height + 10, 0, 0, 0)];
        } completion:^(BOOL finished) {
        }];
    });
    
}

#pragma mark - UISearchBar
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    
    if (!_isSearch) {
        
        _isSearch = YES;
        CGRect frame = searchBar.frame;
        frame.size.width = SCREENW - 58;
        searchBar.frame = frame;
        
        [self.tableHeaderView addSubview:self.cancleSearchBtn];
        
        self.searchArr = [[NSMutableArray alloc] initWithCapacity:0];
        [self.tableView reloadData];
        
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    if ([searchBar.text isEqualToString:@""]) {
        self.searchArr = [[NSMutableArray alloc] initWithCapacity:0];
        [self.tableView reloadData];
    }
    else{
        _isSearch = YES;
        [self requsetGetTagList];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self.view endEditing:YES];
    
    if (![searchBar.text isEqualToString:@""]) {

        _isSearch = YES;
        [self requsetGetTagList];
    }
}
#pragma mark - ManagerAlertDelegate

- (void)createFolder:(TagsItem *)tag inId:(NSString *)userfolderid{
    
    [self.tagsMArr insertObject:tag atIndex:0];
    [self.nameArr insertObject:tag.tag atIndex:0];
    [self.tableView reloadData];
}

- (void)changeName:(TagsItem *)tag{
    
    [self.tagsMArr replaceObjectAtIndex:self.changeNameIndexPath.row withObject:tag];
    [self.nameArr replaceObjectAtIndex:self.changeNameIndexPath.row withObject:tag.tag];
    
    [self.tableView reloadData];

}

- (void)pressCancleChangeName{
    
    self.tableView.editing = NO;
}
#pragma mark - OneTagViewControllerDelegate
- (void)delSuccess:(TagsItem *)tagItem{
    [self.tableView.mj_header beginRefreshing];

//    [self changCountIsAdd:NO withTag:tagItem];
}

- (void)addSuccess:(TagsItem *)tagItem{
    [self.tableView.mj_header beginRefreshing];
//    [self changCountIsAdd:YES withTag:tagItem];

}

- (void)changCountIsAdd:(BOOL)isAdd withTag:(TagsItem *)tagItem{

    for (int i = 0; i < self.tagsMArr.count ; i ++) {
        TagsItem *oldTag = self.tagsMArr[i];
        if ([oldTag.tag_id isEqualToString:tagItem.tag_id]) {
            
            NSInteger count = [oldTag.product_num integerValue];
            if (isAdd) {
                count ++;
            }
            else{
                count --;
            }
            oldTag.product_num = [NSString stringWithFormat:@"%ld",(long)count];
            [self.tagsMArr replaceObjectAtIndex:i withObject:oldTag];
            
            [self.tableView reloadData];
            break;
        }
    }

}
#pragma mark - 请求标签列表
- (void)requsetGetTagList{
    if ([TestNetWorkReached networkIsReached:self]) {

        if ( [self.searchBar.text isEqualToString:@""]&&self.searchArr.count > 0) {
            [self.searchArr removeAllObjects];
        }

        NSMutableDictionary *mDic = [[NSMutableDictionary alloc] initWithCapacity:0];
        if ([self.tableView.mj_header isRefreshing]) {
            [mDic setValue:@"1" forKey:@"debug"];
        }
        if (_isSearch) {
            [mDic setValue:self.searchBar.text forKey:@"w"];
        }
        [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:@"h/workTagList" HTTPBody:mDic completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
            [self hideHUD];
            [self.tableView.mj_header endRefreshing];
            [self.tableView.mj_footer endRefreshing];
            
            NSMutableArray *retMArr = [[NSMutableArray alloc] initWithCapacity:0];
            NSMutableArray *nameMArr = [[NSMutableArray alloc] initWithCapacity:0];
            
            if (resultData && [resultData isKindOfClass:[NSArray class]]) {
                
                for (NSDictionary *dataDict in resultData) {
                    TagsItem *items = [[TagsItem alloc] init];
                    [items setValuesForKeysWithDictionary:dataDict];
                    [retMArr addObject:items];
                    
                    [nameMArr addObject:items.tag];
                }
                
                if (_isSearch) {
                    self.searchArr = retMArr;
                }
                else{
                    
                    //不是搜索状态
                    self.tagsMArr = retMArr;
                    self.nameArr = nameMArr;
                    
                }
            }
            
            [self.tableView reloadData];
            
        }];

    }else{
        self.tagsMArr = nil;
        self.nameArr = nil;
        [self.tableView reloadData];
        [self.tableView.mj_header endRefreshing];
        [self hideHUD];
    }
}

#pragma mark - public
- (void)buildRightBarButtonItem{
    
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addBtn.frame = RIGHTBARBTNFRAME;
    [addBtn addTarget:self action:@selector(pressRightButtonItem:) forControlEvents:UIControlEventTouchUpInside];
    [addBtn setImage:[UIImage imageNamed:@"add-manager"] forState:UIControlStateNormal];
    UIBarButtonItem * barItem = [[UIBarButtonItem alloc] initWithCustomView:addBtn];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = RIGHTNVSPACE;
    
    if (iOS11_OR_HIGHER) {
        
        addBtn.width = 30;
        addBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:addBtn];
        
        self.navigationItem.rightBarButtonItems = @[buttonItem];
        
    }else{
        self.navigationItem.rightBarButtonItems = @[ negativeSpacer,barItem];
    }
}

- (void)pressRightButtonItem:(id)sender{
    
    if (_isSearch) {
        [self cancleSearch];
    }
    
    if ( [TestNetWorkReached networkIsReachedAlertOnView:self.view]) {
        
        ManagerAlertView *alertView = [ManagerAlertView initFrame];
        alertView.nameArr = [NSMutableArray arrayWithArray:self.nameArr];
        [alertView initViewWithTitle:@"新建专辑"];
        alertView.delegata = self;
        alertView.currentVC = self;
        
        [KEYWindow addSubview:alertView];
    }
    
}

- (void)keyboardManager{
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    
    [self.view addGestureRecognizer:tapGestureRecognizer];
    self.view.userInteractionEnabled = YES;
}

- (void)keyboardHide:(UITapGestureRecognizer *)tap{
    
    if (tap.view != self.searchBar) {
        if (_isSearch && [self.searchBar.text isEqualToString:@""]) {
            [self cancleSearch];
        }
        else{
            [self.searchBar resignFirstResponder];
        }
    }
}

- (void)initTableView{
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH - kScreenTopHeight) style:UITableViewStyleGrouped];
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.backgroundColor = TABLEVIEW_COLOR;
    
    self.tableView.mj_header = self.mjHeader;
}

- (void)pullDown{
    
    [self requsetGetTagList];
}

- (void)changeTableHeaderView{
    
    self.tableView.tableHeaderView = self.tableHeaderView;
}
/**
 点击取消搜索
 
 @param sender
 */
- (void)pressCancleSearchBtn:(UIButton *)sender{
    [self cancleSearch];
}

- (void)cancleSearch{
    
    if (self.tableView.mj_footer.state == MJRefreshStateNoMoreData) {
        [self.tableView.mj_footer resetNoMoreData];
    }
    
    _isSearch = NO;
    [self.searchArr removeAllObjects];
    
    [self.searchBar resignFirstResponder];
    CGRect frame = self.searchBar.frame;
    frame.size.width = SCREENW-14;
    self.searchBar.frame = frame;
    self.searchBar.text = @"";
    
    [self.cancleSearchBtn removeFromSuperview];
    
    [self.tableView reloadData];
    
}

- (void)buildTableHeaderViewWithView{
    
    UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, 50.f)];
    tableHeaderView.backgroundColor = RGBa(240,239,245,1);
    self.tableView.tableHeaderView = tableHeaderView;
    
    CGFloat margin = 16.f;
    UIView *whiteV = [[UIView alloc] initWithFrame:CGRectMake(margin, 10, SCREENW - margin * 2, 30.f)];
    whiteV.layer.masksToBounds = YES;
    whiteV.layer.cornerRadius = 5.f;
    [whiteV setBackgroundColor:[UIColor whiteColor]];
    [tableHeaderView addSubview:whiteV];
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 20)];
    titleView.center = whiteV.center;
    [tableHeaderView addSubview:titleView];
    
    UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20.f, 20.f)];
    [imgV setImage:[UIImage imageNamed:@"search-bar"]];
    [titleView addSubview:imgV];
    UILabel *titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(imgV.frame.size.width, 0, titleView.frame.size.width - imgV.frame.size.width, 20.f)];
    titleLbl.textColor = [UIColor lightGrayColor];
    titleLbl.text = @"搜索";
    titleLbl.font = [UIFont systemFontOfSize:14.f];
    [titleView addSubview:titleLbl];
}

- (void)receiveQuitLoginNotification:(NSNotification *)notification{
    
    NSString *receiveStr = (NSString *)[notification object];
    if ([receiveStr isEqualToString:@"0"]) {
        
        [self changeTableHeaderView];
        
        self.tagsMArr = [[NSMutableArray alloc] initWithCapacity:0];
        self.nameArr = [[NSMutableArray alloc] initWithCapacity:0];
        [self.tableView reloadData];
    }
}

#pragma mark - 懒加载
- (NSMutableArray *)tagsMArr{
    
    if (!_tagsMArr) {
        _tagsMArr = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _tagsMArr;
}
- (NSMutableArray *)nameArr{
    
    if (!_nameArr) {
        _nameArr = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _nameArr;
}


- (UIView *)tableHeaderView{
    
    if (!_tableHeaderView) {
        CGFloat height = 44;
        _tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, height)];
        _tableHeaderView.backgroundColor = TABLEVIEW_COLOR;
        
        [_tableHeaderView addSubview:self.searchBar];
        
        CGFloat width = 60.f;
        _cancleSearchBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, height)];
        _cancleSearchBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_cancleSearchBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_cancleSearchBtn setTitleColor:HTColorFromRGB(0x555555) forState:UIControlStateNormal];
        [_cancleSearchBtn addTarget:self action:@selector(pressCancleSearchBtn:) forControlEvents:UIControlEventTouchUpInside];
        _cancleSearchBtn.frame = CGRectMake(SCREENW - width - 1, (_tableHeaderView.frame.size.height - height)/2, width, height);
        //底部线条
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, _tableHeaderView.height - 0.5, SCREENW, 0.5)];
        line.backgroundColor = LIST_LINE_COLOR;
        [_tableHeaderView addSubview:line];
    }
    return _tableHeaderView;
}
- (UISearchBar *)searchBar{
    
    if (!_searchBar) {
       _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(7, 0, SCREENW-14, 44.f)];
        
        [_searchBar setBackgroundImage:[UIImage imageFromColor:TABLEVIEW_COLOR andSize:_searchBar.bounds.size]];
        //设置背景色
        [_searchBar setBackgroundColor:TABLEVIEW_COLOR];
        [_searchBar setSearchFieldBackgroundImage:[UIImage imageNamed:@"search_borderBg"] forState:UIControlStateNormal];
        [_searchBar setSearchTextPositionAdjustment:UIOffsetMake(10, 0)];
        UITextField *tf = [_searchBar valueForKey:@"_searchField"];
        NSString *str = @"搜索专辑关键字";
        tf.attributedPlaceholder = [[NSAttributedString alloc]initWithString:str attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]}];
        tf.font = [UIFont systemFontOfSize:14];
        _searchBar.delegate = self;
    }
    return _searchBar;
}

- (NSMutableArray *)searchArr{
    
    if (!_searchArr) {
        _searchArr = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _searchArr;
}




@end
