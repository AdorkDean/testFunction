
//
//  CardEditingViewController.m
//  qmp_ios
//
//  Created by Molly on 16/9/27.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import "CardEditingViewController.h"
#import "CardEditingTableViewCell.h"
#import <IQKeyboardManager.h>
#import "UIImageView+WebCache.h"

#import "TakeImageTool.h"
#import "SearchDetailViewController.h"
#import "CardScanView.h"

#import "ShareTo.h"
@interface CardEditingViewController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,UITextFieldDelegate>{

    NSString *fullPath;
    UIImage *_backImg;
    TakeImageTool *_takeImgTool;
    BOOL isEditing;
    UIButton *_rightBarButton;
    
    UIScrollView *_firstScrollV;
    UIScrollView *_secondScrollV;
    
    UIImageView *_firstImgV;
    UIImageView *_secondImgV;
    CGFloat lastContentOffsetX;
    
}

@property (strong, nonatomic)  NSArray *sectionTitles;

@property (strong, nonatomic)  UIButton *headerBtn;
@property (strong, nonatomic)  UITapGestureRecognizer *tap;
@property (strong, nonatomic)  UIScrollView *tableHeaderV;
@property (strong, nonatomic)  UIPageControl *pageControl;

@property (strong, nonatomic)  CardScanView *cardScanView;

@property (strong, nonatomic)  UIView *footView;
@property (strong, nonatomic)  UIButton *backAddBtn;

@property(nonatomic,strong)UIView *cardScanToolBar;


@end

@implementation CardEditingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _takeImgTool = [[TakeImageTool alloc]init];
    self.title = @"编辑信息";
    [self addView];
    
    
    if (self.isUpload) {
        _firstImgV.image = self.image;
        isEditing = YES;
        
        [_secondImgV addSubview:self.backAddBtn];
        self.backAddBtn.center = _secondImgV.center;
    
    }else{
        
        self.title = @"人脉详情";
        isEditing = NO;
        [_firstImgV  sd_setImageWithURL:[NSURL URLWithString:self.card.imgUrl] placeholderImage:[UIImage imageFromColor:TABLEVIEW_COLOR andSize:_firstImgV.size]];
        if (self.card.back_flag) {
            [_secondImgV  sd_setImageWithURL:[NSURL URLWithString:self.card.backImgUrl] placeholderImage:[UIImage imageFromColor:TABLEVIEW_COLOR andSize:_firstImgV.size]];
        
        }else{
            [_secondImgV addSubview:self.backAddBtn];
            self.backAddBtn.center = _secondImgV.center;
        }
    }
    
    [self buildBarButtonItem];

    if (self.isUpload) { //新名片，汉王识别
        
        [PublicTool showHudWithView:KEYWindow];
        
        [[NetworkManager sharedMgr] scanCardApiWithImage:self.image resultDic:^(NSDictionary *resultDic) {
          
            [PublicTool dismissHud:KEYWindow];
            
            if (resultDic) {

                QMPLog(@"名片=-------------%@",resultDic);
                CardItem *card = [[CardItem alloc]init];
                [card setValuesForKeysWithDictionary:resultDic];
                self.card = card;
               
                [self.tableView reloadData];
            }
    
        }];
        
    }
    
}

- (void)addView{
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH-kScreenTopHeight) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.tableView registerNib:[UINib nibWithNibName:@"CardEditingTableViewCell" bundle:nil] forCellReuseIdentifier:@"CardEditingTableViewCellID"];
    [self.view addSubview:self.tableView];
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    
    UIView *headerView = [[UIView alloc]initWithFrame:self.tableHeaderV.bounds];
    [headerView addSubview:self.tableHeaderV];
    [headerView addSubview:self.pageControl];
    self.pageControl.bottom = headerView.height - 5;
    self.pageControl.centerX = headerView.width/2.0;
    self.tableView.tableHeaderView = headerView;
    
    
}

