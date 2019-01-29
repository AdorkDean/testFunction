
//
//  RegisterInfoViewController.m
//  qmp_ios
//
//  Created by qimingpian10 on 2016/12/10.
//  Copyright © 2016年 Molly. All rights reserved.
//

#import "RegisterInfoViewController.h"

#import "CompanysDetailRegisterInfoCell.h"
#import "CompanysDetailRegisterGudongCell.h"
#import "CompanysDetailRegisterGudongModel.h"
#import "CompanysDetailRegisterTouziCell.h"
#import "CompanysDetailRegisterTouziModel.h"
#import "CompanysDetailRegisterPeoplesModel.h"
#import "CompanysDetailRegisterPeoplesCell.h"
#import "CompanyBasicInfoTableViewCell.h"
#import "CompanysDetailRegisterChangeRecordsModel.h"
#import "CompanysDetailRegisterChangeRecordsCell.h"
#import "CustomAlertView.h"
#import "AboutTableViewCell.h"
#import "CompanyIcpListViewController.h"
#import "CompanyIcpTableViewCell.h"
#import "URLModel.h"
#import "PersonModel.h"
#import "CompanyIcpModel.h"

#import <objc/runtime.h>
#import "URLModel.h"
#import "DataHandle.h"
#import "NewsWebViewController.h"
#import "GetSizeWithText.h"
#import "PersonAllBusinessRoleController.h"
#import "RegisterInfoViewModel.h"

@interface RegisterInfoViewController () <UITableViewDelegate, UITableViewDataSource, DataHandleDelegate, ShareDelegate>
@property (nonatomic, strong) UIImage *printscreenImage;
@property (nonatomic, strong) ShareTo *shareToTool;
@property (nonatomic, strong) RegisterInfoViewModel *viewModel;

@end

@implementation RegisterInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupNavBar];
    [self initTableView];
    [self initToolView];
    [self showHUD];
    
    [self requestRegisterInfo];
    [QMPEvent event:@"gs_detail_enter"];
}
- (void)setupNavBar {
    self.navigationItem.title = @"工商信息";
    UIButton * captureScreenBtn = [[UIButton alloc] initWithFrame:RIGHTBARBTNFRAME];
    [captureScreenBtn setImage:[BundleTool imageNamed:@"screen_capture_gray"] forState:UIControlStateNormal];
    [captureScreenBtn setImage:[BundleTool imageNamed:@"screen_capture_gray"] forState:UIControlStateHighlighted];
    [captureScreenBtn addTarget:self action:@selector(getCapture) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * captureScreenItem = [[UIBarButtonItem alloc]initWithCustomView:captureScreenBtn];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = RIGHTNVSPACE;
    if (iOS11_OR_HIGHER) {
        captureScreenBtn.width = 30;
        captureScreenBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:captureScreenBtn];
        self.navigationItem.rightBarButtonItems = @[buttonItem];
    } else {
        self.navigationItem.rightBarButtonItems = @[ negativeSpacer,captureScreenItem];
    }
}
- (void)initTableView {
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH - kScreenTopHeight - 44.f) style:UITableViewStyleGrouped];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate = self;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = TABLEVIEW_COLOR;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.mj_header = self.mjHeader;
    [self.tableView registerClass:[CompanysDetailRegisterChangeRecordsCell class] forCellReuseIdentifier:@"CompanysDetailRegisterChangeRecordsCell"];
    [self.view addSubview:self.tableView];
    
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
}
- (void)initToolView {
    
    UIView *toolView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREENH - kScreenBottomHeight - kScreenTopHeight, SCREENW, kScreenBottomHeight)];
    toolView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:toolView];
    
    UIView *lineV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, 0.5f)];
    lineV.backgroundColor = LIST_LINE_COLOR;
    [toolView addSubview:lineV];
    
    CGFloat fontSize = 14.f;
    UIButton *aboveCollectBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SCREENW/2.0, kShortBottomHeight)];
    [aboveCollectBtn layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleLeft imageTitleSpace:7];
    [aboveCollectBtn buttonWithTitle:@"回首页" image:@"gohome_gray" titleColor:H5COLOR fontSize:fontSize];
    [aboveCollectBtn addTarget:self action:@selector(goHome) forControlEvents:UIControlEventTouchUpInside];
    [toolView addSubview:aboveCollectBtn];
    
    UIButton *feedbackToolBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREENW/2.0, 0, SCREENW/2.0, kShortBottomHeight)];
    [feedbackToolBtn layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleLeft imageTitleSpace:7];
    [feedbackToolBtn buttonWithTitle:@"反馈" image:@"feedback-group" titleColor:H5COLOR fontSize:fontSize];
    [feedbackToolBtn addTarget:self action:@selector(requestImmediateFeedback) forControlEvents:UIControlEventTouchUpInside];
    [toolView addSubview:feedbackToolBtn];
}

