//
//  CardToContactController.m
//  qmp_ios
//
//  Created by QMP on 2018/4/10.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "CardToContactController.h"
#import "LeadCardCell.h"
#import "CardLeadProgressView.h"

#define CardCellIdenti @"LeadCardCellID"

@interface CardToContactController ()<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate>
{
    UIView *_bottomView;
    UIButton *_leadBtn;
    UIButton *_allSelectBtn;

    CardLeadProgressView *_progressView;
    BOOL _isAllSelect;
}


@property (strong, nonatomic) NSMutableArray *tableData; //keyValue 数组记录section
@property (strong, nonatomic) NSMutableArray *cardData;

@property (strong, nonatomic) ManagerHud *hudTool;
@property (strong, nonatomic) GetSizeWithText *sizeTool;
@property (strong, nonatomic) NSMutableArray *sectionTitleArr;
@property (nonatomic,strong) UITapGestureRecognizer *tapCancelSearch;

@end

@implementation CardToContactController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    self.tableView.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = @"导出至手机通讯录";
    
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

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
   
    return 0.1;
}

//-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section{
//    UITableViewHeaderFooterView *headerV = (UITableViewHeaderFooterView*)view;
//    headerV.contentView.backgroundColor = TABLEVIEW_COLOR;
//}

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
    return self.cardData.count ? self.cardData.count : 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
 
    if (self.cardData.count == 0) {
        return SCREENH - kScreenTopHeight;
    }
    
    return 50.0;
    
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    return @[];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    if (self.cardData.count > 0) {
        
        id card = self.cardData[indexPath.row];
        
        LeadCardCell *cardCell = [tableView dequeueReusableCellWithIdentifier:CardCellIdenti forIndexPath:indexPath];
        if (self.cardFrom == CardStyleFromUpload) {
            cardCell.cardItem = self.cardData[indexPath.row];
        }else if (self.cardFrom == CardStyleFromEntrust) {

            [cardCell refreshContactInfo:self.cardData[indexPath.row]];
        }else{
            [cardCell refreshFriendInfo:self.cardData[indexPath.row]];
        }
        cardCell.selectionStyle = UITableViewCellSelectionStyleNone;
        cardCell.contentView.backgroundColor = tableView.backgroundColor;
        cardCell.selectBtn.tag = 1000 + indexPath.row;
        objc_setAssociatedObject(cardCell.selectBtn, "card", card, OBJC_ASSOCIATION_RETAIN);
        
        [cardCell.selectBtn addTarget:self action:@selector(cardCellSelectBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        
        return cardCell;
        
    }
    return [self nodataCellWithInfo:REQUEST_DATA_NULL tableView:tableView];
}

- (void)cardCellSelectBtnClick:(UIButton*)btn{
    
    if (self.cardFrom == CardStyleFromExchange) {
        FriendModel *cardItem = objc_getAssociatedObject(btn,"card");
        cardItem.selected = cardItem.selected.integerValue == 1 ? @"0":@"1";
    }else{
        CardItem *cardItem = objc_getAssociatedObject(btn,"card");
        cardItem.selected = !cardItem.selected;
    }

    [self.tableView reloadData];
    [self refreshLeadBtn];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if([self noDataIsAllowSelectedTbVw:tableView withIndexPaht:indexPath]){return;}
    if (self.cardFrom == CardStyleFromExchange) {
        FriendModel *friend1 = self.cardData[indexPath.row];
        friend1.selected = friend1.selected.integerValue == 1 ? @"0":@"1";
    }else{
        CardItem *card = self.cardData[indexPath.row];
        card.selected = !card.selected;
    }
    
    [self.tableView reloadData];
    [self refreshLeadBtn];
}


#pragma mark - 请求名片列表
- (BOOL)requestData{
    if (![super requestData]) {
        return NO;
    }
    
    if (self.cardFrom == CardStyleFromUpload) {
        [self requestMyCard]; //名片
   
    }else if (self.cardFrom == CardStyleFromEntrust) { //委托联系
        [self requestContacts];

    }else{
        [self requestExchange];
    }
    
    return YES;
}

//通讯录
- (void)requestExchange{
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:@(1),@"page",@(10000),@"num", nil];
    [AppNetRequest getMyfriendListWithParameter:@{} completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        [self hideHUD];
        
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        
        if (resultData && [resultData isKindOfClass:[NSArray class]]) {
            
            NSMutableArray *arr = [NSMutableArray array];
            for (NSDictionary *dic in resultData) {
                FriendModel *person = [[FriendModel alloc]initWithDictionary:dic error:nil];
                if (![PublicTool isNull:person.bind_phone]) {
                    [arr addObject:person];
                }
            }
            
            [self.cardData addObjectsFromArray:arr];
            [self refreshFooter:resultData];
        }

        [self.tableView reloadData];

    }];
}