- (void)handerBtnClick{
    
    [self.view endEditing:YES];

    [_takeImgTool alertPhotoAction:^(UIImage *image, NSData *imgData) {
        
        [PublicTool showHudWithView:KEYWindow];
        
        //修改,或者新建保存过
        if(!self.isUpload  || (self.isUpload && ![PublicTool isNull:self.card.cardId])){
            
            NSMutableDictionary *mDict = [[NSMutableDictionary alloc] initWithCapacity:0];
            [mDict setValue:[NSString stringWithString:self.card.cardId] forKey:@"card_id"];

            [[NetworkManager sharedMgr]uploadUrl:QMPImageUpLoadURL image:image progress:nil uploadFinished:^(NSURLSessionDataTask *dataTask, NSString *fileUrl) {
                if (![PublicTool isNull:fileUrl]) {
                    [mDict setValue:fileUrl forKey:@"web_url"];
                    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:QMPUserAddCardBack HTTPBody:mDict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
                        [PublicTool dismissHud:KEYWindow];
                        if (resultData && [resultData[@"status"] integerValue] == 0) {
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"AddCardBackSuccess" object:self.card];
                            _backImg = image;
                            [self.backAddBtn removeFromSuperview];
                            [self refreshTableHeaderView];
                            [self.tableHeaderV setContentOffset:CGPointMake(SCREENW, 0)];
                        }else{
                            [PublicTool showMsg:@"上传失败"];
                        }
                    }];
                }else{
                    [PublicTool dismissHud:KEYWindow];
                    [PublicTool showMsg:@"上传失败"];
                }
            }];
 
        }else if(self.isUpload && [PublicTool isNull:self.card.cardId]){ //新建名片，没保存过
            [PublicTool dismissHud:KEYWindow];
            _backImg = image;
            [self.backAddBtn removeFromSuperview];
            [self refreshTableHeaderView];
        }
        
    }];
}

- (void)refreshTableHeaderView{
    self.headerBtn.hidden = YES;
    _secondImgV.image = _backImg;
    self.tableHeaderV.contentSize = CGSizeMake(SCREENW*2, self.tableHeaderV.height);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}



- (void)refreshLeftBarbutton{
    
    if (isEditing) {
        self.navigationItem.leftBarButtonItems = [self createCancleButton];
        self.tableView.tableFooterView = self.footView;

    }else{
        self.navigationItem.leftBarButtonItems = [self createBackButton];
        self.tableView.tableFooterView = nil;

    }
    if (isEditing) {
        self.title = @"编辑信息";
    }else{
        self.title = @"人脉详情";
    }
}

#pragma mark --请求新建名片--
- (void)requesetUploadImg{
    
    [PublicTool showHudWithView:KEYWindow];
    __block NSString *card_url = @"";
    __block NSString *back_url = @"";
    
    [[NetworkManager sharedMgr] uploadUrl:QMPImageUpLoadURL image:self.image progress:nil uploadFinished:^(NSURLSessionDataTask *dataTask, NSString *fileUrl) {
        
        if ([PublicTool isNull:fileUrl]) {
            [PublicTool dismissHud:KEYWindow];
            [PublicTool showMsg:@"上传失败"];
        }else{
            card_url = fileUrl;
            if (_backImg) {
                [[NetworkManager sharedMgr] uploadUrl:QMPImageUpLoadURL image:self.image progress:nil uploadFinished:^(NSURLSessionDataTask *dataTask, NSString *fileUrl) {
                    if ([PublicTool isNull:fileUrl]) {
                        [PublicTool dismissHud:KEYWindow];
                        [PublicTool showMsg:@"上传失败"];
                    }else{
                        back_url = fileUrl;
                        [self saveCardInfo:card_url backUrl:back_url];
                    }
                }];
            }else{
                [self saveCardInfo:card_url backUrl:nil];
            }
        }
    }];
    
    
}

