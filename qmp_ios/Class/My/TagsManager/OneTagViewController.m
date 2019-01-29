//
//  OneTagViewController.m
//  qmp_ios
//
//  Created by molly on 2017/5/19.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "OneTagViewController.h"
#import "WorkFlowToAlbumController.h"
#import "SearchProductViewController.h"
#import "OneTagTableViewCell.h"
#import "LrdOutputView.h"
#import "StarProductsTableViewCell.h"
#import "StarProductsModel.h"

 
@interface OneTagViewController ()<UITableViewDataSource,UITableViewDelegate,LrdOutputViewDelegate,AddProductToGroupOnGroupDelegate>{
    
    BOOL orderByLunci;
    BOOL _isEditting;
    BOOL _allChoose;
    UIView *_bottomView;
    NSInteger count;
    WorkFlowToAlbumController *_workToAlbumVC;
}

@property (strong, nonatomic) UIView *headerView;
@property (strong, nonatomic) UILabel *headerLab;

@property (strong, nonatomic) LrdOutputView *outputView;
@property (strong,nonatomic) NSArray *moreOptionsArr;

@property (strong, nonatomic) TagsItem *tagItem;
@property(nonatomic,strong) NSMutableArray * companysModelMArr;
@property(nonatomic,strong) NSMutableArray *companyCellStrHeightMArr;//存companycell各字符串高度,比如:总高度,行业,业务
@property (nonatomic, strong) NSMutableArray *productidMArr;
@property (strong, nonatomic) UIView *tableHeadView;



@end

@implementation OneTagViewController

- (instancetype)initWithTagItem:(TagsItem *)tagItem{

    if (self = [super init]) {
        self.tagItem = tagItem;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //没有分页
    self.currentPage = 1;
    self.numPerPage = 30;
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self initBottomView];
    [self buildRightBarButtonItem];
    NSString *title = self.tagItem.tag;
    self.title = (title ? title : @"");
    
    [self initHeaderView];
    [self initTableView];
    if (![PublicTool isNull:self.tagItem.tag_id]) {
        [self showHUD];
        [self requesetProductList];
        
        self.tableView.mj_header = self.mjHeader;
        self.tableView.mj_footer = self.mjFooter;
    }

}


#pragma mark --删除移动
- (void)initBottomView{
    
    _bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.height, SCREENW, 44)];
    _bottomView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_bottomView];
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 0.5)];
    line.backgroundColor = LINE_COLOR;
    [_bottomView addSubview:line];
    
    UIButton *leadBtn = [[UIButton alloc]initWithFrame:CGRectMake(64*ratioWidth, 0, 110, 44)];
    [leadBtn setImage:[UIImage imageNamed:@"leadToAlbumIcon"] forState:UIControlStateNormal];
    [leadBtn setTitle:@"导入到专辑" forState:UIControlStateNormal];
    [leadBtn layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleLeft imageTitleSpace:7];
    [leadBtn setTitleColor:H5COLOR forState:UIControlStateNormal];
    leadBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [leadBtn addTarget:self  action:@selector(leadBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:leadBtn];
    
    
    UIButton *delBtn = [[UIButton alloc]initWithFrame:CGRectMake(SCREENW-64*ratioWidth - 70, 0, 70, 44)];
    [delBtn setTitle:@"删除" forState:UIControlStateNormal];
    [delBtn setImage:[UIImage imageNamed:@"workFlowDel"] forState:UIControlStateNormal];
    [delBtn setTitleColor:H5COLOR forState:UIControlStateNormal];
    delBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [delBtn layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleLeft imageTitleSpace:7];
    [delBtn addTarget:self  action:@selector(deleteBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:delBtn];
    
    
}
//导入到专辑事件
- (void)leadBtnClick{
    NSMutableArray *idArr = [NSMutableArray array];
    
    for (StarProductsModel *company in self.companysModelMArr) {
        if ([company.selected isEqualToString:@"1"]) {
            [idArr addObject:company.productId];
        }
    }
    
    if (idArr.count == 0) {
        [PublicTool showMsg:@"请选择要导入的项目"];
        return;
    }
    
    _workToAlbumVC = [[WorkFlowToAlbumController alloc]init];
    _workToAlbumVC.tag = self.tagItem;
    _workToAlbumVC.companyIdArr = idArr;
    __weak typeof(self) weakSelf = self;
    
    _workToAlbumVC.introductSuccess = ^{
        
        [weakSelf cancleEditting];
        //调用oneTagView的代理，刷新专辑页
        if ([weakSelf.delegate respondsToSelector:@selector(addSuccess:)]) {
            [weakSelf.delegate addSuccess:weakSelf.tagItem];
        }
    };
    
    [[PublicTool topViewController].navigationController pushViewController:_workToAlbumVC animated:YES];
}

//删除事件
- (void)deleteBtnClick{
    
    NSMutableArray *idArr = [NSMutableArray array];
    
    for (StarProductsModel *company in self.companysModelMArr) {
        if ([company.selected isEqualToString:@"1"]) {
            [idArr addObject:company.productId];
        }
    }
    
    if (idArr.count == 0) {
        [PublicTool showMsg:@"请选择要删除的项目"];
        return;
    }
    
    [PublicTool alertActionWithTitle:@"提示" message:[NSString stringWithFormat:@"确定要从该专辑中删除这%ld个项目吗",idArr.count] leftTitle:@"取消" rightTitle:@"删除" leftAction:^{
        
    } rightAction:^{
        [self requestRemove:[idArr componentsJoinedByString:@"|"]];

    }];
   
}

- (void)refreshDeleteData{
    
    //删除成功  刷新数据
    [self.companysModelMArr enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(StarProductsModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.selected isEqualToString:@"1"]) {
            [self.companysModelMArr removeObject:obj];
            [self.productidMArr removeObject:obj.productId];
            count --;
        }
    }];
    NSString *info = [NSString stringWithFormat:@"共%ld个项目",(long)(count ? count : (NSInteger)self.companysModelMArr.count)];

    _headerLab.text = info;

    [self.tableView reloadData];
}