#pragma mark - ShareDelegate
- (void)shareSuccess {
    _printscreenImage = nil;
    [ShowInfo showInfoOnView:self.view withInfo:@"分享成功"];
}
- (void)shareFaild {
    _printscreenImage = nil;
    [ShowInfo showInfoOnView:self.view withInfo:@"分享取消"];
}

#pragma mark - LoadRegisterInfo
-(void)pullDown{
    
    [self requestRegisterInfo];
}

- (void)requestRegisterInfo {
    
    // 判断网络连接状态
    if (![TestNetWorkReached networkIsReached:self]) {
        [self hideHUD];
        [self.tableView.mj_header endRefreshing];
        return;
    }
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionaryWithDictionary:_urlDict];
    NSString *ticket = _urlDict[@"ticket"];
    NSString *decodeStr =  [PublicTool decodeString:ticket];
    
    if (self.tableView.mj_header.refreshing) {
        [paramDict setValue:@"1" forKey:@"debug"];
    }
    [paramDict setValue:decodeStr?:@"" forKey:@"ticket"];
    [[NetworkManager sharedMgr]requestNewWithMethod:kHTTPPost URLString:@"CompanyDetail/register" HTTPBody:paramDict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        [self hideHUD];
        [self.tableView.mj_header endRefreshing];
        if (resultData && [resultData isKindOfClass:[NSDictionary class]]) {
           
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
                
                self.viewModel = [[RegisterInfoViewModel alloc] initWithAllInfo:resultData company:self.companyName];
                self.viewModel.tableV = self.tableView;
                CFAbsoluteTime end = CFAbsoluteTimeGetCurrent();
                
                QMPLog(@"%f", end - start);
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];

                    if (![PublicTool isNull:self.gotoSection]) {
                        NSInteger section = 0;
                        for (NSDictionary *dic in self.viewModel.allSection) {
                            if ([dic[@"title"] isEqualToString:self.gotoSection]) {
                                section = [self.viewModel.allSection indexOfObject:dic];
                                
                                NSInteger status = [[self.viewModel.sectionShowAllDic valueForKey:dic[@"title"]] integerValue];
                                if (status == HeaderShowStatus_Hide) {
                                    [self.viewModel.sectionShowAllDic setValue:@(HeaderShowStatus_Show) forKey:dic[@"title"]];
                                }
                            }
                        }
                       
                        if (section < self.viewModel.allSection.count) {
                            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section] atScrollPosition:UITableViewScrollPositionTop animated:NO];

                        }
                        self.gotoSection = nil;
                    }
                    
                    [self.tableView reloadData];

                });
            });
            
        }else{
            [PublicTool showMsg:@"暂无数据"];
        }
    }];
}