- (void)saveCardInfo:(NSString*)cardUrl backUrl:(NSString*)backUrl{
    
    NSMutableDictionary *mDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    [mDict setValue:self.card.cardName?self.card.cardName:@"" forKey:@"name"];
    [mDict setValue:self.card.phone?self.card.phone:@"" forKey:@"phone"];
    [mDict setValue:self.card.zhiwu?self.card.zhiwu:@"" forKey:@"zhiwu"];
    [mDict setValue:self.card.email?self.card.email:@"" forKey:@"email"];
    [mDict setValue:self.card.company?self.card.company:@"" forKey:@"company"];
    [mDict setValue:self.card.wechat?self.card.wechat:@"" forKey:@"wechat"];
    [mDict setValue:cardUrl  forKey:@"web_url"];
    if (![PublicTool isNull:backUrl]) {
        [mDict setValue:backUrl  forKey:@"back"];
    }
    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:QMPUserAddCard HTTPBody:mDict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        [PublicTool dismissHud:KEYWindow];
        if (resultData && [resultData[@"msg"] isEqualToString:@"success"]) {
            self.card.cardId = resultData[@"card_id"];
            self.card.imgUrl = cardUrl;
            self.card.backImgUrl = backUrl;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"CardInfoUpdateSuccess" object:self.card];
            
            isEditing = NO;
            [self.tableView reloadData];
            [self refreshLeftBarbutton];
            [_rightBarButton setTitle:@"编辑" forState:UIControlStateNormal];
            
            [PublicTool showMsg:@"保存成功"];
        }else{
            [PublicTool showMsg:@"保存失败"];
        }
       
    }];
}


#pragma mark - 请求修改card内容
- (void)requestUpdateCard{
    
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionaryWithDictionary:@{@"card_id":self.card.cardId}];
    
    [requestDict setValue:self.card.cardName?self.card.cardName:@"" forKey:@"name"];
    [requestDict setValue:self.card.phone?self.card.phone:@"" forKey:@"phone"];
    [requestDict setValue:self.card.zhiwu?self.card.zhiwu:@"" forKey:@"zhiwu"];
    [requestDict setValue:self.card.email?self.card.email:@"" forKey:@"email"];
    [requestDict setValue:self.card.company?self.card.company:@"" forKey:@"company"];
    [requestDict setValue:self.card.wechat?self.card.wechat:@"" forKey:@"wechat"];
    
    
    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:QMPUserEditCard HTTPBody:requestDict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        if ([resultData[@"status"] integerValue] == 0) {
            [PublicTool showMsg:@"保存成功"];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"CardInfoUpdateSuccess" object:self.card];
            
            isEditing = NO;
            [self.tableView reloadData];
            [self refreshLeftBarbutton];
            [_rightBarButton setTitle:@"编辑" forState:UIControlStateNormal];
        }else{
            
        }
    }];
    
}

#pragma mark - tableView

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 10)];
    headerV.backgroundColor = TABLEVIEW_COLOR;
    return headerV;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