#pragma mark - 数据源和代理方法

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    if (section == 0) {
        if (self.companysModelMArr.count == 0 || !_isEditting) {
            return 0;
        }
    }
    return 55;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        if (self.companysModelMArr.count == 0 || !_isEditting) {
            return [[UIView alloc]init];
        }
    }
    
    
    UIView *headerV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, 55.f)];
    
    UIView *grayV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 10)];
    grayV.backgroundColor = TABLEVIEW_COLOR;
    [headerV addSubview:grayV];
    
    UIView *whiteV = [[UIView alloc]initWithFrame:CGRectMake(0, 10, SCREENW, 45)];
    whiteV.backgroundColor = [UIColor whiteColor];
    [headerV addSubview:whiteV];
    
    if (section == 0) {
        if (self.companysModelMArr.count > 0) {
            
            UIButton *allChooseBtn = [[UIButton alloc] initWithFrame:CGRectMake(17, 0.f, 67, 45)];
            [allChooseBtn setImage:[UIImage imageNamed:@"select_workFlow"] forState:UIControlStateSelected];
            [allChooseBtn setImage:[UIImage imageNamed:@"noselect_workFlow"] forState:UIControlStateNormal];
            [allChooseBtn setTitle:@"全选" forState:UIControlStateNormal];
            [allChooseBtn setTitleColor:NV_TITLE_COLOR forState:UIControlStateNormal];
            [allChooseBtn layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleLeft imageTitleSpace:15];
            allChooseBtn.titleLabel.font = [UIFont systemFontOfSize:15];
            allChooseBtn.titleLabel.textColor = NV_TITLE_COLOR;
            [allChooseBtn addTarget:self action:@selector(chooseAllBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            [whiteV addSubview:allChooseBtn];
            allChooseBtn.hidden = !_isEditting;
            allChooseBtn.selected = _allChoose;
            
            CGFloat btnW = 60.f;
            
            UIButton *editBtn = [[UIButton alloc]initWithFrame:CGRectMake(SCREENW - btnW - 17.f, 7.5, btnW, 30)];
            [editBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
            editBtn.titleLabel.font = [UIFont systemFontOfSize:15];
            [editBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
            [editBtn setTitle:@"取消" forState:UIControlStateNormal];
            [editBtn layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleLeft imageTitleSpace:5];
            
            [editBtn addTarget:self action:@selector(editBtnClick) forControlEvents:UIControlEventTouchUpInside];
            [whiteV addSubview:editBtn];
            
            UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 44.5, SCREENW, 0.5)];
            line.backgroundColor = LINE_COLOR;
            [whiteV addSubview:line];
            
        }
    }
    return headerV;
    
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc]init];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.companysModelMArr.count) {
        return self.companysModelMArr.count;
    }
    return 1;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.companysModelMArr.count == 0) {
        
        return SCREENH - kScreenTopHeight;
    }else{
        return 80.f;
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.companysModelMArr.count == 0) {
        NSString *title = @"暂无专辑";
        return [self nodataCellWithInfo:title tableView:tableView];
    }else{
        
        StarProductsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StarProductsTableViewCellID"];
        if (!cell) {
            cell = [[StarProductsTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"StarProductsTableViewCellID"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.isHomeRz = NO;
        StarProductsModel *model = self.companysModelMArr[indexPath.row];
        cell.isEditting = _isEditting;

        [cell refreshUI:model];
        cell.contactBtn.hidden = YES;

        return cell;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self noDataIsAllowSelectedTbVw:tableView withIndexPaht:indexPath]){
        [self pressAddProductBtn];
        return;
        
    }
    
    if (_isEditting) {
        
        StarProductsModel *company = self.companysModelMArr[indexPath.row];
        if ([company.selected isEqualToString:@"1"]) {
            company.selected = @"0";
        }else{
            company.selected = @"1";
        }
        
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        
        [self refreshAllChooseBtnState];
        return;
        
    }

    
    if (![TestNetWorkReached networkIsReached:self]) {
        
        return;
    }else{
        
        if (self.companysModelMArr.count == 0) {
            [self pressAddProductBtn];
            return;
        }else{
            
            StarProductsModel *model = self.companysModelMArr[indexPath.row];
            
            NSString *tempStr = model.detail;
            NSDictionary *urldict = [PublicTool toGetDictFromStr:tempStr];
            [[AppPageSkipTool shared] appPageSkipToProductDetail:urldict];
        }
    }
}

-(UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UIContextualAction *removeTag = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"删除" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        
        //移除标签
        StarProductsModel *model = self.companysModelMArr[indexPath.row];
        
        [self requestRemove:model.productId];
    }];
    removeTag.backgroundColor = RED_TEXTCOLOR;
    UISwipeActionsConfiguration *action = [UISwipeActionsConfiguration configurationWithActions:@[removeTag]];
    action.performsFirstActionWithFullSwipe = NO;
    return action;
    
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (iOS11_OR_HIGHER) {
        return @[];
        
    }
    UITableViewRowAction *removeAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        StarProductsModel *model = self.companysModelMArr[indexPath.row];
        
        [self requestRemove:model.productId];
    }];
    return @[removeAction];
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return (self.companysModelMArr.count > 0);
}