#pragma mark - UITableViewDataSource & Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.viewModel numberOfSection];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.viewModel numberOfRowInSection:section];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *title = self.viewModel.allSection[indexPath.section][@"title"];
    
    id model = [self.viewModel modelWithIndexPath:indexPath];
    if ([title isEqualToString:@"注册信息"]||[title isEqualToString:@"联系方式"]) { //基本信息
        NSDictionary *row = (NSDictionary *)model;
        if ([row.allKeys containsObject:@"title"]) {
            CompanyBasicInfoTableViewCell *cell = [CompanyBasicInfoTableViewCell cellWithTableView:tableView];
            [cell initDataWithKey:row[@"title"] withValue:row[@"value"]];
            return cell;
        } else {
            AboutTableViewCell *cell = [AboutTableViewCell cellWithTableView:tableView];
            [cell initData:row[@"title2"] aValue:row[@"value2"] currentVC:self];
            return cell;
        }
    }else if ([title containsString:@"关联"]) { //关联
        NSDictionary *row = (NSDictionary *)model;
        UITableViewCell *cell = [self relateCellWithTableView:tableView relateInfo:row];
        return cell;

    } else if ([model isKindOfClass:[CompanysDetailRegisterGudongModel class]]) { //股东
        CompanysDetailRegisterGudongCell *cell = [CompanysDetailRegisterGudongCell cellWithTableView:tableView];
        CompanysDetailRegisterGudongModel *gudoModel = (CompanysDetailRegisterGudongModel *)model;
        [cell refreshUI:gudoModel];
//        if (cell.imgBtn.hidden == NO) {
//            objc_setAssociatedObject(cell.imgBtn, "gudongIconObject", gudoModel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//            [cell.imgBtn addTarget:self action:@selector(pushGudongIconVC:) forControlEvents:UIControlEventTouchUpInside];
//        }
        return cell;
    } else if ([model isKindOfClass:[CompanysDetailRegisterPeoplesModel class]]) { //成员
        CompanysDetailRegisterPeoplesCell *cell = [CompanysDetailRegisterPeoplesCell cellWithTableView:tableView];
        CompanysDetailRegisterPeoplesModel *pModel = (CompanysDetailRegisterPeoplesModel *)model;
        [cell refreshUI:pModel nameColor:RANDOM_COLORARR[indexPath.row%6]];
        cell.searchBtn.hidden = YES;
        return cell;
    } else if ([model isKindOfClass:[CompanysDetailRegisterTouziModel class]]) { //对外投资
        CompanysDetailRegisterTouziCell *cell = [CompanysDetailRegisterTouziCell cellWithTableView:tableView];        
        CompanysDetailRegisterTouziModel *tModel = (CompanysDetailRegisterTouziModel *)model;
        [cell refreshUI:tModel];
//        if (cell.imgBtn.hidden == NO) {
//
//            objc_setAssociatedObject(cell.imgBtn, "gudongIconObject", tModel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//            [cell.imgBtn addTarget:self action:@selector(pushTouziIconVC:) forControlEvents:UIControlEventTouchUpInside];
//        }
        return cell;
    } else if ([model isKindOfClass:[CompanyIcpModel class]]) { //备案信息
        
        CompanyIcpModel *icpModel = (CompanyIcpModel *)model;
        CompanyIcpTableViewCell *cell = [CompanyIcpTableViewCell cellWithTableView:tableView];

        [cell initData:icpModel];
        
        UITapGestureRecognizer *tap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(icpWebInfoTap:)];
        cell.moneyLab.userInteractionEnabled = YES;
        [cell.moneyLab addGestureRecognizer:tap];
        objc_setAssociatedObject(tap, "webUrl",icpModel.web_site , OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return cell;
    } else if ([model isKindOfClass:[CompanysDetailRegisterChangeRecordsModel class]]) { //变更记录
        CompanysDetailRegisterChangeRecordsCell *cell = [CompanysDetailRegisterChangeRecordsCell cellWithTableView:tableView];
        CompanysDetailRegisterChangeRecordsModel *rModel = (CompanysDetailRegisterChangeRecordsModel *)model;
        [cell refreshUI:rModel];
        cell.bottomLine.hidden = (indexPath.row + 1 == [self.viewModel numberOfRowInSection:indexPath.section]);
        return cell;
    } else {
        return [[UITableViewCell alloc]init];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *sectionDict = self.viewModel.allSection[indexPath.section];
    id model = [self.viewModel modelWithIndexPath:indexPath];
    NSString *title = sectionDict[@"title"];
    if ([title containsString:@"关联"]) {
        return 78;
    }else if ([title isEqualToString:@"备案信息"]) {
        return 135;
    } else if ([title isEqualToString:@"对外投资"] || [title isEqualToString:@"主要成员"]||[title isEqualToString:@"股东信息"]) {
        return 60;
    } else if ([title isEqualToString:@"注册信息"]) {
        NSString *value = model[@"value"];
        CGFloat width = (SCREENW - 105);
        NSAttributedString *muAtt = [value stringWithParagraphlineSpeace:4 textColor:[UIColor whiteColor] textFont:[UIFont systemFontOfSize:14]];
        CGFloat height = [muAtt boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.height;
        if (height < 34) {
            return 40;
        }
        return height+15;
    } else if ([title isEqualToString:@"变更记录"]) {
        return [tableView fd_heightForCellWithIdentifier:@"CompanysDetailRegisterChangeRecordsCell" configuration:^(CompanysDetailRegisterChangeRecordsCell *cell) {
            [cell refreshUI:model];
        }];
    }
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    NSDictionary *sectionDict = self.viewModel.allSection[section];
    NSString *title = sectionDict[@"title"];
    if ([title containsString:@"关联"]||[title isEqualToString:@"注册信息"]||[title isEqualToString:@"联系方式"]||
        [title isEqualToString:@"备案信息"]||[title isEqualToString:@"变更记录"]) {
        return 45;
    }
    return 55.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    HeaderShowStatus status = [self.viewModel headerStatusOfSection:section];
    if (status != HeaderShowStatus_None) {
        return 55;
        
    }else{
        return 10.0;
    }
    
    return 10.0;

}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *sectionHeadView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, 55.f)];
    sectionHeadView.backgroundColor = [UIColor whiteColor];
    
    CGFloat lblW = 55.f;
    UILabel *timeLbl = [[UILabel alloc] initWithFrame:CGRectMake(SCREENW - lblW - 17, 11, lblW, 20.f)];
    timeLbl.textAlignment = NSTextAlignmentRight;
    timeLbl.text = [self.viewModel headerDescOfSection:section];
    timeLbl.textColor = H9COLOR;
    timeLbl.font = [UIFont systemFontOfSize:13.f];
    [sectionHeadView addSubview:timeLbl];
    
    UIView *lineV = [[UIView alloc]initWithFrame:CGRectMake(17, 15.5, 2, 14)];
    lineV.backgroundColor = BLUE_BG_COLOR;
    [sectionHeadView addSubview:lineV];
    
    UILabel *infoLbl = [[UILabel alloc] initWithFrame:CGRectMake(25, 0, 100, 45)];
    infoLbl.font = [UIFont systemFontOfSize:15.f];
    infoLbl.text = [self.viewModel headerTitleOfSection:section];
    infoLbl.textColor = HTColorFromRGB(0x555555);
    [sectionHeadView addSubview:infoLbl];
   
    
    //底线
    UIView *bottomLine = [[UIView alloc]initWithFrame:CGRectMake(0,42, sectionHeadView.width, 1)];
    bottomLine.backgroundColor = LIST_LINE_COLOR;
    [sectionHeadView addSubview:bottomLine];
    
    return sectionHeadView;
}