// 名片
- (void)requestMyCard{
    NSInteger page = 1;
    
    
    NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:[WechatUserInfo  shared].unionid,@"unionid",@"qmp_ios",@"ptype",VERSION,@"version",@(page),@"page",@(10000),@"page_num", nil];

    [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:@"L/cardListIs" HTTPBody:param completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        [self hideHUD];
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        NSMutableArray *retMArr = [[NSMutableArray alloc] initWithCapacity:0];
        if (resultData) {
            for (NSDictionary *cardsDict in resultData[@"data"]) {
                CardItem *item = [[CardItem alloc] init];
                [item setValuesForKeysWithDictionary:cardsDict];
                [retMArr addObject:item];
            }
        }
        self.cardData = [NSMutableArray arrayWithArray:retMArr];
        [self.tableView reloadData];
        [self refreshFooter:@[]];
    }];
    
}


- (void)requestContacts{
    
    NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:[WechatUserInfo  shared].unionid,@"unionid",@"qmp_ios",@"ptype",VERSION,@"version",@(1),@"page",@(10000),@"page_num", nil];
    
    [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:@"Contact/getContactList" HTTPBody:param completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        [self hideHUD];

        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        
        if (resultData && [resultData[@"msg"] isKindOfClass:[NSArray class]]) {
            NSMutableArray *retMArr = [[NSMutableArray alloc] initWithCapacity:0];
            
            for (NSDictionary *dic in resultData[@"msg"]) {
                CardItem *cardItem = [[CardItem alloc] init];
                [cardItem setValuesForKeysWithDictionary:dic];
                [retMArr addObject:cardItem];
            }
            
            self.cardData = [NSMutableArray arrayWithArray:retMArr];
            [self.tableView reloadData];
            [self refreshFooter:@[]];
            
        }
        
    }];
}

#pragma mark - public
- (void)buildRightBarButtonItem{
    
    
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 80, 44)];
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    [btn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
    [btn setTitle:@"全选" forState:UIControlStateNormal];
    
    [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [btn addTarget:self action:@selector(pressRightButtonItem:) forControlEvents:UIControlEventTouchUpInside];
    _allSelectBtn = btn;
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc]initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = item1;
}


- (void)pressRightButtonItem:(id)sender{
    _isAllSelect = !_isAllSelect;
    [_allSelectBtn setTitle:_isAllSelect?@"取消全选":@"全选" forState:UIControlStateNormal];
    //全选
    if (self.cardFrom == CardStyleFromExchange) {
        for (FriendModel *card in self.cardData) {
            card.selected = _isAllSelect ? @"1":@"0";
        }
    }else{
        for (CardItem *card in self.cardData) {
            card.selected = _isAllSelect;
        }
    }
    
    [self.tableView reloadData];
    [self refreshLeadBtn];
}

#pragma mark ----批量操作
- (void)initBottomView{
    
    _bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, self.tableView.bottom, SCREENW, kScreenBottomHeight)];
    _bottomView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_bottomView];
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 0.5)];
    line.backgroundColor = LINE_COLOR;
    [_bottomView addSubview:line];
    
    UIButton *leadBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, SCREENW, kScreenBottomHeight)];
    NSMutableAttributedString *attText = [[NSMutableAttributedString alloc]initWithString:@"导出"];
    [attText addAttributes:@{NSForegroundColorAttributeName:NV_TITLE_COLOR} range:NSMakeRange(0, 2)];
    [leadBtn setAttributedTitle:attText forState:UIControlStateNormal];
    
    leadBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [leadBtn layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleLeft imageTitleSpace:7];
    [leadBtn addTarget:self  action:@selector(leadBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:leadBtn];
  
    _leadBtn = leadBtn;
}


