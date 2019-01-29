//
//  GetProductsFromTagsViewController.m
//  qmp_ios
//
//  Created by qimingpian10 on 2016/12/9.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import "GetProductsFromTagsViewController.h"
#import "StarProductsModel.h"
#import "StarProductsTableViewCell.h"


#define FEEDBACKBUTTONFRAME CGRectMake(8, 11.5, 20, 21)
@interface GetProductsFromTagsViewController ()<UITableViewDataSource,UITableViewDelegate,ShareDelegate>{
  
    UILabel *titleLbl;
}
@property (strong, nonatomic) NSMutableArray *tagProMArr;
@property (strong, nonatomic) NSMutableDictionary *paramsDic;
@property (strong, nonatomic) NSMutableDictionary *tagProMdict;
@property (strong, nonatomic) UIImage *printscreenShortImage;

@end

@implementation GetProductsFromTagsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.numPerPage = 20;
    self.currentPage = 1;
    [self buildRightBarButtonItem];
     self.title = ![PublicTool isNull:self.urlDict[@"tag"]]?self.urlDict[@"tag"]:@"";
    [self showHUD];
    [self requestGetProductsFromTags:self.paramsDic];
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

//        [self.shareTool shareImgToOtherApp:_printscreenShortImage];
    }
}
- (void)buildRightBarButtonItem{

    UIButton * captureScreenBtn = [[UIButton alloc] initWithFrame:RIGHTBARBTNFRAME];
    [captureScreenBtn setImage:[UIImage imageNamed:@"screen_capture_gray"] forState:UIControlStateNormal];
    [captureScreenBtn setImage:[UIImage imageNamed:@"screen_capture_gray"] forState:UIControlStateHighlighted];
    [captureScreenBtn addTarget:self action:@selector(imageWithShortScreenshot) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * captureScreenItem = [[UIBarButtonItem alloc]initWithCustomView:captureScreenBtn];
//    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = RIGHTNVSPACE;
    if (iOS11_OR_HIGHER) {
        
        captureScreenBtn.width = 30;
        captureScreenBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:captureScreenBtn];
        
        self.navigationItem.rightBarButtonItems = @[buttonItem];
        
    }else{
        self.navigationItem.rightBarButtonItems = @[ negativeSpacer,captureScreenItem];
    }
}

- (void)initTableView{
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH-kScreenTopHeight) style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = TABLEVIEW_COLOR;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;//设置cell的分割线为无
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    if (self.tagProMArr.count>0) {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
       
        self.tableView.mj_footer = self.mjFooter;
        
        self.tableView.mj_header = self.mjHeader;
    }
    
    [self.view addSubview:self.tableView];
}

- (void)pullDown{ //下拉
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:self.paramsDic];
    [dic setValue:@"1" forKey:@"debug"];
    
    if (self.tableView.mj_footer.state == MJRefreshStateNoMoreData) {
        [self.tableView.mj_footer resetNoMoreData];
    }
    self.currentPage = 1;
    [self requestGetProductsFromTags:dic];
    
}

- (void)pullUp{
    
    self.currentPage ++;
    [self requestGetProductsFromTags:self.paramsDic];
}

- (void)requestGetProductsFromTags:(NSDictionary *)dict{
   
    //判断网络连接状态
    if (![TestNetWorkReached networkIsReached:self]) {
        [self hideHUD];
        [self.tableView.mj_footer endRefreshing];
        [self.tableView.mj_header endRefreshing];
    }else{
        
        NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithDictionary:dict];
        [mDict setValue:@"orderbytag" forKey:@"order"];
        [mDict setValue:[NSString stringWithFormat:@"%ld",(long)self.currentPage] forKey:@"curpage"];
        [mDict setValue:[NSString stringWithFormat:@"%ld",(long)self.numPerPage] forKey:@"num"];

        NSString *action = @"";
        if (_isMatchTag) {
            action = @"d/getProByTag";
        }else{
            action = @"d/getProByUnMatchTag";
        }
        
        [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:action HTTPBody:mDict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
           
            [self hideHUD];
            [self.tableView.mj_header endRefreshing];
            [self.tableView.mj_footer endRefreshing];
            
            NSMutableArray *retMArr = [[NSMutableArray alloc] initWithCapacity:0];
            if (resultData && [resultData isKindOfClass:[NSDictionary class]]) {
                
                _tagProMdict = [NSMutableDictionary dictionaryWithDictionary:resultData];
                
                NSMutableArray *dataMarr = _tagProMdict[@"list"];
                if (dataMarr.count>0) {
                    for (NSDictionary *dataDict in dataMarr) {
                        StarProductsModel *starPModel = [[StarProductsModel alloc] init];
                        [starPModel setValuesForKeysWithDictionary:dataDict];
                        [retMArr addObject:starPModel];
                    }
                }
            }
            
            //分页
            if (self.currentPage == 1) {
                
                self.tagProMArr = retMArr;
            }else{
                
                for (StarProductsModel *model in retMArr) {
                    
                    [self.tagProMArr addObject:model];
                }
                
            }
            
            if (!self.tableView) {
                [self initTableView];
            }
            [self refreshFooter:retMArr];

            [self.tableView reloadData];
            
        }];
    }
}

#pragma mark - UITableView
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    if(section == 0){
        return 5.f;
    }
    else{
        return 5.0f;
    }
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [[UIView alloc]init];
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc]init];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.tagProMArr.count == 0) {
        return 1;
    }
    else{
        return self.tagProMArr.count;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.tagProMArr.count == 0) {
        return SCREENH - kScreenTopHeight;
    }
    else{
        return 80;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.tagProMArr.count > 0 ) {
        StarProductsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        if (!cell) {
            cell = [[StarProductsTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.bottomLine.hidden = YES;
        if (self.tagProMArr.count>0) {
            StarProductsModel *model = self.tagProMArr[indexPath.section];
            [cell refreshUI:model];
        }
        cell.contactBtn.hidden = YES;

        return cell;
    }
    else{
        return [self nodataCellWithInfo:REQUEST_DATA_NULL tableView:tableView];
    
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.tagProMArr.count > 0 ) {
        StarProductsModel *model = self.tagProMArr[indexPath.section];
        if (model.detail) {
            [[AppPageSkipTool shared] appPageSkipToProductDetail:[PublicTool toGetDictFromStr:model.detail]];

        }
    }
}


#pragma mark - 懒加载
- (NSMutableArray *)tagProMArr{
    if (!_tagProMArr) {
        _tagProMArr  = [NSMutableArray arrayWithCapacity:0];
    }
    return _tagProMArr;
}

- (NSMutableDictionary *)paramsDic{
    if (!_paramsDic) {
        _paramsDic = [NSMutableDictionary dictionaryWithDictionary:self.urlDict];
        self.currentPage = 1;
        [_paramsDic setValue:[NSString stringWithFormat:@"%ld",(long)self.currentPage] forKey:@"curpage"];
        [_paramsDic setValue:@"20" forKey:@"num"];
    }else{
        [_paramsDic setValue:_urlDict[@"tag"] forKey:@"tag"];
    }
    return _paramsDic;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
