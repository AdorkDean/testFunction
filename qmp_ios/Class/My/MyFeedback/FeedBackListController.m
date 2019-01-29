//
//  FeedBackListController.m
//  qmp_ios
//
//  Created by QMP on 2018/1/22.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "FeedBackListController.h"
#import "FeedbackListCell.h"
#import "FeedbackModel.h"

@interface FeedBackListController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray *_listArr;
}
@end

@implementation FeedBackListController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _listArr = [NSMutableArray array];
    self.currentPage = 1;
    self.numPerPage = 20;
    [self addView];
    [self showHUD];
    [self requestData];
}


- (void)addView{
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH-kScreenTopHeight) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    [self.view addSubview:self.tableView];
    self.tableView.mj_header = self.mjHeader;
    self.tableView.mj_footer = self.mjFooter;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"FeedbackListCell" bundle:[BundleTool commonBundle]] forCellReuseIdentifier:@"FeedbackListCellID"];
}


#pragma mark --Request--
-(BOOL)requestData{
    if (![super requestData]) {
        return NO;
    }
    
    NSDictionary *dic = @{@"page":@(self.currentPage),@"page_num":@(self.numPerPage)};
    [AppNetRequest getFeedBackListWithParameter:dic completionHandle:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        [self hideHUD];
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        
        if (resultData && [resultData[@"list"] isKindOfClass:[NSArray class]]) {
            
            if (self.currentPage == 1) {
                [_listArr removeAllObjects];
            }
            NSMutableArray *arr = [NSMutableArray array];
            for (NSDictionary *dict in resultData[@"list"]) {
                FeedbackModel *model = [[FeedbackModel alloc]initWithDictionary:dict error:nil];
                [arr addObject:model];
            }
            [_listArr addObjectsFromArray:arr];
            [self refreshFooter:arr];
            [self.tableView reloadData];
        }
    }];
    return YES;
}
#pragma mark --UITableViewDelegate--

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    return [[UIView alloc]init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_listArr.count == 0) {
        return SCREENH - kScreenTopHeight;
    }
    FeedbackModel *model = _listArr[indexPath.row];
    CGFloat height = [PublicTool heightOfString:model.desc  width:SCREENW-88 font:[UIFont systemFontOfSize:15]];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 4.0;
    NSString *desc = model.desc.length > 0 ? model.desc:@"";
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:desc attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15], NSParagraphStyleAttributeName:style}];
    if (model.url.count > 0) {
        NSAttributedString *imStr = [[NSAttributedString alloc] initWithString:@"查看图片" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15], NSParagraphStyleAttributeName:style}];
        [str appendAttributedString:imStr];
    }
    height = [str boundingRectWithSize:CGSizeMake(SCREENW-88, MAXFLOAT) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin context:nil].size.height;
    
    //    if (model.complete.integerValue == 0) {
    //        height -= 48;
    //    }
    //
    return 125+height;
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _listArr.count ? _listArr.count : 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (_listArr.count == 0) {
        return  [self nodataCellWithInfo:REQUEST_DATA_NULL tableView:tableView];
    }
    
    FeedbackListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FeedbackListCellID" forIndexPath:indexPath];
    cell.feedbackM = _listArr[indexPath.row];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
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