// 导出名片
- (void)leadBtnClick{
    
    //访问手机通讯录
    [PublicTool CheckAddressBookAuthorization:^(bool isAuthorized, bool isUp_ios_9) {
        if (isAuthorized) {
            [self toLead];
        }else{
            [PublicTool showAlert:@"通讯录权限未开启" message:@"通讯录权限未开启，请进入系统【设置】>【隐私】>【通讯录】中打开开关,开启通讯录功能"];
        }
    }];
}
- (void)toLead{
    NSMutableArray *leadAdd = [NSMutableArray array];
    if (self.cardFrom == CardStyleFromExchange) {
        for (FriendModel *friend1 in self.cardData) {
            if (friend1.selected.integerValue == 1) {
                CardItem *item = [[CardItem alloc]init];
                item.cardName = friend1.nickname;
                item.phone = friend1.bind_phone;
                item.wechat = friend1.wechat;
                item.email = friend1.email;
                item.company = friend1.company;
                item.zhiwei = friend1.position;
                [leadAdd addObject:item];
            }
        }
    }else{
        for (CardItem *card in self.cardData) {
            if (card.selected) {
                [leadAdd addObject:card];
            }
        }
    }
    
    
    if (leadAdd.count == 0) {
        
        [PublicTool showMsg:@"请选择要导入的人脉信息"];
        return;
    }
    
    [PublicTool alertActionWithTitle:@"提示" message:[NSString stringWithFormat:@"本次企名片共为您导出%ld条人脉名片到手机通讯录(已做去重)",leadAdd.count] cancleAction:^{
        
    } sureAction:^{
        
        //        [PublicTool showHudWithView:KEYWindow];
        _progressView = (CardLeadProgressView*)[[NSBundle mainBundle] loadNibNamed:@"CardLeadProgressView" owner:nil options:nil].lastObject;
        _progressView.frame = [UIScreen mainScreen].bounds;
        _progressView.titleLab.text = [NSString stringWithFormat:@"本次企名片共为您导出%ld条人脉名片到手机通讯录(会去重)",leadAdd.count];
        _progressView.progressLab.text = @"0%";
        [KEYWindow addSubview:_progressView];
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            //同步到通讯录
            for (int i=0;i<leadAdd.count;i++) {
                CardItem *card = leadAdd[i];
                if (![PublicTool isNull:card.telephone] || ![PublicTool isNull:card.phone]) {
                    [PublicTool savePeopleToContactForCardItem:card];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    _progressView.progressLab.text = [NSString stringWithFormat:@"%.0f%%",i*100.0/leadAdd.count];
                    
                    if (i==leadAdd.count-1) {
                        _progressView.progressLab.text = @"100%";
                        [_progressView removeFromSuperview];
                        //                        [PublicTool dismissHud:KEYWindow];
                        [PublicTool showMsg:@"导出完成"];
                        [_leadBtn setAttributedTitle:[[NSAttributedString alloc]initWithString:@"导出"] forState:UIControlStateNormal];
                    }
                    
                });
            }
        });
    }];
}

- (void)refreshLeadBtn{
    
    NSInteger delNum = 0;
    if (self.cardFrom == CardStyleFromExchange) {
        for (FriendModel *card in self.cardData) {
            if (card.selected.integerValue == 1) {
                delNum++;
            }
        }
    }else{
        for (CardItem *card in self.cardData) {
            if (card.selected) {
                delNum++;
            }
        }
    }
    
    NSMutableAttributedString *attText;
    if (delNum) {
        
        attText = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"导出(%ld)",delNum]];
        [attText addAttributes:@{NSForegroundColorAttributeName:BLUE_TITLE_COLOR} range:NSMakeRange(2, attText.length - 2)];
    }else{
        attText = [[NSMutableAttributedString alloc]initWithString:@"导出"];
    }
    [_leadBtn setAttributedTitle:attText forState:UIControlStateNormal];
    
    if (self.cardData.count == delNum) {
        _isAllSelect = YES;
    }else{
        _isAllSelect = NO;
    }
    [_allSelectBtn setTitle:_isAllSelect?@"取消全选":@"全选" forState:UIControlStateNormal];
}


- (void)initTableView{
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH - kScreenTopHeight-kScreenBottomHeight) style:UITableViewStyleGrouped];
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.mj_header = nil;
    self.tableView.mj_footer = self.mjFooter;
    [self.tableView registerClass:[LeadCardCell class] forCellReuseIdentifier:CardCellIdenti];
    [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"headerView"];

    [self.tableView setSectionIndexBackgroundColor:[UIColor clearColor]];
    [self.tableView setSectionIndexColor:[UIColor darkGrayColor]];
  
}


#pragma mark - 懒加载

- (NSMutableArray *)tableData{
    if (!_tableData) {
        _tableData = [NSMutableArray array];
    }
    return _tableData;
}
- (NSMutableArray *)cardData{
    if (!_cardData) {
        _cardData = [NSMutableArray array];
    }
    return _cardData;
}

- (NSMutableArray *)sectionTitleArr{
    if (!_sectionTitleArr) {
        _sectionTitleArr = [NSMutableArray array];
    }
    return _sectionTitleArr;
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
