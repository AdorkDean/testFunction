

#import "JigouNextTargetInvestments.h"
#import "JigouInvestmentsCaseModel.h"
#import "IndustryItem.h"
#import "SKTagView.h"
#import "JigouTZCaseCell.h"

#define FEEDBACKBUTTONFRAME CGRectMake(8, 11.5, 20, 21)
#define CompanyCellInden @"CompanyCell"
@interface JigouNextTargetInvestments ()<UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>
{
    SKTagView *_tagView;
    NSInteger _selectedTagIndex;

    NSString *_lunci;
    UIView *_line;
}

@property(nonatomic,strong)NSMutableArray *tagArray; //标签arr
@property(nonatomic,strong)NSMutableArray *tagTitles; //标签titles
@property (nonatomic, strong) JigouTZCaseCell *caseCell;

@property (nonatomic,strong) NSMutableArray *investmentsCaseMdata;
@property (strong, nonatomic) NSMutableArray *hangyeMArr;
@property (strong, nonatomic) NSMutableArray *selectedMArr;
@property (strong, nonatomic) NSString *hangyeTitle;
@property(nonatomic,strong) SKTag *selectedTag;
@property(nonatomic,strong) SKTag *commonTag;
@property (nonatomic, strong) NSMutableDictionary *heightCacheDict;

@end


@implementation JigouNextTargetInvestments

- (void)dealloc{
    [self.tableView removeObserver:self forKeyPath:@"contentOffset"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.currentPage = 1; //默认30条
    self.numPerPage = 30;
    _lunci = @"全部"; //默认全部
    _selectedTag = 0; //默认选中全部
    self.selectedMArr = [NSMutableArray array];
    [self buildInvestmentsCaseUI];
    [self showHUD];
    [self requestNextTargetInvestments:[NSMutableDictionary dictionaryWithDictionary:self.parametersDic]];
}


#pragma mark - Request---战绩，  传入投资轮次类型 ， 默认全部
- (void)requestNextTargetInvestments:(NSMutableDictionary *)dict{
    
    //判断网络连接状态
    if (![TestNetWorkReached networkIsReached:self]) {
        [self hideHUD];
        [self.tableView.mj_header endRefreshing];
        self.view.userInteractionEnabled = YES;

    }else{
        NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithDictionary:dict];
        if ([_lunci isEqualToString:@"全部"]) { //空 则默认全部
            [mDict removeObjectForKey:@"lunci"];
        }else{
            [mDict setValue:_lunci forKey:@"lunci"];
        }
        [mDict setValue:@(self.currentPage) forKey:@"page"];
        [mDict setValue:@(self.numPerPage) forKey:@"num"];
        
        [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"AgencyDetail/agencyInvestPerformance470" HTTPBody:mDict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
            [self hideHUD];
            self.view.userInteractionEnabled = YES;
            [self.tableView.mj_header endRefreshing];
            [self.tableView.mj_footer endRefreshing];
            
            if (resultData && [resultData isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dataDict = resultData;
                if (!self.tagArray) {
                    self.tagArray = [NSMutableArray array];
                    [self.tagArray addObjectsFromArray:resultData[@"rotation_list"]];
                }
                
                [self initTagView];
                if (self.currentPage == 1) {
                    [self.investmentsCaseMdata removeAllObjects];
                }
                
                NSArray *dataMarr = dataDict[@"list"];
                if (dataMarr && [dataMarr isKindOfClass:[NSArray class]]) {
                    for (NSDictionary *dataDict in dataMarr) {
                        JigouInvestmentsCaseModel *investmentsCaseModel = [[JigouInvestmentsCaseModel alloc] init];
                        [investmentsCaseModel setValuesForKeysWithDictionary:dataDict];
                        [self.investmentsCaseMdata addObject:investmentsCaseModel];
                    }
                }
                [self refreshFooter:dataMarr];
                
                _hangyeTitle = @"";
                if (self.selectedMArr) {
                    if (self.selectedMArr.count) {
                        _hangyeTitle = [self.selectedMArr lastObject];
                    }
                }
            }
            [self.tableView reloadData];
        }];
    }
}

