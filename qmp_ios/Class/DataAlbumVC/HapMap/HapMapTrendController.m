//
//  HapMapTrendController.m
//  qmp_ios
//
//  Created by QMP on 2017/11/17.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "HapMapTrendController.h"
#import "HapMapTrendModel.h"
#import "HapMapTrendCell.h"
#import "HapMapActionJigouCell.h"

@interface HapMapTrendController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *_trendArr;
    NSMutableArray *_activeJigouArr;
}
@end

@implementation HapMapTrendController

- (void)viewDidLoad {
    [super viewDidLoad];
    _trendArr = [NSMutableArray array];
    _activeJigouArr = [NSMutableArray array];
    
    [self showHUD];
    [self requestTrendData];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.backgroundColor = [UIColor whiteColor];

}

- (void)setUI{
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENW,SCREENH-kScreenTopHeight-44) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    self.tableView.backgroundColor = [UIColor whiteColor];

    [self.tableView registerClass:[HapMapTrendCell class] forCellReuseIdentifier:@"HapMapTrendCellID"];
    [self.tableView registerClass:[HapMapActionJigouCell class] forCellReuseIdentifier:@"HapMapActionJigouCellID"];

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}


- (void)requestTrendData{
    
    if (self.fromLingyu) {
        NSDictionary *dic = @{@"tag":self.tagStr?self.tagStr:@""};
        
        [AppNetRequest getPicOfLingyuWithParameter:dic completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
            [self hideHUD];
            if (resultData && resultData[@"trend"]) {
                [_trendArr removeAllObjects];
                for (NSDictionary *dic in resultData[@"trend"]) {
                    HapMapTrendModel *trend = [[HapMapTrendModel alloc]initWithDictionary:dic error:nil];
                    [_trendArr addObject:trend];
                }
            }
            if (resultData && resultData[@"active"]) {
                [_activeJigouArr removeAllObjects];
                for (NSDictionary *dic in resultData[@"active"]) {
                    HapMapActiveJIgouModel *active = [[HapMapActiveJIgouModel alloc]initWithDictionary:dic error:nil];
                    [_activeJigouArr addObject:active];
                }
                [_activeJigouArr sortUsingComparator:^NSComparisonResult(HapMapActiveJIgouModel * _Nonnull obj1, HapMapActiveJIgouModel *  _Nonnull obj2) {
                    return obj1.count.integerValue > obj2.count.integerValue;
                }];
                
            }
            [self setUI];
            
            [self.tableView reloadData];
            
        }];
        
    }else{
        NSDictionary *dic = @{@"tag":self.tagStr?self.tagStr:@""};
        
        [AppNetRequest getTrendByTagWithParameter:dic completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
            [self hideHUD];
            if (resultData && resultData[@"trend"]) {
                [_trendArr removeAllObjects];
                for (NSDictionary *dic in resultData[@"trend"]) {
                    HapMapTrendModel *trend = [[HapMapTrendModel alloc]initWithDictionary:dic error:nil];
                    [_trendArr addObject:trend];
                }
            }
            if (resultData && resultData[@"active"]) {
                [_activeJigouArr removeAllObjects];
                for (NSDictionary *dic in resultData[@"active"]) {
                    HapMapActiveJIgouModel *active = [[HapMapActiveJIgouModel alloc]initWithDictionary:dic error:nil];
                    [_activeJigouArr addObject:active];
                }
                [_activeJigouArr sortUsingComparator:^NSComparisonResult(HapMapActiveJIgouModel * _Nonnull obj1, HapMapActiveJIgouModel *  _Nonnull obj2) {
                    return obj1.count.integerValue > obj2.count.integerValue;
                }];
                
            }
            [self setUI];
            
            [self.tableView reloadData];
            
        }];
    }
    
}


#pragma mark --UITableViewDelegate---

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 41;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 41)];
    headView.backgroundColor = [UIColor whiteColor];
    UILabel *titleLab = [[UILabel alloc]initWithFrame:CGRectMake(17, 20, 130, 21)];
    titleLab.textColor = NV_TITLE_COLOR;
    titleLab.font = [UIFont systemFontOfSize:15];
    [headView addSubview:titleLab];
    UILabel *trailLab = [[UILabel alloc]initWithFrame:CGRectMake(SCREENW - 17 - 100, 20, 100, 21)];
    [trailLab labelWithFontSize:13 textColor:H9COLOR];
    trailLab.textAlignment = NSTextAlignmentRight;
    [headView addSubview:trailLab];
    
    if (section == 0) {
        titleLab.text = @"投资趋势";
        trailLab.text = @"单位:笔";
    }else if(section == 1){
        titleLab.text = @"活跃机构";
        trailLab.text = @"单位:个";
    }
    
    return headView;
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 10)];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0 && _trendArr.count) {
        return 290;
    }else if(indexPath.section == 1 && _activeJigouArr.count){
        return _activeJigouArr.count * 37 + _activeJigouArr.count*6 + 30;

    }
    return 120;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0 && _trendArr.count) {
        HapMapTrendCell *trendCell = [tableView dequeueReusableCellWithIdentifier:@"HapMapTrendCellID" forIndexPath: indexPath];
        
        [trendCell buildUI:_trendArr];
        trendCell.selectionStyle = UITableViewCellSelectionStyleNone;
        return trendCell;
        
    }else if(indexPath.section == 1 && _activeJigouArr.count){
        
        HapMapActionJigouCell *jigouCell = [tableView dequeueReusableCellWithIdentifier:@"HapMapActionJigouCellID" forIndexPath:indexPath];
        
        [jigouCell buildUI:_activeJigouArr];
        
        __weak typeof(self) weakSelf = self;
        
        jigouCell.clickJigou = ^(NSString *jigouUrl) {
    
            NSDictionary *urlDict = [PublicTool toGetDictFromStr:jigouUrl];
            [[AppPageSkipTool shared] appPageSkipToJigouDetail:urlDict];
        };
        
        jigouCell.selectionStyle = UITableViewCellSelectionStyleNone;
        return jigouCell;
    }else{
        
        static NSString *cellIdentifier = @"infoCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        UILabel *lab = [cell.contentView viewWithTag:1000];
        if (!lab) {
            lab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, SCREENW, 120)];
            [lab labelWithFontSize:16 textColor:H5COLOR];
            [cell.contentView addSubview:lab];
            lab.tag = 1000;
            lab.textAlignment = NSTextAlignmentCenter;
            lab.text = @"暂无相关数据";
        }
       
        return cell;
    }
    
    return nil;
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}


@end
