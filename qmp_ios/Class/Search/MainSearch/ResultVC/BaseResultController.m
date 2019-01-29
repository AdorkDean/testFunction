//
//  BaseResultController.m
//  qmp_ios
//
//  Created by QMP on 2018/1/23.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "BaseResultController.h"
#import "CustomAlertView.h"
#import "WebSearchController.h"

@interface BaseResultController ()<CustomAlertViewDelegate>

@end

@implementation BaseResultController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //tableView
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH - kScreenTopHeight-45) style:UITableViewStyleGrouped];
    
    [self.view addSubview:self.tableView];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.delegate  = self;
    self.tableView.dataSource = self;
    self.tableView.mj_footer = self.mjFooter;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else{
        self.automaticallyAdjustsScrollViewInsets = NO;
    }

//    UIView *footerV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 40)];
//    footerV.backgroundColor = [UIColor whiteColor];
//    self.tableView.tableFooterView = footerV;
}


-(void)setKeyword:(NSString *)keyword{
    NSString *oldWord = _keyword;
    _keyword = keyword;
    self.currentPage = 1;
    self.feedbackBtn.selected = NO;
    self.feedbackBtn.userInteractionEnabled = YES;//不能重复反馈

    [self.dataArr removeAllObjects];
//    UIScrollView *supV = (UIScrollView*)self.view.superview;
    if ([self isViewLoaded]) { //在屏幕内再请求
        
        [self.tableView setContentOffset:CGPointZero animated:NO];
        [self requestData];
    }
}

- (void)baiduBtnClick{

    WebSearchController *webSearchVC = [[WebSearchController alloc]init];
    webSearchVC.keyword = self.keyword;
    [self.navigationController pushViewController:webSearchVC animated:YES];
}


- (void)kefuBtnClick:(UIButton *)button {
    NSString *title = @"";
    switch (self.searchType) {
        case SearchType_All:
            title = @"全部";
            break;
        case SearchType_Product:
            title = @"项目";
            break;
        case SearchType_Jigou:
            title = @"机构";
            break;
        case SearchType_Person:
            title = @"人物";
            break;
        case SearchType_Company:
            title = @"公司";
            break;
        case SearchType_Report:
            title = @"报告";
            break;
        case SearchType_News:
            title = @"新闻";
            break;
            
        default:
            break;
    }
    NSString *msg = [NSString stringWithFormat:@"你好，我在搜索%@时%@列表无结果，烦请处理一下",self.keyword,title];
    [PublicTool contactKefuMSG:msg reply:kDefaultWel delMsg:NO];
}

- (void)feedbackAlertView1{
    
    NSMutableArray *arr = [NSMutableArray arrayWithObjects:@"有官网",@"有新闻报道",@"有招聘信息",@"有产品",@"有联系方式", nil];
    
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionaryWithDictionary:@{@"module":@"搜索列表详情",@"title":@"搜索"}];
    [infoDic setValue:@"人工信息完善" forKey:@"type"];
    [infoDic setValue:@"急" forKey:@"c4"];
    [infoDic setValue:self.keyword forKey:@"c1"];
    [infoDic setValue:self.keyword forKey:@"company"];
    
    CustomAlertView *alertV = [[CustomAlertView alloc]initWithAlertViewHeight:arr frame:CGRectZero WithAlertViewHeight:10 infoDic:infoDic viewcontroller:self moduleNum:0 isFeeds:NO];
    alertV.delegate = self;
}


#pragma mark --CustomAlertViewDelegate --

- (void)feedsUploadSuccess{
    self.feedbackBtn.selected = YES;
    self.feedbackBtn.userInteractionEnabled = NO;//不能重复反馈
}


- (NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr = [[NSMutableArray alloc] initWithCapacity:0];
    }
    
    return _dataArr;
}

@end