- (void)buildInvestmentsCaseUI{

    self.navigationItem.title = @"战绩";
    [self initTableView];
}
- (void)initTagView{
    if (_tagView || !self.tagArray ||self.tagArray.count == 0) {
        return;
    }
    
    self.tagTitles = [NSMutableArray array];
    for (NSDictionary *dic in self.tagArray) {
        NSString *tagTitle = [NSString stringWithFormat:@"%@ (%@)",dic[@"name"],dic[@"count"]];
        [self.tagTitles addObject:tagTitle];
    }
    _tagView = [[SKTagView alloc] init];
    _tagView.backgroundColor = [UIColor whiteColor];
    // 整个tagView对应其SuperView的上左下右距离
    _tagView.padding = UIEdgeInsetsMake(20, 17, 20, 17);
    // 上下行之间的距离
    _tagView.lineSpacing = 15;
    // item之间的距离
    _tagView.interitemSpacing = 15;
    // 最大宽度
    _tagView.preferredMaxLayoutWidth = SCREENW;
    
// 开始加载
    [self.tagTitles enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        SKTag *tag;
        if (idx == 0) {
            tag = self.selectedTag;
            
        }else{
            tag = self.commonTag;
        }
        tag.text = self.tagTitles[idx];
        [_tagView addTag:tag];
        
    }];
    
    // 点击事件回调
    __weak typeof(self) weakSelf = self;
    _tagView.didTapTagAtIndex = ^(NSUInteger idx){
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.view.userInteractionEnabled = NO;
        //重置轮次选择参数
        NSDictionary *lunciDic = weakSelf.tagArray[idx];
        NSString *requestLunci = lunciDic[@"name"];
        if ([strongSelf -> _lunci isEqualToString:requestLunci]) {
            strongSelf.view.userInteractionEnabled = YES;
            return ;
        }

        strongSelf -> _lunci = requestLunci;
        weakSelf.currentPage = 1;
        if ([strongSelf.tableView visibleCells].count) {
            [strongSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:YES];
        }
        [ strongSelf.tableView.mj_header beginRefreshing];
    };
    
    CGFloat tagHeight = _tagView.intrinsicContentSize.height;
    _tagView.frame = CGRectMake(0, 0, SCREENW, tagHeight);
    [_tagView layoutSubviews];
    [self.view insertSubview:_tagView atIndex:0];
    
    [_tagView onTag:_tagView.subviews[0]];
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, _tagView.bottom - 0.5, SCREENW, 0.5)];
    line.backgroundColor = LINE_COLOR;
    [_tagView addSubview:line];
    _line = line;
    _line.hidden = YES;
    self.tableView.top = tagHeight;
    self.tableView.height = self.view.height - (tagHeight);
    [self.tableView reloadData];
    
}

- (void)initTableView{
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, _tagView.height, SCREENW, SCREENH-kScreenTopHeight-_tagView.height) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.tableView.backgroundColor = TABLEVIEW_COLOR;
    self.view.backgroundColor = self.tableView.backgroundColor;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.mj_header = self.mjHeader;
    
    [self.view addSubview:self.tableView];
    [self.tableView registerNib:[UINib nibWithNibName:@"JigouTZCaseCell" bundle:nil] forCellReuseIdentifier:@"JigouTZCaseCellID"];

    [self.tableView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    
    if ([keyPath isEqualToString:@"contentOffset"]) {
        if (self.tableView.contentOffset.y > 20) {
            _line.hidden = NO;
        }else{
            _line.hidden = YES;

        }
    }
}

- (void)pullUp{
    self.currentPage ++;
    [self requestNextTargetInvestments:(NSMutableDictionary*)self.parametersDic];
}

-(void)pullDown{
    
    NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithDictionary:self.parametersDic];
    [mDict setValue:@"1" forKey:@"debug"];
    [self requestNextTargetInvestments:mDict];
}


