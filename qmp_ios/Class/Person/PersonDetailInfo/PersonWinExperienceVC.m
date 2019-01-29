//
//  PersonWinExperienceVC.m
//  qmp_ios
//
//  Created by QMP on 2018/4/13.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "PersonWinExperienceVC.h"
#import "CustomAlertView.h"
#import "JobExpriencesCell.h"

@interface PersonWinExperienceVC ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation PersonWinExperienceVC


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.navTitleStr;
    [self buildRightBarButtonItem];
    [self initTableView];
    
}
- (void)setNavTitleStr:(NSString *)navTitleStr{
    _navTitleStr = navTitleStr;
    self.title = _navTitleStr;
}


- (void)buildRightBarButtonItem{
    
    UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 47.f, 20.f)];
    [rightBtn setTitle:@"反馈" forState:UIControlStateNormal];
    rightBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:15.f];
    [rightBtn setTitleColor:BLUE_TITLE_COLOR forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(feedbackDetail) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)feedbackDetail{
    
    NSMutableArray *mArr = [NSMutableArray arrayWithCapacity:0];
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionaryWithCapacity:0];//反馈所在模块的信息
    if (_formType == ExperionStylePerson) {
        if (![PublicTool isNull:self.person.name]) {
            [infoDic setValue:self.person.name forKey:@"company"];
        }else{
            [infoDic setValue:@"" forKey:@"company"];
        }
        [infoDic setValue:self.person.personId forKey:@"product"];
        [infoDic setValue:@"获奖经历" forKey:@"title"];
        [infoDic setValue:@"获奖经历" forKey:@"module"];
        [infoDic setValue:@"获奖经历" forKey:@"type"];
    }else if (_formType == ExperionStyleJiGou){
        [infoDic setValue:@"获奖经历" forKey:@"title"];
        [infoDic setValue:@"机构获奖经历" forKey:@"module"];
        [infoDic setValue:@"机构获奖经历" forKey:@"type"];
        
        [infoDic setValue:[PublicTool nilStringReturn:self.jigModel.name] forKey:@"product"];
        [infoDic setValue:[PublicTool nilStringReturn:self.jigModel.name] forKey:@"jgname"];
        
    }else if (_formType == ExperionStylePro){
        [infoDic setValue:@"获奖经历" forKey:@"title"];
        [infoDic setValue:@"项目获奖经历" forKey:@"module"];
        [infoDic setValue:@"项目获奖经历" forKey:@"type"];
        
        [infoDic setValue:[PublicTool nilStringReturn:self.productM.company_basic.product] forKey:@"product"];
        [infoDic setValue:[PublicTool nilStringReturn:self.productM.company_basic.product] forKey:@"company"];
    }
    
    [mArr addObject:@"奖项名称不对"];
    [mArr addObject:@"颁奖单位不对"];
    [mArr addObject:@"颁奖时间不对"];
    
    CustomAlertView *alert = [[CustomAlertView alloc] initWithAlertViewHeight:mArr frame:CGRectZero WithAlertViewHeight:50 infoDic:(NSDictionary *)infoDic viewcontroller:self moduleNum:0 isFeeds:NO];
}


- (void)initTableView{
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH-kScreenTopHeight) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = TABLEVIEW_COLOR;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
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
    if (_listArr.count) {
        WinExperienceModel *winM = self.listArr[indexPath.row];

        NSString *name = [PublicTool isNull:winM.winning] ? winM.prize_name:winM.winning;
        CGFloat height = [PublicTool heightOfString:name width:SCREENW-74 font:[UIFont systemFontOfSize:15]];
        if (indexPath.row == 0) {
            return height+55;
        }
        return height+45;
    }
    
    
    return SCREENH - kScreenTopHeight;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ( _listArr.count == 0 ) {
        
        NSString *title = REQUEST_DATA_NULL;
        return [self nodataCellWithInfo:title tableView:tableView];
        
    } else{
        JobExpriencesCell *cell = [JobExpriencesCell cellWithTableView:tableView];
        cell.nameLabRightEdge.constant = 17;
        if (self.formType == ExperionStylePerson) {
            cell.winExprienceM = self.listArr[indexPath.row];
        }else{
            cell.proOrgPrizeM = self.listArr[indexPath.row];
        }
        cell.topLine.backgroundColor = F5COLOR;
        if (indexPath.row == 0) { //第一个
            cell.topLine.backgroundColor = [UIColor whiteColor];
            cell.topEdge.constant = 10;
        }else{
            cell.topEdge.constant = 0;
        }
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   
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
