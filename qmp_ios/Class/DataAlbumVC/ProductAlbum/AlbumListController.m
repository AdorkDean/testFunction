//
//  AlbumListController.m
//  qmp_ios_v2.0
//
//  Created by QMP on 2018/10/23.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "AlbumListController.h"
#import "AlbumListCell.h"
#import "OneSquareListViewController.h"

@interface AlbumListController () <UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)NSMutableArray *groupArr;
@property(nonatomic,strong)NSMutableArray *hotArr;

@end

@implementation AlbumListController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.currentPage = 1;
    self.numPerPage = 20;
    [self setViews];
    [self showHUD];
    [self requestData];
}

- (void)setViews{
    self. self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH - kScreenTopHeight) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.mj_header = self.mjHeader;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = TABLEVIEW_COLOR;
    
    
    [self.tableView registerNib:[UINib nibWithNibName:@"IPOEventCell" bundle:nil] forCellReuseIdentifier:@"IPOEventCellID"];
    [self.tableView registerNib:[UINib nibWithNibName:@"IPOEventHeaderV" bundle:nil] forHeaderFooterViewReuseIdentifier:@"IPOEventHeaderVID"];
    [self.view addSubview:self.tableView];
    
    self.tableView.showsVerticalScrollIndicator = NO;
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

#pragma mark --Request Data

- (BOOL)requestData{
    if (![super requestData]) {
        return NO;
    }
    
    if ([TestNetWorkReached networkIsReached:self]) {
    
        NSString *type = self.isFieldAlbum ? @"":@"top";
        NSMutableDictionary *searchDict = [NSMutableDictionary dictionaryWithDictionary:@{@"page":@(self.currentPage),@"num":@(self.numPerPage),@"type":type}];
        
        [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"album/getAlbumLists" HTTPBody:searchDict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
            
            [self hideHUD];

            [self.tableView.mj_header endRefreshing];
            [self.tableView.mj_footer endRefreshing];
            
            if (resultData && [resultData isKindOfClass:[NSArray class]]) {
                
                NSMutableArray *groupMarr = [NSMutableArray array];
                for (NSDictionary *dic in resultData) {
                    GroupModel *model = [[GroupModel alloc]initWithDictionary:dic error:nil];
                    [groupMarr addObject:model];
                }
                //正常状态下包含分页
                if (self.currentPage == 1) {
                    self.groupArr = groupMarr;
                    
                }else{
                    [self.groupArr addObjectsFromArray:groupMarr];
                    
                }
                
                [self refreshFooter:groupMarr];
                [self.tableView reloadData];

            }
        }];
        
    }else{
        
        [self hideHUD];
        [self.tableView.mj_footer endRefreshing];
        [self.tableView.mj_header endRefreshing];
        
    }
    return YES;
}

#pragma mark --UItableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return self.groupArr.count ? 100:tableView.height;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.groupArr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.groupArr.count) {
        AlbumListCell *cell = [AlbumListCell cellWithTableView:tableView];
        cell.groupM = self.groupArr[indexPath.row];
        return cell;
    }
    
    return [self nodataCellWithInfo:REQUEST_DATA_NULL tableView:tableView];
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.groupArr.count) {
        //跳转,请求分组列表
        OneSquareListViewController *listVC = [[OneSquareListViewController alloc] init];
        listVC.groupModel = self.groupArr[indexPath.row];
        listVC.action = @"ManagerSquare";
        [self.navigationController pushViewController:listVC animated:YES];
    }
    
}

@end