#pragma mark - UITableView
//设置区头高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    if (self.investmentsCaseMdata.count == 0){
        
        return 0.1f;
    }
    else{
        if(section == 0){
            return 10.f;
        }
        else{
            return 0.1;
        }
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}
- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc]init];
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [[UIView alloc]init];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.investmentsCaseMdata.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_investmentsCaseMdata.count == 0) {
        return SCREENH - kScreenTopHeight;
    }
    JigouInvestmentsCaseModel *caseModel = _investmentsCaseMdata[indexPath.row];
    if (![self.heightCacheDict objectForKey:caseModel.detail]) {
        CGFloat height = [self.caseCell setCaseModel:caseModel];
        [self.heightCacheDict setValue:@(height) forKey:caseModel.detail];
        return height;
    }
    
    CGFloat height = [[self.heightCacheDict objectForKey:caseModel.detail] floatValue];
    return height;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.investmentsCaseMdata.count == 0 ) {
        return [self nodataCellWithInfo:REQUEST_DATA_NULL tableView:tableView];
    }
    else{
        
        JigouTZCaseCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JigouTZCaseCellID" forIndexPath:indexPath];
        [cell setCaseModel:self.investmentsCaseMdata[indexPath.row]];
        cell.iconColor = RANDOM_COLORARR[indexPath.section%6];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.investmentsCaseMdata.count == 0) {
        
        return;
    }else{
        JigouInvestmentsCaseModel *model = self.investmentsCaseMdata[indexPath.row];
        if (![PublicTool isNull:model.detail]) {
            
            NSString *urlTmp = model.detail;
            [[AppPageSkipTool shared] appPageSkipToProductDetail:[PublicTool toGetDictFromStr:urlTmp]];
        }
    }
}

#pragma mark - 懒加载
-(JigouTZCaseCell *)caseCell{
    
    if (!_caseCell) {
        _caseCell = [nilloadNibNamed:@"JigouTZCaseCell" owner:nil options:nil].lastObject;
    }
    return _caseCell;
}
- (NSMutableDictionary *)heightCacheDict {
    if (!_heightCacheDict) {
        _heightCacheDict = [NSMutableDictionary dictionary];
    }
    return _heightCacheDict;
}
- (NSMutableArray *)investmentsCaseMdata{
    if (!_investmentsCaseMdata) {
        _investmentsCaseMdata = [[NSMutableArray alloc] initWithCapacity:0];
    }
    
    return _investmentsCaseMdata;
}


- (NSMutableArray *)hangyeMArr{

    if (!_hangyeMArr) {
        _hangyeMArr = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _hangyeMArr;
}
-(SKTag *)selectedTag{
    if (!_selectedTag) {
        // 初始化标签
        SKTag *tag = [[SKTag alloc] init];
        // 标签相对于自己容器的上左下右的距离
        tag.padding = UIEdgeInsetsMake(7, 10, 7, 10);
        // 字体
        tag.font = [UIFont systemFontOfSize:13];
        tag.cornerRadius = 2;
        // 边框宽度
        tag.borderWidth = 0.5;
        // 边框颜色
        tag.borderColor = BORDER_LINE_COLOR;
        // 字体颜色
        tag.textColor = BLUE_TITLE_COLOR;
        // 是否可点击
        tag.enable = YES;
        _selectedTag = tag;
    }
    return _selectedTag;
}

- (SKTag *)commonTag{
    if (!_commonTag) {
        // 初始化标签
        SKTag *tag = [[SKTag alloc] init];
        // 标签相对于自己容器的上左下右的距离
        tag.padding = UIEdgeInsetsMake(7, 10, 7, 10);
        // 字体
        tag.font = [UIFont systemFontOfSize:13];
        tag.cornerRadius = 2;
        
        // 边框宽度
        tag.borderWidth = 0.5;
        // 边框颜色
        tag.borderColor = BORDER_LINE_COLOR;
        // 字体颜色
        tag.textColor = HTColorFromRGB(0x555555);
        // 是否可点击
        tag.enable = YES;
        _commonTag = tag;
    }
    return _commonTag;
}


@end