- (void)chooseAllBtnClick:(UIButton*)btn{
    btn.selected = !btn.selected;
    _allChoose = btn.selected;
    
    for (StarProductsModel *model in self.companysModelMArr) {
        if (btn.selected) {
            model.selected = @"1";
            
        }else{
            model.selected = @"0";
            
        }
    }
    [self.tableView reloadData];
}
- (void)refreshAllChooseBtnState{
    
    BOOL ifAllChoose = YES;
    for (StarProductsModel *model in self.companysModelMArr) {
        if (![model.selected isEqualToString:@"1"]) { //存在未选中
            ifAllChoose = NO;
            _allChoose = NO;
            break;
            
        }
    }
    if (ifAllChoose) {
        _allChoose = YES;
    }
    
    [self.tableView reloadData];
}

- (void)editBtnClick{
    [self.view bringSubviewToFront:_bottomView];
    _isEditting = !_isEditting;
    if (_isEditting) {
        
        self.tableView.tableHeaderView = nil;
        self.tableView.mj_header = nil;
        [UIView animateWithDuration:0.3 animations:^{
            _bottomView.top = self.view.height - 44;
        }completion:nil];
        self.tableView.height = self.view.height;
        [self.tableView reloadData];
        
    }else{
        
        [self cancleEditting];
        
    }
    
}

// 结束 编辑
- (void)cancleEditting{
    _allChoose = NO;
    _isEditting = NO;
    self.tableView.height = self.view.height;
    _bottomView.top = self.view.height;
    self.tableView.tableHeaderView = self.tableHeadView;
    self.tableView.mj_header = self.mjHeader;

    [self.companysModelMArr enumerateObjectsUsingBlock:^(StarProductsModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.selected = @"0";
    }];
    
    [self.tableView reloadData];
    [self.tableView setContentOffset:CGPointMake(0, 0) animated:NO];
    
    
}


