//
//  SchoolPersonController.m
//  qmp_ios
//
//  Created by QMP on 2018/3/27.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "SchoolPersonController.h"
#import "CompanyPersonCell.h"
#import "SearchPerson.h"

@interface SchoolPersonController ()<UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>


@property (strong, nonatomic) NSMutableArray *tableData;


@end

@implementation SchoolPersonController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initTableView];
    
    [self showHUD];
    self.title = self.school;
    self.currentPage = 1;
    self.numPerPage = 20;
    self.title = self.school;
    
    [self requestData];
}


- (BOOL)requestData{
    
    if (![super requestData]) {
        return NO;
    }
    
    [AppNetRequest getSchoolPersonWithParameter:@{@"school":self.school,@"page":@(self.currentPage),@"num":@(self.numPerPage)} completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        [self hideHUD];
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];

        if (resultData) {
            
            NSMutableArray *arr = [NSMutableArray array];
            for (NSDictionary *dic in resultData[@"list"]) {
                SearchPerson *person = [[SearchPerson alloc]initWithDictionary:dic error:nil];
                [arr addObject:person];
            }
            
            if (self.currentPage == 1) {
                [self.tableData removeAllObjects];
//                self.title = [NSString  stringWithFormat:@"%@(%@)",self.school,resultData[@"count"]];
                
            }
            [self.tableData addObjectsFromArray:arr];
            [self refreshFooter:arr];
            [self.tableView reloadData];
        }
        
    }];
    
    return YES;
}

#pragma mark - UITableView
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
    
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
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.tableData.count ? self.tableData.count:1;

    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.tableData.count == 0) {
        return SCREENH - kScreenTopHeight;
    }
    return 77;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.tableData.count == 0) {
        return [self nodataCellWithInfo:REQUEST_DATA_NULL tableView:tableView];

    }else{
        SearchPerson *person = _tableData[indexPath.row];
        
        CompanyPersonCell *companyCell = [tableView dequeueReusableCellWithIdentifier:@"CompanyPersonCellID" forIndexPath:indexPath];
        companyCell.person = person;
        companyCell.iconColor = RANDOM_COLORARR[indexPath.row%6];
        companyCell.chatBtn.hidden = [PublicTool isNull:person.usercode];
        companyCell.chatBtn.tag = indexPath.row + 1000;
        [companyCell.chatBtn addTarget:self action:@selector(enterChatVC:) forControlEvents:UIControlEventTouchUpInside];
        companyCell.selectionStyle = UITableViewCellSelectionStyleNone;
        return companyCell;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.tableData.count == 0) {
        return;
    }
    
    ManagerItem *item = _tableData[indexPath.row];
    
    if (![PublicTool isNull:item.personId]) {
        [[AppPageSkipTool shared] appPageSkipToPersonDetail:item.personId nameLabBgColor:RANDOM_COLORARR[indexPath.row%6]];
    }
}



- (void)enterChatVC:(UIButton*)chatBtn{
    SearchPerson *person = _tableData[chatBtn.tag - 1000];
    [[AppPageSkipTool shared] appPageSkipToChatView:person.usercode verifyUserClaim:YES];
}

- (void)initTableView{
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH-kScreenTopHeight) style:UITableViewStyleGrouped];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    self.tableView.mj_header = self.mjHeader;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"CompanyPersonCell" bundle:[BundleTool commonBundle]] forCellReuseIdentifier:@"CompanyPersonCellID"];
    
    [self.view addSubview:self.tableView];
}


#pragma mark --懒加载
-(NSMutableArray *)tableData{
    if (!_tableData) {
        _tableData = [NSMutableArray array];
    }
    return _tableData;
}


@end
