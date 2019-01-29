//
//  InvestmentDistributionViewController.m
//  qmp_ios
//
//  Created by Molly on 2017/2/14.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "InvestmentDistributionViewController.h"
#import "JigouDetailChartTableViewCell.h"
#import "JigouDetailChartModel.h"

@interface InvestmentDistributionViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong) NSMutableArray * chartCellStrHeightMArr;//存横向条形图高度
@property(nonatomic,strong) NSMutableArray * chartDataMArr;//投资分布图表

@end

@implementation InvestmentDistributionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    
    [self initTableView];
    [self showHUD];

    [self requestChart:self.userDict];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initTableView{
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH - kScreenTopHeight) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.mj_header = self.mjHeader;
    [self.view addSubview:self.tableView];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)pullDown{
    
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionaryWithDictionary:self.userDict];
    [requestDict setValue:@"1" forKey:@"debug"];
    [self requestChart:requestDict];
    
}
#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.chartCellStrHeightMArr.count == 0) {
        return 1;
    }
    return self.chartDataMArr.count?:1;;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.chartCellStrHeightMArr.count == 0) {
        return [self nodataCellWithInfo:REQUEST_DATA_NULL tableView:tableView];
    }
    NSArray *chartArr = self.chartDataMArr[indexPath.section];
    JigouDetailChartTableViewCell *cell = [[JigouDetailChartTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"userID" andModel:chartArr];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.chartCellStrHeightMArr.count == 0) {
        return SCREENH - kScreenTopHeight;
    }
    NSNumber *tmpHeight = self.chartCellStrHeightMArr[indexPath.section];
    NSUInteger cellHeight = [tmpHeight unsignedIntegerValue];
    if (indexPath.section == self.chartDataMArr.count-1) {
        return cellHeight+20;
    }else{
        return cellHeight;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if ([self.chartCellStrHeightMArr.firstObject integerValue] == 0) {
        return [[UIView alloc]init];
    }
    if(section == 0){
       UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, 30.f)];
       headView.backgroundColor = [UIColor whiteColor];
       
       UIView *lineV = [[UIView alloc]initWithFrame:CGRectMake(10, 11, 2, 14)];
       lineV.backgroundColor = BLUE_BG_COLOR;
       [headView addSubview:lineV];
       
       UILabel *infoLbl = [[UILabel alloc] initWithFrame:CGRectMake(18, 11, 100, 16)];
       infoLbl.font = [UIFont systemFontOfSize:16.f];
       infoLbl.text = @"投资分布";
       infoLbl.textColor = RGBblackColor;
       infoLbl.textAlignment = NSTextAlignmentLeft;
       [headView addSubview:infoLbl];
       
       return headView;
    }
    
    return [[UIView alloc]init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if ([self.chartCellStrHeightMArr.firstObject integerValue] == 0) {
        return 0.1;
    }else if(section == 0){
        return 40.f;
    }
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{

    return 0.5f;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 0.5)];
    line.backgroundColor = LIST_LINE_COLOR;
    return line;
}
#pragma mark - 请求投资分布图表tzpic
- (void)requestChart:(NSDictionary *)dict{
 
    if ([TestNetWorkReached networkIsReached:self]){

        [[NetworkManager sharedMgr]requestNewWithMethod:kHTTPPost URLString:@"AgencyDetail/agencyEventFilter" HTTPBody:dict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
            [self.tableView.mj_header endRefreshing];
            [self hideHUD];

            if (resultData && [resultData isKindOfClass:[NSDictionary class]]) {
                NSMutableArray *chartDataMArr = [NSMutableArray arrayWithCapacity:0];
                NSDictionary *chartDict = resultData;
                [self.chartDataMArr removeAllObjects];
                //hangye
                if (chartDict[@"industry_list"]&& [chartDict[@"industry_list"] isKindOfClass:[NSArray class]] ) {
                    for (NSDictionary *hangyePicDic in chartDict[@"industry_list"]) {
                        if ([hangyePicDic[@"count"] integerValue]!=0) {
                            JigouDetailChartModel *model = [[JigouDetailChartModel alloc]init];
                            model.chartType = ChartType_Industry;
                            [model setValuesForKeysWithDictionary:hangyePicDic];
                            [chartDataMArr addObject:model];
                        }
                    }
                    [self getHeightFromJigouDetailChartModel:chartDataMArr];//从model中得到高度
                    [self.chartDataMArr addObject:chartDataMArr];
                }
                
                if (chartDict[@"rotation_list"]&& [chartDict[@"rotation_list"] isKindOfClass:[NSArray class]]) {
                    NSMutableArray *chartMArr = [NSMutableArray arrayWithCapacity:0];
                    for (NSDictionary *dict in chartDict[@"rotation_list"]) {
                        if ([dict[@"count"] integerValue]!=0) {
                            JigouDetailChartModel *model4 = [[JigouDetailChartModel alloc]init];
                            [model4 setValuesForKeysWithDictionary:dict];
                            model4.chartType = ChartType_Lunci;
                            [chartMArr addObject:model4];
                        }
                    }
                    [self getHeightFromJigouDetailChartModel:chartMArr];//从model中得到高度
                    [self.chartDataMArr addObject:chartMArr];
                }
                //year
                if (chartDict[@"year_list"]&& [chartDict[@"year_list"] isKindOfClass:[NSArray class]]) {
                    NSMutableArray *chartMAr = [NSMutableArray arrayWithCapacity:0];
                    for (NSDictionary *dict in chartDict[@"year_list"]) {
                        JigouDetailChartModel *model4 = [[JigouDetailChartModel alloc]init];
                        [model4 setValuesForKeysWithDictionary:dict];
                        model4.chartType = ChartType_Time;
                        [chartMAr addObject:model4];
                    }
                    [self getHeightFromJigouDetailChartModel:chartMAr];//从model中得到高度
                    [self.chartDataMArr addObject:chartMAr];
                }
            }
            
            [self.tableView reloadData];
        }];
        
    }else{
        [self hideHUD];
        [self.tableView.mj_header endRefreshing];
    }
}

/**
 得到各个JigouDetailChartCell高度
 */
- (void)getHeightFromJigouDetailChartModel:(NSArray *)dataArr{
    if (dataArr.count == 0) {
        [self.chartCellStrHeightMArr addObject:@(0)];
        return;
    }
    JigouDetailChartModel *model = dataArr[0];
    NSUInteger chartStrHeight = (dataArr.count*(10+14))/0.87f + 20+60;//80是x轴label高度 tmpArr.count*(10+14)+ 88
    if (model.chartType == ChartType_Industry || model.chartType == ChartType_Lunci) {
      chartStrHeight = dataArr.count*(10+14)+ 30+dataArr.count*2;//80是x轴label高度 tmpArr.count*(10+14)+ 88
    }
    
    [self.chartCellStrHeightMArr addObject:@(chartStrHeight)];
}


#pragma mark - 懒加载

- (NSMutableArray *)chartCellStrHeightMArr{
    if (!_chartCellStrHeightMArr) {
        _chartCellStrHeightMArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _chartCellStrHeightMArr;
}

- (NSMutableArray *)chartDataMArr{
    if (!_chartDataMArr) {
        _chartDataMArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _chartDataMArr;
}
@end