#pragma mark - LrdOutputViewDelegate
- (void)didSelectedAtIndexPath:(NSIndexPath *)indexPath{
    
    switch (indexPath.row) {
        case 0:{
            //share
            [self shareURL];
            break;
        }
        case 1:{
            //排序
            [self orderData];
            break;
        }
        default:
            break;
    }
}
#pragma mark - AddProductToGroupOnGroupDelegate
- (void)addSuccess{

    [self requesetProductList];
    
    if ([self.delegate respondsToSelector:@selector(addSuccess:)]) {
        [self.delegate addSuccess:self.tagItem];
    }
}
#pragma mark - public
- (void)buildRightBarButtonItem{
    
    UIButton * moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    moreBtn.frame = RIGHTBARBTNFRAME; //x坐标没有作用
    [moreBtn setImage:[UIImage imageNamed:@"moreOptions"] forState:UIControlStateNormal];
    [moreBtn addTarget:self action:@selector(pressMoreOptions:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * moreItem = [[UIBarButtonItem alloc]initWithCustomView:moreBtn];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = RIGHTNVSPACE;
    if (iOS11_OR_HIGHER) {
        
        moreBtn.width = 30;
        moreBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:moreBtn];
        
        self.navigationItem.rightBarButtonItems = @[buttonItem];
        
    }else{
        self.navigationItem.rightBarButtonItems = @[ negativeSpacer,moreItem];
    }
}

- (void)pressShareBtn:(id)sender{
    
    [self shareURL];
}

- (void)pressMoreOptions:(UIButton *)sender{
    
    CGFloat x = SCREENW-10;
    CGFloat y = kScreenTopHeight + 10;
    _outputView = [[LrdOutputView alloc] initWithDataArray:self.moreOptionsArr origin:CGPointMake(x, y) width:120 height:44 direction:kLrdOutputViewDirectionRight hasImg:YES];
    _outputView.delegate = self;
    _outputView.dismissOperation = ^(){
        
        _outputView = nil;
    };
    [_outputView pop];
}
-(void)shareURL{
    NSString *titleStr = [NSString stringWithFormat:@"%@(%@个)",self.tagItem.tag,self.tagItem.product_num];
    
    NSString *detailStr = @"商业信息服务平台";
    
    NSString *url = [NSString stringWithFormat:@"http://wx.qimingpian.com/zuhe/filesshare.html?tag_uuid=%@",self.tagItem.tag_uuid];
    UIImage *image = [UIImage imageNamed:@"share_group.jpg"];
    
    [self.shareTool shareToOtherApp:detailStr aTitleSessionStr:titleStr aTitleTimelineStr:titleStr aIcon:image aOpenUrl:url onViewController:self shareResult:^(BOOL shareSuccess) {
        if (shareSuccess) {
         
        }
    }];
}

- (void)orderData{
    orderByLunci = !orderByLunci;
    [self.tableView.mj_header beginRefreshing];
}

- (void)initHeaderView{
    _headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 45)];//表头
    _headerView.backgroundColor = [UIColor whiteColor];
    
    _headerLab = [[UILabel alloc]initWithFrame:CGRectMake(17, 0, 150, 45)];
    _headerLab.font = [UIFont systemFontOfSize:15];
    [_headerView addSubview:_headerLab];
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 44, SCREENW, 1)];
    line.backgroundColor = LIST_LINE_COLOR;
    [_headerView addSubview:line];
    
    CGFloat btnY = 0.f;
    CGFloat btnW = 60;
    CGFloat btnH = 45.f;
    
    UIButton *addBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREENW - btnW - 15, btnY, btnW, btnH)];
    [addBtn setTitle:@"添加" forState:UIControlStateNormal];
    [addBtn setTitleColor:H5COLOR forState:UIControlStateNormal];
    addBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [addBtn setImage:[UIImage imageNamed:@"add-yellow"] forState:UIControlStateNormal];
    [addBtn layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleLeft imageTitleSpace:5];
    [addBtn addTarget:self action:@selector(pressAddProductBtn) forControlEvents:UIControlEventTouchUpInside];
    [_headerView addSubview:addBtn];
}

- (void)initTableView{
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH - kScreenTopHeight) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc]init];
    self.tableView.backgroundColor = RGB(240, 239, 245, 1);
    [self.view addSubview:self.tableView];
    
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
}

