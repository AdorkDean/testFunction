
//
//  ProductValuelistController.m
//  qmp_ios
//
//  Created by QMP on 2018/8/9.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "ProductValuelistController.h"
#import "ProductValueActivityCell.h"
#import "ActivityModel.h"
#import "ActivityLayout.h"
#import "ActivityDetailViewController.h"
#import "NewsWebViewController.h"

@interface ProductValuelistController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)NSMutableArray *valueDynamicArr;
@end

@implementation ProductValuelistController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"价值动态";
    [self setUI];
    self.currentPage = 1;
    self.numPerPage = 20;
    [self showHUD];
    [self requestData];
}

- (void)setUI{
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH - kScreenTopHeight) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.mj_header = self.mjHeader;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = TABLEVIEW_COLOR;
    
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ProductValueActivityCell" bundle:nil] forCellReuseIdentifier:@"ProductValueActivityCellID"];
    [self.view addSubview:self.tableView];
    
    self.tableView.showsVerticalScrollIndicator = NO;
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
}


- (BOOL)requestData{
    if (![super requestData]) {
        return NO;
    }
    
    if ([PublicTool isNull:self.companyTicket]) {
        return NO;
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:@"product" forKey:@"type"];
    [dic setValue:self.companyTicket forKey:@"ticket"];
    [dic setValue:@(2) forKey:@"comment_type"];
    [dic setValue:@(self.currentPage) forKey:@"page"];
    [dic setValue:@(self.numPerPage) forKey:@"num"];
    
    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"activity/getDetailRelationList" HTTPBody:dic completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {

        [self hideHUD];
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];

        if (resultData && [resultData[@"list"] isKindOfClass:[NSArray class]]) {
            
            NSMutableArray *listArr = [NSMutableArray array];
            for (NSDictionary *dict in resultData[@"list"]) {
                ActivityModel *model = [ActivityModel activityModelWithDict:dict];
                if (![PublicTool isNull:model.linkInfo.linkUrl]) {
                    model.linkInfo.linkTitle = @"新闻链接";
                }
                ActivityLayout *layout = [[ActivityLayout alloc] initLayoutWithActivityModel:model type:ActivityLayoutTypeCompany];
                [listArr addObject:layout];
            }
            if (self.currentPage == 1) {
                [self.valueDynamicArr removeAllObjects];
            }
            [self.valueDynamicArr addObjectsFromArray:listArr];
            [self refreshFooter:listArr];
            [self.tableView reloadData];
        }
        
    }];
   
    return YES;
}


#pragma mark --UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.valueDynamicArr.count == 0) {
        return SCREENH - kScreenTopHeight;
    }
    ActivityLayout *l = self.valueDynamicArr[indexPath.row];
    
    if (l.textLayout.lines.count > 1) {
        return 82;
    }
    return 62;
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.valueDynamicArr.count ? self.valueDynamicArr.count:1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.valueDynamicArr.count == 0) {
        return [self nodataCellWithInfo:REQUEST_DATA_NULL tableView:tableView];
        
    }
    
    ProductValueActivityCell *cell = [ProductValueActivityCell productValueActivityCellWithTableView:tableView];
    
    ActivityLayout *l = self.valueDynamicArr[indexPath.row];
    NSMutableAttributedString *a = [[NSMutableAttributedString alloc] initWithAttributedString:l.textLayout.text];
    if (![PublicTool isNull:l.activityModel.linkInfo.linkUrl]) {
        [a yy_setTextHighlightRange:NSMakeRange(a.string.length-l.activityModel.linkInfo.linkTitle.length, l.activityModel.linkInfo.linkTitle.length) color:BLUE_TITLE_COLOR backgroundColor:nil tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            URLModel *m = [URLModel new];
            m.url = l.activityModel.linkInfo.linkUrl;
            NewsWebViewController *vc = [[NewsWebViewController alloc] init];
            vc.urlModel = m;
            [[PublicTool topViewController].navigationController pushViewController:vc animated:YES];
        }];
    }
    
    
    cell.label.attributedText = a;
    cell.label.frame = CGRectMake(16, 10, SCREENW-32, l.textLayout.textBoundingSize.height+2);
    cell.dateLabel.text =  [l.activityModel.createTime componentsSeparatedByString:@" "][0];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.valueDynamicArr.count == 0) {
        return;
    }
    
    ActivityLayout *l = self.valueDynamicArr[indexPath.row];
    ActivityDetailViewController *vc = [[ActivityDetailViewController alloc] init];
    vc.activityID = l.activityModel.ID;
    vc.activityTicket = l.activityModel.ticket;
    [self.navigationController pushViewController:vc animated:YES];
}



#pragma mark --懒加载--
- (NSMutableArray *)valueDynamicArr{
    if (!_valueDynamicArr) {
        _valueDynamicArr = [NSMutableArray array];
    }
    return _valueDynamicArr;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