//    return 5;
    return 6;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 50;
    
    return 0.1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    static NSString *cellIdentifier = @"CardEditingTableViewCellID";
    CardEditingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.infoTextField.tag = indexPath.row + 1000;;
    NSString *secTitle = self.sectionTitles[indexPath.row];
    if ([secTitle isEqualToString:@"姓名"]) {
        cell.infoLbl.text = @"姓名";
        cell.infoTextField.text = self.card.cardName? self.card.cardName : @"";
        cell.infoTextField.textColor = NV_TITLE_COLOR;

    }else  if ([secTitle isEqualToString:@"公司"]) {
        cell.infoLbl.text = @"公司";
        cell.infoTextField.text = [PublicTool isNull:self.card.company] ? @"-":self.card.company;
        cell.infoTextField.textColor = BLUE_TITLE_COLOR;

    }else  if ([secTitle isEqualToString:@"职位"]) {
        cell.infoLbl.text = @"职位";
        cell.infoTextField.text = self.card.zhiwu ? self.card.zhiwu : @"";
        cell.infoTextField.textColor = NV_TITLE_COLOR;

    }else  if ([secTitle isEqualToString:@"电话"]) {
        cell.infoLbl.text = @"电话";
        cell.infoTextField.text = self.card.phone? self.card.phone : @"";
        cell.infoTextField.textColor = BLUE_TITLE_COLOR;
    }else  if ([secTitle isEqualToString:@"微信"]) {
        cell.infoLbl.text = @"微信";
        cell.infoTextField.text = self.card.wechat? self.card.wechat : @"";
        cell.infoTextField.textColor = BLUE_TITLE_COLOR;

    }else  if ([secTitle isEqualToString:@"邮箱"]) {
        cell.infoLbl.text = @"邮箱";
        cell.infoTextField.text = self.card.email? self.card.email : @"";
        cell.infoTextField.textColor = BLUE_TITLE_COLOR;
    }
    
    cell.infoTextField.delegate = self;
    cell.rightButton.hidden = YES;
    
    if (isEditing) {
        cell.infoTextField.textColor = NV_TITLE_COLOR;
        if (indexPath.row == self.sectionTitles.count-1) {
            cell.infoTextField.returnKeyType = UIReturnKeyDone;
        }else{
            cell.infoTextField.returnKeyType = UIReturnKeyNext;

        }
        cell.infoTextField.userInteractionEnabled = YES;
    }else{
        cell.infoTextField.userInteractionEnabled = NO;
    }
    return cell;
   
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (isEditing) {
        return;
    }
    
    NSString *secTitle = self.sectionTitles[indexPath.row];

    if ([secTitle isEqualToString:@"公司"] && ![PublicTool isNull:self.card.company]) {
        [self tapCompanyTextView];
    }else  if ([secTitle isEqualToString:@"电话"]&& ![PublicTool isNull:self.card.phone]) {
        [PublicTool dealPhone:self.card.phone];
    }else  if ([secTitle isEqualToString:@"微信"] && ![PublicTool isNull:self.card.wechat]) {
        [PublicTool dealWechat:self.card.wechat];

    }else  if ([secTitle isEqualToString:@"邮箱"] && ![PublicTool isNull:self.card.email]) {
        [PublicTool dealEmail:self.card.email];

    }
}
- (void)tapCompanyTextView{

    NSString *company = self.card.company;
    
    SearchDetailViewController *searchVC = [[SearchDetailViewController alloc]init];
    searchVC.searchString = company;
    [self.navigationController pushViewController:searchVC animated:YES];

}