- (void)changeTableviewFrame{

    if (self.productidMArr.count > 0) {
        NSString *headerStr = [NSString stringWithFormat:@"共%ld个项目",(long)(count ? count : (NSInteger)self.companysModelMArr.count)];


        _headerLab.text = headerStr;
        if (!_isEditting) {
            self.tableView.tableHeaderView = self.tableHeadView;
        }
        
    }
    else{
        
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, 0.1f)];
        
        if (!_isEditting) {
            
            self.tableView.tableHeaderView = headerView;
        }
    }
}

- (void)pullDown{
    
    self.view.userInteractionEnabled = NO;

    [self.tableView.mj_footer resetNoMoreData];
    self.currentPage = 1;
    [self requesetProductList];
}

- (void)pullUp{

    self.currentPage ++;
    [self requesetProductList];
}
- (void)pressAddProductBtn{
    SearchProductViewController *listVC = [[SearchProductViewController alloc] initWithAction:@"CollectCompanyListViewController"];
    listVC.delegate = self;
    listVC.groupId = self.tagItem.tag_id;
    listVC.hasProductidMArr = [NSMutableArray arrayWithArray:self.productidMArr];
    
    [self.navigationController pushViewController:listVC animated:YES];

}
#pragma mark -请求移出分组
- (void)requestRemove:(NSString *)productId{
    
    [PublicTool showHudWithView:self.view];
    [[NetworkManager sharedMgr]RequestWithMethod:kHTTPPost URLString:@"h/workTagDeleteProduct" HTTPBody:@{@"tag_id":self.tagItem.tag_id,@"product_id":productId} completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        [PublicTool dismissHud:self.view];
        if (resultData) {
            NSArray *tmpArr = [NSArray arrayWithArray:self.companysModelMArr];
            //选择一个
            if (_isEditting) {
                [ShowInfo showInfoOnView:self.view withInfo:@"删除成功"];
                
                [self refreshDeleteData];
                [self cancleEditting];
                if ([self.delegate respondsToSelector:@selector(delSuccess:)]) {
                    [self.delegate delSuccess:self.tagItem];
                }
                
            }else{
                
                for (StarProductsModel *company in tmpArr) {
                    
                    if ([company.productId isEqualToString:productId]) {
                        
                        [self.productidMArr removeObject:productId];
                        [self.companysModelMArr removeObject:company];
                        [ShowInfo showInfoOnView:self.view withInfo:@"删除成功"];
                        
                        [self changeTableviewFrame];
                        [self.tableView reloadData];
                        break;
                    }
                }
            }
            if ([self.delegate respondsToSelector:@selector(delSuccess:)]) {
                [self.delegate delSuccess:self.tagItem];
            }
        }
    }];
}
#pragma mark - 请求获取某一标签下的产品列表
- (void)requesetProductList{
    if ([TestNetWorkReached networkIsReached:self]) {
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        
        [dic setValue: self.tagItem.tag_id forKey:@"tag_id"];
        
        NSString *order = orderByLunci ? @"lunci" : @"time";
        [dic setValue:order forKey:@"order"];
        
        //默认 50条
        [dic setValue:[NSString stringWithFormat:@"%ld",(long)self.currentPage] forKey:@"page"];
        [dic setValue:[NSString stringWithFormat:@"%ld",(long)self.numPerPage] forKey:@"page_num"];

        [[NetworkManager sharedMgr]RequestWithMethod:kHTTPPost URLString:@"h/workTagProductList" HTTPBody:dic completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
            
            self.view.userInteractionEnabled = YES;
            [self hideHUD];
            [self.tableView.mj_header endRefreshing];
            [self.tableView.mj_footer endRefreshing];
            
            if (resultData && [resultData isKindOfClass:[NSDictionary class]]) {
                
                NSMutableArray *productMArr = [NSMutableArray array];
                NSDictionary *dataDict = resultData;
                count = [dataDict[@"count"] integerValue];
                
                NSArray *productsDict = [dataDict objectForKey:@"list"];
                
                for (NSDictionary *productDict in productsDict) {
                    
                    StarProductsModel *company = [[StarProductsModel alloc] init];
                    [company setValuesForKeysWithDictionary:productDict];
                    company.selected = @"0";
                    [productMArr addObject:company];
                }
                self.productidMArr = [NSMutableArray arrayWithArray:dataDict[@"product_id"]];
                
                if (self.currentPage == 1) {
                    self.companysModelMArr = productMArr;
                    
                }else{
                    if (productMArr.count > 0) {
                        for (StarProductsModel *company in productMArr) {
                            [self.companysModelMArr addObject:company];
                        }
                    }
                }
                
                
                [self changeTableviewFrame];
                [self refreshFooter:productMArr];
                
            }
            [self.tableView reloadData];

        }];

    }else{
        self.view.userInteractionEnabled = YES;

        [self hideHUD];
        [self.tableView.mj_footer endRefreshing];
        [self.tableView.mj_header endRefreshing];
        self.currentPage --;

    }
    
}
#pragma mark - 懒加载
-(NSMutableArray *)companyCellStrHeightMArr{
    if (!_companyCellStrHeightMArr) {
        _companyCellStrHeightMArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _companyCellStrHeightMArr;
}
-(NSMutableArray *)companysModelMArr{
    if (!_companysModelMArr) {
        _companysModelMArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _companysModelMArr;
}

- (NSArray *)moreOptionsArr{
    
    if (!_moreOptionsArr) {
        
        
        LrdCellModel *shareModel = [[LrdCellModel alloc] initWithTitle:@"分享" imageName:@"web_share"];
        
        LrdCellModel *orderModel = [[LrdCellModel alloc] initWithTitle:@"排序" imageName:@"orderProduct"];
        _moreOptionsArr = @[shareModel,orderModel];
    }
    return _moreOptionsArr;
}



- (NSMutableArray *)productidMArr{
    
    if (!_productidMArr) {
        _productidMArr = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _productidMArr;
}



- (UIView *)tableHeadView{
    if (!_tableHeadView) {
        UIView *headerV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, 55.f)];
        
        UIView *grayV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 10)];
        grayV.backgroundColor = TABLEVIEW_COLOR;
        [headerV addSubview:grayV];
        
        UIView *whiteV = [[UIView alloc]initWithFrame:CGRectMake(0, 10, SCREENW, 45)];
        whiteV.backgroundColor = [UIColor whiteColor];
        [headerV addSubview:whiteV];
        
        NSString *info = [NSString stringWithFormat:@"共%ld个项目",(long)(count ? count : (NSInteger)self.companysModelMArr.count)];
        UILabel *infoLbl = [[UILabel alloc] initWithFrame:CGRectMake(17, 0, 200, 45)];
        infoLbl.text = info;
        infoLbl.textColor = H9COLOR;
        infoLbl.font = [UIFont systemFontOfSize:13];
        
        _headerLab = infoLbl;
        
        [whiteV addSubview:infoLbl];
        
        CGFloat btnW = 60;
        UIButton *addBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREENW - btnW*2 - 35.f, 0.f, btnW, 45)];
        [addBtn setImage:[UIImage imageNamed:@"onework_add"] forState:UIControlStateNormal];
        [addBtn setTitle:@"添加" forState:UIControlStateNormal];
        [addBtn setTitleColor:NV_TITLE_COLOR forState:UIControlStateNormal];
        [addBtn layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleLeft imageTitleSpace:5];
        addBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        addBtn.titleLabel.textColor = NV_TITLE_COLOR;
        [addBtn addTarget:self action:@selector(pressAddProductBtn) forControlEvents:UIControlEventTouchUpInside];
        [whiteV addSubview:addBtn];
        addBtn.hidden = _isEditting;
        
        UIButton *editBtn = [[UIButton alloc]initWithFrame:CGRectMake(SCREENW - btnW - 17.f, 7.5, btnW, 30)];
        [editBtn setTitleColor:NV_TITLE_COLOR forState:UIControlStateNormal];
        editBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [editBtn layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleLeft imageTitleSpace:5];
        
        UIImage *img = [UIImage imageNamed:@"edit_card"];
        [editBtn setImage:img forState:UIControlStateNormal];
        [editBtn setTitle:@"编辑" forState:UIControlStateNormal];
        
        editBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [editBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        
        [editBtn addTarget:self action:@selector(editBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [whiteV addSubview:editBtn];
        
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 44.5, SCREENW, 0.5)];
        line.backgroundColor = LINE_COLOR;
        [whiteV addSubview:line];
        
        _tableHeadView = headerV;
    }
    return _tableHeadView;
}
@end