- (void)headerShowBtnClick:(UIButton*)btn{
    NSInteger section = btn.tag - 3000;
    [self.viewModel.headerShowBtnCommand execute:@(section)];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section] atScrollPosition:UITableViewScrollPositionNone animated:NO];
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, 10.0f)];
    footerView.backgroundColor = [UIColor clearColor];
    
    HeaderShowStatus status = [self.viewModel headerStatusOfSection:section];
    if (status != HeaderShowStatus_None) {
        footerView.height = 55;
        
        UIButton *allBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SCREENW, 45.f)];
        [allBtn setTitle:@"查看全部" forState:UIControlStateNormal];
        [allBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
        allBtn.titleLabel.font = [UIFont systemFontOfSize:13.f];
        allBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [allBtn addTarget:self action:@selector(headerShowBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        allBtn.backgroundColor = [UIColor whiteColor];
        [footerView addSubview:allBtn];
        allBtn.tag = 3000 + section;
        //底部灰条
        UIView *grayView = [[UIView alloc]initWithFrame:CGRectMake(17, 0, SCREENW-34, 1)];
        grayView.backgroundColor = LIST_LINE_COLOR;
        [allBtn addSubview:grayView];
        [allBtn setTitle:((status == HeaderShowStatus_Show)?@"收起":@"查看全部") forState:UIControlStateNormal];
        
    }
    
    return footerView;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *sectionDict = self.viewModel.allSection[indexPath.section];
    NSString *title = sectionDict[@"title"];
    NSArray *data = sectionDict[@"data"];
    if ([title isEqualToString:@"注册信息"]) {
        NSDictionary *row = data[indexPath.row];
        if ([row[@"title"] isEqualToString:@"法人代表"]) {
            NSDictionary *dic = [self.viewModel legelPersonParam];
            if (![PublicTool isNull:dic[@"detail"]]) {
                NSDictionary *detailUrlDict = [PublicTool toGetDictFromStr:dic[@"detail"]];//[self handleDetailToDict:model.detail];
                [self enterRegisterView:detailUrlDict withModel:row[@"value"]];
                return;
            }
            [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:@"d/isRelateTyc1" HTTPBody:dic completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {

                if (resultData) {
                    if (![PublicTool isNull:resultData[@"person_id"]]) {
                        [self enterPersonDetail:resultData[@"person_id"]];
                    }else{
                        [self enterAllBusinessVC:[self.viewModel legelPersonModel]];
                    }
                }else{
                    [PublicTool showMsg:@"无数据"];
                }
            }];
        }
    } else if ([title isEqualToString:@"股东信息"]) {
        CompanysDetailRegisterGudongModel *model = [self.viewModel modelWithIndexPath:indexPath];
        NSArray *personArr = @[@"自然人股东",@"自然人"];
        //人
        if ([personArr containsObject:model.gd_type]) {
            NSDictionary *dic = [self dealPersonDetailUrl:model.person_detail];
            dic = @{@"uniq_hid":(model.uniq_hid?model.uniq_hid:@"")};
            if (dic.allKeys.count) {
                [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:@"d/isRelateTyc1" HTTPBody:dic completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
                    
                    if (resultData) {
                        if (![PublicTool isNull:resultData[@"person_id"]]) {
                            [self enterPersonDetail:resultData[@"person_id"]];
                            
                        }else{
                            PersonModel *person1 = [[PersonModel alloc]init];
                            person1.name = model.gd_name;
                            person1.uniq_hid = model.uniq_hid;
                            [self enterAllBusinessVC:person1];
                            
                        }
                    }
                }];
                
            }
            
        }else{
            if (![PublicTool isNull:model.detail]) { //工商
                NSDictionary *detailUrlDict = [PublicTool toGetDictFromStr:model.detail];//[self handleDetailToDict:model.detail];
                [self enterRegisterView:detailUrlDict withModel:model.gd_name];
            }
        }
    } else if ([title isEqualToString:@"主要成员"]) {
        
        CompanysDetailRegisterPeoplesModel *model = [self.viewModel modelWithIndexPath:indexPath];
        
        NSDictionary *dic = [self dealPersonDetailUrl:model.detail];
        dic = @{@"uniq_hid":(model.uniq_hid?:@"")};
        if (dic.allKeys.count) {
            [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:@"d/isRelateTyc1" HTTPBody:dic completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
                if (resultData) {
                    if (![PublicTool isNull:resultData[@"person_id"]]) {
                        [self enterPersonDetail:resultData[@"person_id"]];
                        
                    }else{
                        PersonModel *person = [[PersonModel alloc]init];
                        person.name = model.name;
                        person.uniq_hid = model.uniq_hid;
                        [self enterAllBusinessVC:person];                        }
                }
            }];
        }
    }else if ([title isEqualToString:@"对外投资"]) {
        CompanysDetailRegisterTouziModel *model = [self.viewModel modelWithIndexPath:indexPath];
        NSString *detailUrlTmp = model.detail;
        if (![PublicTool isNull:model.detail]) {
            [self enterRegisterView:[PublicTool toGetDictFromStr:detailUrlTmp] withModel:model.tz_name];
        }
    }else if ([title containsString:@"关联"]) {
        NSDictionary *model = [self.viewModel modelWithIndexPath:indexPath];
        [[AppPageSkipTool shared] appPageSkipToDetail:model[@"detail"]];
    }
}

