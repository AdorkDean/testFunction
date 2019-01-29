//
//  OneSquareListViewController.m
//  qmp_ios
//
//  Created by Molly on 16/9/6.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import "OneSquareListViewController.h"
#import "ProductListCell.h"

#import "ShareTo.h"
#import "ManagerHud.h"
#import "CustomAlertView.h"

@interface OneSquareListViewController ()<UITableViewDataSource,UITableViewDelegate,ShareDelegate>


@property (strong, nonatomic) UIView *headerView;
@property (strong, nonatomic) UILabel *headerLab;
@property (strong, nonatomic) UIButton *shareBtn;

@property (strong, nonatomic) UIView *toolView;

@property (strong, nonatomic) UIButton *feedbackToolBtn;

@property(nonatomic,strong) NSMutableDictionary * dataMDict;
@property(nonatomic,strong) NSArray *sectionHeaderNameArr;//区头名字 "机构","公司"
@property(nonatomic,strong) NSMutableArray * companysModelMArr;//存公司model
@property(nonatomic,strong) NSMutableArray *companyCellStrHeightMArr;//存companycell各字符串高度,比如:总高度,行业,业务
@property (nonatomic, strong) NSMutableArray *productidMArr;
@property (strong, nonatomic) NSMutableDictionary *infoMDict;

@property (strong, nonatomic) UIImage *printscreenShortImage;
@property (strong,nonatomic) NSMutableArray *feedbackProIds;

@end

@implementation OneSquareListViewController


- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.title = self.groupModel.name;
    self.feedbackProIds = [NSMutableArray array];
    [self buildRightBarButtonItem];
    [self initHeaderView];

    [self initTableView];
    
    [self initToolView];

    if ([self.groupModel.count intValue] > 0) { //保险
        
        [self showHUD];
        [self requestGetProduct];
    }
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - FeedbackResultDelegate

- (void)FeedbackResultSuccess{
    [ShowInfo showInfoOnView:self.view withInfo:@"感谢您的反馈"];
}


#pragma mark - 请求数据

- (void)requestGetProduct{
    
    if ([TestNetWorkReached networkIsReached:self]) {
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:self.infoMDict];
        [dic setValue: self.groupModel.name forKey:@"tag"];

  
        if(self.tableView.mj_header.isRefreshing){
            [dic setValue:@"1" forKey:@"debug"];
        }
        
        [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:@"d/getprobytag3" HTTPBody:dic completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
            [self.tableView.mj_header endRefreshing];
            [self.tableView.mj_footer endRefreshing];
            [self hideHUD];
            if (resultData && resultData[@"list"]) {
                NSDictionary *dataDict = resultData;
                //
                NSMutableArray *productMArr = [[NSMutableArray alloc] initWithCapacity:0];
                NSMutableArray *productidMArr = [[NSMutableArray alloc] initWithCapacity:0];
                
                NSDictionary *productsDict = [dataDict objectForKey:@"list"];
                
                for (NSDictionary *productDict in productsDict) {
                    
                    StarProductsModel *company = [[StarProductsModel alloc] init];
                    [company setValuesForKeysWithDictionary:productDict];
                    
                    [productMArr addObject:company];
                    [productidMArr addObject:company.productId];
                }
                
                self.companysModelMArr = productMArr;
                self.productidMArr = productidMArr;
                [self changeTableviewFrame];
                
                [self.tableView reloadData];
            }
           
            QMPLog(@"--------%@---",resultData);
        }];

    } else{
        [self hideHUD];
    }
}
#pragma mark - 不属于该专辑
- (void)requsetNoBelongThisAlbum:(StarProductsModel *)model{
    
    if ([self.feedbackProIds containsObject:model.productId]) {

        return ;
    }
    
    if (![TestNetWorkReached networkIsReached:self]) {
        return;
    }else{

        [self.tableView setEditing:NO];
        [ShowInfo showInfoOnView:self.view withInfo:@"感谢您的反馈"];
        [self.feedbackProIds addObject:model.productId];
        [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:@"d/editalbumfeedback" HTTPBody:@{@"tag":_groupModel.userfolderid,@"productid":model.productId,@"info":@"不属于该专辑"} completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
            
        }];

        [QMPEvent event:@"trz_square_detail_errorfeedback"];
    }

}


