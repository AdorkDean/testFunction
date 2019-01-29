//
//  InvestorTzCaseController.m
//  qmp_ios
//
//  Created by QMP on 2017/11/27.
//  Copyright © 2017年 Molly. All rights reserved.
//

#import "InvestorTzCaseController.h"
#import "InvestorTzCaseCell.h"
#import "CustomAlertView.h"

@interface InvestorTzCaseController ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation InvestorTzCaseController


- (void)viewDidLoad {
    [super viewDidLoad];

    [self buildRightBarButtonItem];
    [self initTableView];
    
}


- (void)buildRightBarButtonItem{
    
    UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 47.f, 20.f)];
    [rightBtn setTitle:@"反馈" forState:UIControlStateNormal];
    rightBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:15.f];
    [rightBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(feedbackDetail:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)feedbackDetail:(UIButton*)btn{
    
    NSMutableArray *mArr = [NSMutableArray arrayWithCapacity:0];
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionaryWithCapacity:0];//反馈所在模块的信息
    
    if (![PublicTool isNull:self.person.name]) {
        [infoDic setValue:self.person.name forKey:@"company"];
    }else{
        [infoDic setValue:@"" forKey:@"company"];
    }
    
    [infoDic setValue:self.person.personId forKey:@"product"];
    NSString *title = [self.title containsString:@"服务"]?@"人物服务案例":@"人物投资案例";
    [infoDic setValue:title forKey:@"title"];
    [infoDic setValue:title forKey:@"module"];
    
    [mArr addObject:@"案例不对"];
    [mArr addObject:@"案例不全"];
    
    CustomAlertView *alert = [[CustomAlertView alloc] initWithAlertViewHeight:mArr frame:CGRectZero WithAlertViewHeight:50 infoDic:(NSDictionary *)infoDic viewcontroller:self moduleNum:0 isFeeds:NO];
}

- (void)initTableView{
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH-kScreenTopHeight) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = TABLEVIEW_COLOR;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"InvestorTzCaseCell" bundle:nil] forCellReuseIdentifier:@"InvestorTzCaseCellID"];
    [self.view addSubview:self.tableView];
}



#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _listArr.count ? _listArr.count : 0;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return _listArr.count ? 69 : SCREENH - kScreenTopHeight;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ( _listArr.count == 0 ) {

        NSString *title = REQUEST_DATA_NULL;
        return [self nodataCellWithInfo:title tableView:tableView];
        
    } else{
        InvestorTzCaseCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InvestorTzCaseCellID" forIndexPath:indexPath];
        cell.tzCaseM = _listArr[indexPath.row];
        cell.iconColor = RANDOM_COLORARR[indexPath.row%6];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (_listArr.count == 0) {
        
        return;
    }
    else{
        PersonTouziModel *model = _listArr[indexPath.row];
        if (![PublicTool isNull:model.detail]) {
            NSDictionary *urlDict = [PublicTool toGetDictFromStr:model.detail];
            [[AppPageSkipTool shared] appPageSkipToProductDetail:urlDict];
            
        }
        [QMPEvent event:@"person_tzcaseCellClick"];
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1;
}
- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [[UIView alloc]init];
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}
- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc]init];
}


@end