#pragma mark - DataHandleDelegate
- (void)pressOKOnDataHandleAlertView{
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)getCapture {
    _printscreenImage = nil;
    UIImage* viewImage = nil;
    UITableView *scrollView = self.tableView;
    UIImage *image2 = [BundleTool imageNamed:@"QuickMark"];
    CGFloat imgH = scrollView.contentSize.width/1125 *591;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(scrollView.contentSize.width, scrollView.contentSize.height+ imgH), scrollView.opaque, 0.0);
    {
        CGPoint savedContentOffset = scrollView.contentOffset;
        CGRect savedFrame = scrollView.frame;
        
        scrollView.contentOffset = CGPointZero;
        scrollView.frame = CGRectMake(0, 0, scrollView.contentSize.width, scrollView.contentSize.height);
        
        [scrollView.layer renderInContext: UIGraphicsGetCurrentContext()];
        viewImage = UIGraphicsGetImageFromCurrentImageContext();
        
        scrollView.contentOffset = savedContentOffset;
        scrollView.frame = savedFrame;
    }
    [image2 drawInRect:CGRectMake(0, scrollView.contentSize.height, scrollView.contentSize.width,imgH)];
    UIImage *togetherImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
//    UIImageWriteToSavedPhotosAlbum(togetherImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    
    _printscreenImage = togetherImage;
    
    [self sharePrintScreen];
    [QMPEvent event:@"gs_screenShare_click"];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    NSString *desc = @"";
    if (error == nil) {
        desc = @"保存相册成功";
    }else{
        desc = @"保存相册失败";
    }
    QMPLog(@"-------%@---------", desc);

}
#pragma mark - Event
- (void)sharePrintScreen {
    // 判断网络连接状态
    if (![TestNetWorkReached networkIsReached:self]) {
        if (_printscreenImage) {
            _printscreenImage = nil;
        }
        return;
    }
    [self.shareToTool shareDetailImage:_printscreenImage];
}
- (void)pressRightButtonItem:(id)sender {
    [self goHome];
}
- (void)goHome {
    [self.tabBarController setSelectedIndex:0];
    [self.navigationController popToRootViewControllerAnimated:YES];
    [QMPEvent event:@"gs_homeClick"];
}