#pragma mark - UITabelView

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [[UIView alloc]init];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0.1;
    }
    return 0.1;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc]init];
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.companysModelMArr.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.companysModelMArr.count == 0) {
        
        return SCREENH - kScreenTopHeight;
    }else{

        
        return 80;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.companysModelMArr.count == 0 ) {
        
        NSString *title = REQUEST_DATA_NULL;
        return [self nodataCellWithInfo:title tableView:tableView];
        
    }else{
        
        ProductListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProductListCellID" forIndexPath:indexPath];

        StarProductsModel *model = self.companysModelMArr[indexPath.section];
        cell.productM = model;
        cell.iconColor = RANDOM_COLORARR[indexPath.section%6];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![TestNetWorkReached networkIsReached:self]) {
        
        return;
    }else{
        
        if (self.companysModelMArr.count == 0 ) {
     
            return;
        }else{
            
            StarProductsModel *model = self.companysModelMArr[indexPath.section];

            NSString *tempStr = model.detail;
            NSDictionary *urlDict = [PublicTool toGetDictFromStr:tempStr];
            [[AppPageSkipTool shared] appPageSkipToProductDetail:urlDict];
        }

    }

}


-(UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    StarProductsModel *model = self.companysModelMArr[indexPath.section];
    
    NSString *title;
    if ([self.feedbackProIds containsObject:model.productId]) {
        title = @"已反馈";
    }else{
        title = @"不属于该专辑";
    }
    
    UIContextualAction *removeAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:title handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
    
        [self requsetNoBelongThisAlbum:model];

    }];
    if ([self.feedbackProIds containsObject:model.productId]) {
        removeAction.backgroundColor = [UIColor lightGrayColor];
    }else{
        removeAction.backgroundColor = RED_TEXTCOLOR;
    }
    UISwipeActionsConfiguration *action = [UISwipeActionsConfiguration configurationWithActions:@[removeAction]];
    action.performsFirstActionWithFullSwipe = NO;
    return action;
}


- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (iOS11_OR_HIGHER) {
        return @[];
        
    }
    StarProductsModel *model = self.companysModelMArr[indexPath.section];
    
    NSString *title;
    if ([self.feedbackProIds containsObject:model.productId]) {
        title = @"已反馈";
    }else{
        title = @"不属于该专辑";
    }
    UITableViewRowAction *removeAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:title handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
       
            [self requsetNoBelongThisAlbum:model];
        
    }];
    if ([self.feedbackProIds containsObject:model.productId]) {
       removeAction.backgroundColor = [UIColor lightGrayColor];
    }else{
        removeAction.backgroundColor = RED_TEXTCOLOR;
    }
    
    return @[removeAction];
}


#pragma mark - public


- (void)buildRightBarButtonItem{
    
    self.shareBtn = [[UIButton alloc] initWithFrame:RIGHTBARBTNFRAME];
    [_shareBtn setImage:[UIImage imageNamed:@"card_share"] forState:UIControlStateNormal];
    [_shareBtn addTarget:self action:@selector(shareURL) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* shareItem = [[UIBarButtonItem alloc]initWithCustomView:_shareBtn];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = RIGHTNVSPACE;
    if (iOS11_OR_HIGHER) {
        
        self.shareBtn.width = 30;
        self.shareBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:self.shareBtn];
        
        self.navigationItem.rightBarButtonItems = @[buttonItem];
        
    }else{
        self.navigationItem.rightBarButtonItems = @[ negativeSpacer,shareItem];
    }
    
    
}
#pragma mark - ShareDelegate
- (void)shareSuccess{
    _printscreenShortImage = nil;
    
    [ShowInfo showInfoOnView:self.view withInfo:@"分享成功"];
}