#pragma mark - public
//点击图片
- (void)tapCardImgV{
    
    if (isEditing) {
        [self.view endEditing:YES];
        return;
    }

    
    if (_backImg || ![PublicTool isNull:self.card.backImgUrl]) {
        if (_backImg) {
            self.cardScanView.imgArr = @[_firstImgV.image,_backImg];
        }else{
            self.cardScanView.imgArr = @[_firstImgV.image,self.card.backImgUrl];

        }
        [self.cardScanView setContentOffset:self.tableHeaderV.contentOffset];
        [KEYWindow addSubview:self.cardScanView];
        [KEYWindow addSubview:self.cardScanToolBar];
        return;
        
    }else{
        
        if (self.tableHeaderV.contentOffset.x >= 50) { //反面无图 点击
            return;
        }
    }
    
    self.cardScanView.imgArr = @[_firstImgV.image];
    [self.cardScanView setContentOffset:CGPointMake(0, 0)];

    [KEYWindow addSubview:self.cardScanView];
    [KEYWindow addSubview:self.cardScanToolBar];
}
- (void)buildBarButtonItem{
    
    if (self.isUpload) { //leftBarbutton 取消
         self.navigationItem.leftBarButtonItems = [self createCancleButton];
        self.tableView.tableFooterView = self.footView;
    }else{
        self.navigationItem.leftBarButtonItems = [self createBackButton];
    }
    
    
    UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 47.f, 20.f)];
    if (self.isUpload) {
        [rightBtn setTitle:@"保存" forState:UIControlStateNormal];

    }else{
        [rightBtn setTitle:@"编辑" forState:UIControlStateNormal];

    }
    rightBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:15.f];
    [rightBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(pressSaveBarBtn:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = item;
    
    _rightBarButton = rightBtn;
    
}

- (NSArray*)createBackButton{
    
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
    [leftButton setImage:[UIImage imageNamed:@"left-arrow"] forState:UIControlStateNormal];
    //    [leftButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [leftButton addTarget:self action:@selector(popSelf) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = LEFTNVSPACE;
    if (iOS11_OR_HIGHER) {
        //        leftButton.width = 30;
        leftButton.contentEdgeInsets = UIEdgeInsetsMake(0, -40, 0, 0);
        //        leftButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
        
        return @[leftButtonItem];
    }
    return @[negativeSpacer,leftButtonItem];

}


- (NSArray*)createCancleButton{
    
    UIButton *leftButton = [[UIButton alloc] initWithFrame:LEFTBUTTONFRAME];
    [leftButton setTitle:@"取消" forState:UIControlStateNormal];
    [leftButton setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
    leftButton.titleLabel.font = [UIFont systemFontOfSize:15.f];
    
    [leftButton addTarget:self action:@selector(cancelAddCard) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = LEFTNVSPACE;

    if (iOS11_OR_HIGHER) {
        leftButton.width = 40;
        leftButton.contentEdgeInsets = UIEdgeInsetsMake(0, -3, 0, 0);
        leftButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
        
        return @[leftButtonItem];
    }
    
    return @[leftButtonItem];
}

- (void)popSelf{
    
    [self.view endEditing:YES];

    [self.navigationController popViewControllerAnimated:YES];
}

- (void)pressSaveBarBtn:(id)sender{

    [self.view endEditing:YES];
    
    //添加新名片   更新旧名片
    if (self.isUpload && [PublicTool isNull:self.card.cardId]) { //新增 没保存过
        
        [self requesetUploadImg];
        
    }else{
        
        UIButton *btn = (UIButton*)sender;
        if ([btn.titleLabel.text isEqualToString:@"编辑"]) {
            isEditing = YES;
            [self refreshLeftBarbutton];
            [btn setTitle:@"保存" forState:UIControlStateNormal];
            [self.tableView reloadData];
            
        }else{
            isEditing = NO;
            
            [self requestUpdateCard];

        }

    }
    
}


- (void)cancelAddCard{
    
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];

//
//    [PublicTool alertActionWithTitle:@"提示" message:@"是否放弃此次添加图片" leftTitle:@"放弃" rightTitle:@"继续编辑" leftAction:^{
//        [self.navigationController popViewControllerAnimated:YES];
//
//    } rightAction:^{
//
//    }];
}




#pragma mark --UIScrollViewDelegate--

- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    
    if (scrollView == _firstScrollV || scrollView == _secondScrollV) {
       
        for (UIImageView *imgV in scrollView.subviews) {
            if ([imgV isKindOfClass:[UIImageView class]]) {
                return imgV;
            }
        }
    }
    
    return nil;
}

-(void)scrollViewDidZoom:(UIScrollView *)scrollView{
    if (scrollView == _firstScrollV || scrollView == _secondScrollV) {
        
        CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
        (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
        CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
        (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
        
        if (scrollView == _firstScrollV) {
            _firstImgV.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                            scrollView.contentSize.height * 0.5 + offsetY);
        }else{
            _secondImgV.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                             scrollView.contentSize.height * 0.5 + offsetY);
        }
    }
   
    
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{
    if (scrollView == _firstScrollV || scrollView == _secondScrollV) {
        [scrollView setZoomScale:scale animated:NO];
    }
}


-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    if (scrollView == self.cardScanView) {
        
        [self.cardScanView refreshSubViews];
        
    }else if(scrollView == _tableHeaderV){
        
        if (lastContentOffsetX == _tableHeaderV.contentOffset.x) {
            return;
            
        }else if(_tableHeaderV.contentOffset.x == 0 || _tableHeaderV.contentOffset.x == SCREENW){ //滑动结束
            [_firstScrollV setZoomScale:1 animated:YES];
            [_secondScrollV setZoomScale:1 animated:YES];
        }
        lastContentOffsetX = _tableHeaderV.contentOffset.x;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(scrollView == _tableHeaderV){
        
        NSInteger index = (scrollView.contentOffset.x + SCREENW/2.0)/SCREENW;
        self.pageControl.currentPage = index;
    }
}


- (void)pageControlValueChanged:(UIPageControl*)pageCon{
    [self.tableHeaderV setContentOffset:CGPointMake(pageCon.currentPage *SCREENW, 0)];
}



- (void)recordInputText:(UITextField *)textField{
    _sectionTitles = @[@"姓名",@"公司",@"职位",@"电话",@"微信",@"邮箱"];

   switch (textField.tag - 1000) {
        case 0:{
            self.card.cardName = textField.text;
            break;
        }
        case 1:{
            self.card.company = textField.text;
            break;
        }
        case 2:{
            self.card.zhiwu = textField.text;
            break;
        }
        case 3:{
            self.card.phone = textField.text;
            break;
        }
        case 4:{
            self.card.wechat = textField.text;
            break;
        }
       case 5:{
           self.card.email = textField.text;
           break;
       }
        default:
            break;
    }
    
}


#pragma mark --UITextFieldDelegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (isEditing == YES) {
        return YES;
    }
    
    
    if ([PublicTool isNull:textField.text]) {
        return NO;
    }
    
    switch (textField.tag - 1000) {
        case 0:{
            break;
        }
        case 1:{ //打电话
            [PublicTool makeACall:textField.text];
            break;
        }
        case 2:{  //公司
            
            SearchDetailViewController *searchVC = [[SearchDetailViewController alloc]init];
            searchVC.searchString = textField.text;
            [self.navigationController pushViewController:searchVC animated:YES];
            break;
        }
        case 4:{
            [PublicTool sendEmail:textField.text];
            break;
        }
            
        default:
            break;
    }
    
    return NO;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ([string isEqualToString:@"\n"]) { //下一步
        //        UITableViewCell *cell = (UITableViewCell*)textField.superview.superview;
        //        NSInteger row = [self.tableView indexPathForCell:cell].row;
        NSInteger row = textField.tag - 1000;
        
        if (row == 6) {
            [self.view endEditing:YES];
            return YES;
        }
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row+1 inSection:0];
        CardEditingTableViewCell *nextCell = [self.tableView cellForRowAtIndexPath:indexPath];
        [nextCell.infoTextField becomeFirstResponder];
        return NO;
        
    }
    
    [self recordInputText:textField];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    [self recordInputText:textField];
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    [self recordInputText:textField];
//    return YES;
}