- (void)pushGudongIconVC:(UIButton *)sender {
    CompanysDetailRegisterGudongModel *model = objc_getAssociatedObject(sender, "gudongIconObject");
    //判断网络连接状态
    if (![TestNetWorkReached networkIsReached:self]) {
        return;
    }
    if(![PublicTool isNull:model.detail]&&![PublicTool isNull:model.product]) {
        [self enterCompanyDetail:model.detail];
        return;
    }else if(![PublicTool isNull:model.agency_detail]&&![PublicTool isNull:model.agency_name]){
        [self enterCompanyDetail:model.agency_detail];
        return;
    }
        
    NSArray *personArr = @[@"自然人股东", @"自然人"];
    if (![personArr containsObject:model.gd_type]) {
        return;
    }
    NSDictionary *dic = [self dealPersonDetailUrl:model.person_detail];
    dic = @{@"uniq_hid":(model.uniq_hid?:@"")};
    if (dic.allKeys.count <= 0) {
        return;
    }
    [[NetworkManager sharedMgr] RequestWithMethod:kHTTPPost URLString:@"d/isRelateTyc1" HTTPBody:dic completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        if (resultData) {
            if (![PublicTool isNull:resultData[@"person_id"]]) {
                [self enterPersonDetail:resultData[@"person_id"]];
            } else {
                PersonModel *person = [[PersonModel alloc]init];
                person.name = model.person_name;
                person.uniq_hid = model.uniq_hid;
                [self enterAllBusinessVC:person];
            }
        }
    }];
}
- (void)enterAllBusinessVC:(PersonModel*)person{
    if ([PublicTool isNull:person.uniq_hid]) {
        [PublicTool showMsg:@"无数据"];
        return;
    }
    PersonAllBusinessRoleController *busicnessVC = [[PersonAllBusinessRoleController alloc]init];
    busicnessVC.personModel = person;
    busicnessVC.isNeedUserHeader = YES;
    [self.navigationController pushViewController:busicnessVC animated:YES];
}
- (void)pushTouziIconVC:(UIButton *)sender{
    id first = objc_getAssociatedObject(sender, "gudongIconObject");
    //判断网络连接状态
    if (![TestNetWorkReached networkIsReached:self]) {
        return;
    }
    CompanysDetailRegisterTouziModel *model = (CompanysDetailRegisterTouziModel *)first;
    if (![PublicTool isNull:model.product] && ![PublicTool isNull:model.detail]) {
        [self enterCompanyDetail:model.detail];
        return;
    }else if (![PublicTool isNull:model.agency_name] && ![PublicTool isNull:model.agency_detail]) {
        [self enterCompanyDetail:model.agency_detail];
        return;
    }
}