- (void)shareFaild{
    _printscreenShortImage = nil;
    
    [ShowInfo showInfoOnView:self.view withInfo:@"分享取消"];
}
- (void)shareShortScreenshot{
    //判断网络连接状态
    if (![TestNetWorkReached networkIsReached:self]) {
        if (_printscreenShortImage) {
            _printscreenShortImage = nil;
        }
        return;
    }else{
        [self.shareTool shareDetailImage:_printscreenShortImage];
    }
}
- (void)imageWithShortScreenshot{
    UIImage* image1 = nil;
    UIWindow *screenWindow = [UIApplication sharedApplication].delegate.window;
    CGFloat imgH = SCREENW/1125 *591;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(SCREENW, SCREENH + imgH), NO, 0.0);
    [screenWindow.layer renderInContext:UIGraphicsGetCurrentContext()];
    image1 = UIGraphicsGetImageFromCurrentImageContext();
    
    UIImage *image2 = [UIImage imageNamed:@"QuickMark"];
    [image2 drawInRect:CGRectMake(0, SCREENH, SCREENW, imgH)];//100
    UIImage *togetherImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    _printscreenShortImage = togetherImage;
    
    [self shareShortScreenshot];
}

-(void)shareURL{
    
    NSString *titleStr = [NSString stringWithFormat:@"%@(%@个)",self.groupModel.name,self.groupModel.count];
    
    NSString *detailStr = @"商业信息服务平台";
    
    NSString *url;
    if (iOS9_OR_HIGHER) {
        url = @"http://wx.qimingpian.com/zuhe/filesshare.html?tag=";
        NSString *encodeStr = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)self.groupModel.name, NULL, (CFStringRef)@"!*'();:@&=+ $,./?%#[]", kCFStringEncodingUTF8));
        url = [NSString stringWithFormat:@"%@%@",url,encodeStr];
    }else{
        url = [NSString stringWithFormat:@"%@%@",@"http://wx.qimingpian.com/zuhe/filesshare.html?tag=",self.groupModel.name];
    }
    
    [self.shareTool shareToOtherApp:detailStr aTitleSessionStr:titleStr aTitleTimelineStr:titleStr aIcon:[UIImage imageNamed:@"share_group.jpg"] aOpenUrl:url onViewController:self shareResult:^(BOOL shareSuccess) {
        if (shareSuccess) {
            if ([self.action isEqualToString:@"ManagerSquare"]) {
            }else if([self.action isEqualToString:@"FollowGroup"]){
            }
        }
    }];
    
    [QMPEvent event:@"trz_square_detail_shareclick"];
   
}

/**
 *  下拉刷新
 */
- (void)pullDown{
    
    [self requestGetProduct];
    
}

-(void)initTableView{
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH - kScreenTopHeight - 44.f) style:UITableViewStyleGrouped];
    [self.view addSubview:self.tableView];
    
    //设置代理
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.mj_header = self.mjHeader;//下拉刷新
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;//设置cell的分割线为无
    //去掉多余的线条
    self.tableView.tableFooterView = [[UIView alloc]init];
    self.tableView.backgroundColor = TABLEVIEW_COLOR;
    [self.tableView registerNib:[UINib nibWithNibName:@"ProductListCell" bundle:nil] forCellReuseIdentifier:@"ProductListCellID"];

}

- (void)initHeaderView{
    
    _headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 45)];//表头
    _headerView.backgroundColor = [UIColor whiteColor];
    
    _headerLab = [[UILabel alloc]initWithFrame:CGRectMake(17, 0, 150, 45)];
    _headerLab.font = [UIFont systemFontOfSize:15];
    [_headerView addSubview:_headerLab];
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 44.5, SCREENW, 0.5)];
    line.backgroundColor = LIST_LINE_COLOR;
    [_headerView addSubview:line];
    
}