-(BOOL)prefersStatusBarHidden{
    return NO;
}

- (void)cardScanViewHide {
    [self.cardScanToolBar removeFromSuperview];
    [self.cardScanView removeFromSuperview];
}
- (void)saveCardButtonClick {
    if (self.cardScanView.contentOffset.x > 0) {
        UIImageWriteToSavedPhotosAlbum(_secondImgV.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        return;
    }
    UIImageWriteToSavedPhotosAlbum(_firstImgV.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}
- (void)shareCardButtonClick {
    if (self.cardScanView.contentOffset.x > 0) {
        [self.shareTool shareImgToOtherApp: _secondImgV.image];
        return;
    }
    [self.shareTool shareImgToOtherApp: _firstImgV.image];
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    [PublicTool showMsg:@"保存成功"];
}
#pragma mark - 懒加载
-(UITapGestureRecognizer *)tap{
    if (!_tap) {
        _tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapCompanyTextView:)];
    }
    return _tap;
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    
    return UIStatusBarStyleDefault;
}

-(UIScrollView *)tableHeaderV{
    if (!_tableHeaderV) {
        _tableHeaderV = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, SCREENW/375*209)];
        _tableHeaderV.bounces = NO;
        _tableHeaderV.delegate = self;
        _tableHeaderV.pagingEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapCardImgV)];
        [_tableHeaderV addGestureRecognizer:tap];
       
        UIScrollView *scrollV = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, SCREENW/375*209)];
        scrollV.showsHorizontalScrollIndicator = NO;
        scrollV.delegate = self;
        scrollV.maximumZoomScale = 2;
        scrollV.minimumZoomScale = 1;
        [_tableHeaderV addSubview:scrollV];
        
        UIScrollView *scrollV2 = [[UIScrollView alloc]initWithFrame:CGRectMake(SCREENW, 0, SCREENW, SCREENW/375*209)];
        scrollV2.showsHorizontalScrollIndicator = NO;
        scrollV2.maximumZoomScale = 2;
        scrollV2.minimumZoomScale = 1;
        scrollV2.delegate = self;
        [_tableHeaderV addSubview:scrollV2];
        _firstScrollV = scrollV;
        _secondScrollV = scrollV2;
        
        _firstImgV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, _tableHeaderV.width, _tableHeaderV.height)];
        [scrollV addSubview:_firstImgV];
        _firstImgV.contentMode = UIViewContentModeScaleAspectFit;
        _firstImgV.userInteractionEnabled = YES;

        _secondImgV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, _tableHeaderV.width, _tableHeaderV.height)];
        [scrollV2 addSubview:_secondImgV];
        _secondImgV.contentMode = UIViewContentModeScaleAspectFit;
        _secondImgV.userInteractionEnabled = YES;

        _tableHeaderV.contentSize = CGSizeMake(SCREENW*2, _tableHeaderV.height);
       
        
    }
    return _tableHeaderV;
}