- (void)enterOrganizeDetail:(NSDictionary *)jglinkUrlDict {
    [[AppPageSkipTool shared] appPageSkipToJigouDetail:jglinkUrlDict];
}
- (void)enterPersonDetail:(NSString*)personId {
 
    [[AppPageSkipTool shared] appPageSkipToPersonDetail:personId];

}
- (void)enterCompanyDetail:(NSString *)detail {
    [[AppPageSkipTool shared] appPageSkipToDetail:detail];
}
- (void)enterRegisterView:(NSDictionary *)detailUrlDict withModel:(NSString*)name{
    RegisterInfoViewController *registerDetailVC = [[RegisterInfoViewController alloc]init];
    registerDetailVC.urlDict = detailUrlDict;
    registerDetailVC.product = name;
    registerDetailVC.companyName = name&&![name isEqualToString:@""] ? name:@"";
    [self.navigationController pushViewController:registerDetailVC animated:YES];
}
- (void)enterAllIcp {
    CompanyIcpListViewController *listVC = [[CompanyIcpListViewController alloc] init];
    listVC.tableData = [self.viewModel allIcpInfos];
    [self.navigationController pushViewController:listVC animated:YES];
}
- (void)enterWebViewWithUrlStr:(NSString *)urlStr{
    URLModel *urlModel = [[URLModel alloc]init];
    urlModel.url = urlStr;
    NewsWebViewController *webView = [[NewsWebViewController alloc] initWithUrlModel:urlModel];
    webView.fromVC = @"baidu";
    [self.navigationController pushViewController:webView animated:YES];
}

- (void)icpWebInfoTap:(UITapGestureRecognizer *)tap {
    NSString *urlStr = (NSString *)objc_getAssociatedObject(tap, "webUrl");
    if (urlStr && ![urlStr isEqualToString:@""]) {
        [self enterWebViewWithUrlStr:urlStr];
    }
}

#pragma mark - Getter
- (ShareTo *)shareToTool {
    if (!_shareToTool) {
        _shareToTool = [[ShareTo alloc] init];
        _shareToTool.delegate = self;
    }
    return _shareToTool;
}