- (void)changeTableviewFrame{
    
    if (self.companysModelMArr.count > 0) {
        
        _headerLab.textColor = H9COLOR;
        NSString *numStr = [NSString stringWithFormat:@"%lu",(unsigned long)self.companysModelMArr.count];
        NSString *headerStr = [NSString stringWithFormat:@"收录项目%@个",numStr];
//        NSRange range = {5,numStr.length};
//        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:headerStr];
//        [str addAttribute:NSForegroundColorAttributeName value:RED_TEXTCOLOR range:range];
//        _headerLab.attributedText = str;
        _headerLab.text = headerStr;
        self.tableView.tableHeaderView = _headerView;
        
    }else{
        
        if ([_headerView isDescendantOfView:self.view]) {
            [_headerView removeFromSuperview];
        }
    }

}

- (void)initToolView{

    _toolView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREENH - kScreenBottomHeight - kScreenTopHeight, SCREENW, kScreenBottomHeight)];
    _toolView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_toolView];
    
    UIView *lineV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, 1)];
    lineV.backgroundColor = LIST_LINE_COLOR;
    [_toolView addSubview:lineV];

    CGFloat btnW = SCREENW;
    CGFloat collectY = 1;
    
    _feedbackToolBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, collectY,btnW , _toolView.height - collectY)];
    [_feedbackToolBtn setImage:[UIImage imageNamed:@"feedback-group"] forState:UIControlStateNormal];
    [_feedbackToolBtn setTitle:@"反馈" forState:UIControlStateNormal];
    [_feedbackToolBtn setTitleColor:H5COLOR forState:UIControlStateNormal];
    _feedbackToolBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [_feedbackToolBtn layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleLeft imageTitleSpace:7];
    [_feedbackToolBtn addTarget:self action:@selector(immediateFeedbackUs:) forControlEvents:UIControlEventTouchUpInside];
    [_toolView addSubview:_feedbackToolBtn];
    
}

- (void)immediateFeedbackUs:(UIButton *)sender{
    
    sender.selected = YES;
    
    CGFloat height = 65;
    NSMutableArray *mArr = [NSMutableArray arrayWithCapacity:0];//反馈的选项
    [mArr addObject:@"榜单质量差"];
    [mArr addObject:@"公司数量少"];
    if (mArr.count>0) {
        height += ((mArr.count-1)/2+1)*35 + 55.f;
    }
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionaryWithCapacity:0];//反馈所在模块的信息
    [infoDic setValue:_groupModel.userfolderid forKey:@"userfolderid"];
    [infoDic setValue:@"专辑" forKey:@"module"];
    [infoDic setValue:(_groupModel.name&&[_groupModel.name isKindOfClass:[NSString class]]&&![_groupModel.name isEqualToString:@""] ? _groupModel.name:@"")  forKey:@"company"];
    CGRect frame = CGRectMake(0, 0, 200, 40);
    [infoDic setValue:@"榜单列表信息" forKey:@"title"];
    
    CustomAlertView *alert = [[CustomAlertView alloc] initWithAlertViewHeight:mArr frame:frame WithAlertViewHeight:height infoDic:(NSDictionary *)infoDic viewcontroller:self moduleNum:0 isFeeds:NO];
    
    [QMPEvent event:@"trz_square_detail_feedbackclick"];
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
-(NSMutableDictionary *)dataMDict{
    if (!_dataMDict) {
        _dataMDict = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    return _dataMDict;
}

- (NSMutableArray *)productidMArr{
    
    if (!_productidMArr) {
        _productidMArr = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _productidMArr;
}



- (NSMutableDictionary *)infoMDict{

    _infoMDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    [_infoMDict setValue:@"qmp_ios" forKey:@"ptype"];
    [_infoMDict setValue:VERSION forKey:@"version"];
    NSString *unionid = [[NSUserDefaults standardUserDefaults] objectForKey:@"unionid"];
    [_infoMDict setValue:(unionid?unionid:@"") forKey:@"unionid"];

    return _infoMDict;
}

@end
