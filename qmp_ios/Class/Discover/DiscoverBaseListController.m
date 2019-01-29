//
//  DiscoverBaseListController.m
//  qmp_ios
//
//  Created by QMP on 2018/8/13.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "DiscoverBaseListController.h"

NSNotificationName const ChildScrollVDidScrollNSNotification = @"ChildScrollViewDidScrollNSNotification";
NSNotificationName const ChildScrollVRefreshStateNSNotification = @"ChildScrollViewRefreshStateNSNotification";

@interface DiscoverBaseListController ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation DiscoverBaseListController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH-kScreenBottomHeight-kScreenTopHeight) style:UITableViewStyleGrouped];
    
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else{
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.layer.masksToBounds = NO;
//    self.tableView.contentInset = UIEdgeInsetsMake(kHeaderViewH+kPageMenuH, 0, 0, 0);
//    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(kHeaderViewH+kPageMenuH, 0, 0, 0);
    
    [self.view addSubview:self.tableView];
    self.scrollView = self.tableView;
    
    self.tableView.estimatedRowHeight =75;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    
}



- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetDifference = scrollView.contentOffset.y - self.lastContentOffset.y;
    // 滚动时发出通知
    if (scrollView.contentOffset.y <= -(kPageMenuH+kHeaderViewH)) {
        return;
    }
//    [[NSNotificationCenter defaultCenter] postNotificationName:ChildScrollVDidScrollNSNotification object:nil userInfo:@{@"scrollingScrollView":scrollView,@"offsetDifference":@(offsetDifference)}];
    self.lastContentOffset = scrollView.contentOffset;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.lastContentOffset = scrollView.contentOffset;
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