#pragma mark - Util
- (NSDictionary*)dealPersonDetailUrl:(NSString*)detail_person {
    if ([PublicTool isNull:detail_person]) {
        return @{};
    }
    NSArray *arr = [detail_person componentsSeparatedByString:@"/"];
    if (arr.count <= 0) {
        return @{};
    }
    NSArray *strArr = [[arr lastObject] componentsSeparatedByString:@"-c"];
    if (strArr.count != 2) {
        return @{};
    }
    return @{@"hid":strArr[0],@"cid":strArr[1]};
}
#pragma mark - 请求快速反馈接口
- (void)requestImmediateFeedback{
    
    if ([TestNetWorkReached networkIsReached:self]) {
        
        NSMutableDictionary *infoDic = [NSMutableDictionary dictionaryWithCapacity:0];
        [infoDic setValue:@"工商信息" forKey:@"module"];
        if (_product && ![_product isEqualToString:@""]) {
            [infoDic setValue:_product forKey:@"product"];
        }else{
            [infoDic setValue:@"" forKey:@"product"];
        }
        if (_companyName && ![_companyName isEqualToString:@""]) {
            [infoDic setValue:_companyName forKey:@"company"];
        }else{
            [infoDic setValue:@"" forKey:@"company"];
        }
        
        NSMutableArray *mArr = [NSMutableArray arrayWithCapacity:0];
        [mArr addObject:@"注册信息不对"];
        
        if ([self.viewModel hasStockHolders]){
            [mArr addObject:@"股东信息不对"];
            [mArr addObject:@"关联公司不全"];
            [mArr addObject:@"关联机构不全"];
            [mArr addObject:@"有产品"];
            
        } else {
            
            [mArr addObject:@"股东信息不全"];
            [mArr addObject:@"有产品"];
            
        }
        
        CGFloat height = 65.f + ((mArr.count-1)/2+1)*35 + 45.f;
        [infoDic setValue:@"工商信息" forKey:@"title"];
        
        CustomAlertView *alert = [[CustomAlertView alloc] initWithAlertViewHeight:mArr frame:CGRectMake(0, 0, 0, 0) WithAlertViewHeight:height infoDic:(NSDictionary *)infoDic viewcontroller:self moduleNum:0 isFeeds:NO];
        
    }
    [QMPEvent event:@"gs_feedback_click"];
    
}

- (UITableViewCell*)relateCellWithTableView:(UITableView*)tableView relateInfo:(NSDictionary*)row{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellID"];
    }
    UIImageView *iconV = [cell.contentView viewWithTag:900];
    if (!iconV) {
        iconV= [[ UIImageView alloc]initWithFrame:CGRectMake(17, 15, 48, 48)];
        iconV.layer.cornerRadius = 2;
        iconV.layer.masksToBounds = YES;
        iconV.layer.borderColor = BORDER_LINE_COLOR.CGColor;
        iconV.layer.borderWidth = 0.5;
        iconV.tag = 900;
        [cell.contentView addSubview:iconV];
    }
    UILabel *nameLab = [cell.contentView viewWithTag:1000];
    if (!nameLab) {
        nameLab = [[UILabel alloc]initWithFrame:CGRectMake(iconV.right+15, 18.5, 200, 20)];
        [nameLab labelWithFontSize:15 textColor:H3COLOR];
        if (@available(iOS 8.2, *)) {
            nameLab.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
        } else {
            nameLab.font = [UIFont systemFontOfSize:15];
        }
        
        nameLab.tag = 1000;
        [cell.contentView addSubview:nameLab];
    }
    UILabel *descLab = [cell.contentView viewWithTag:1001];
    if (!descLab) {
        descLab = [[UILabel alloc]initWithFrame:CGRectMake(iconV.right+15, 43, 200,14)];
        [descLab labelWithFontSize:13 textColor:H6COLOR];
        descLab.tag = 1001;
        [cell.contentView addSubview:descLab];
    }
    [iconV sd_setImageWithURL:[NSURL URLWithString:row[@"icon"]] placeholderImage:[UIImage imageNamed:PROICON_DEFAULT]];
    nameLab.text = row[@"name"];
    descLab.text = row[@"desc"];
    if ([PublicTool isNull:row[@"desc"]] || [row[@"detail"] containsString:@"org"]) {
        descLab.hidden = YES;
        nameLab.centerY = iconV.centerY;
    }else{
        descLab.hidden = NO;
        nameLab.top = 18.5;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
@end