-(UIPageControl *)pageControl{
    if (!_pageControl) {
        _pageControl =[[ UIPageControl alloc]initWithFrame:CGRectMake(0, SCREENW/375*209-10, 100, 30)];
        _pageControl.numberOfPages = 2;
        _pageControl.pageIndicatorTintColor = [RGBBlueColor colorWithAlphaComponent:0.3];
        _pageControl.currentPageIndicatorTintColor = RGBBlueColor;
        [_pageControl addTarget:self action:@selector(pageControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _pageControl;
    
}


-(CardScanView *)cardScanView{
    if (!_cardScanView) {
        _cardScanView = [[CardScanView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH)];
        _cardScanView.delegate = self;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(cardScanViewHide)];
        [_cardScanView addGestureRecognizer:tap];
    }
    return _cardScanView;
}
- (UIView *)cardScanToolBar {
    if (!_cardScanToolBar) {
        _cardScanToolBar = [[UIView alloc] initWithFrame:CGRectMake(0, SCREENH-kScreenBottomHeight, SCREENW, kScreenBottomHeight)];
        _cardScanToolBar.backgroundColor = [UIColor whiteColor];
        
        UIButton *saveCardButton = [[UIButton alloc] init];
        saveCardButton.frame = CGRectMake(0, 0, SCREENW/2.0, 49);
        saveCardButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [saveCardButton setTitle:@"保存" forState:UIControlStateNormal];
        [saveCardButton setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
        [saveCardButton addTarget:self action:@selector(saveCardButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [_cardScanToolBar addSubview:saveCardButton];
        
        UIButton *shareCardButton = [[UIButton alloc] init];
        shareCardButton.frame = CGRectMake(SCREENW/2.0, 0, SCREENW/2.0, 49);
        shareCardButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [shareCardButton setTitle:@"分享" forState:UIControlStateNormal];
        [shareCardButton setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
        [shareCardButton addTarget:self action:@selector(shareCardButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [_cardScanToolBar addSubview:shareCardButton];
        
        UIImageView *line = [[UIImageView alloc] init];
        line.frame = CGRectMake(SCREENW/2.0-0.25, 2, 0.5, 49-4);
        line.backgroundColor = HTColorFromRGB(0xe2e4e8);
        [_cardScanToolBar addSubview:line];
        
    }
    return _cardScanToolBar;
}

-(UIView *)footView{
    
    if (!_footView) {
        CGFloat height = SCREENW > 375 ? 250:300;
        _footView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, height)];
        
    }
    return _footView;
}

-(UIButton *)backAddBtn{
    
    if (!_backAddBtn) {
        _backAddBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 106, 66)];
        [_backAddBtn setImage:[UIImage imageNamed:@"card_back"] forState:UIControlStateNormal];
        [_backAddBtn addTarget:self action:@selector(handerBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backAddBtn;
}

- (NSArray*)sectionTitles{
    if (!_sectionTitles) {
        _sectionTitles = @[@"姓名",@"公司",@"职位",@"电话",@"微信",@"邮箱"];
    }
    return _sectionTitles;
}
@end
