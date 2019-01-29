//
//  QMPDescoverTabController.m
//  qmp_ios
//
//  Created by QMP on 2018/10/10.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "QMPDescoverTabController.h"
#import "HomeNavigationBar.h"
#import "DiscoverTabController.h"


@interface QMPDescoverTabController ()

@property (nonatomic, strong) HomeNavigationBar *navSearchBar;

@property (nonatomic, strong) DiscoverTabController *dataController;
@end

@implementation QMPDescoverTabController
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (![ToLogin isLogin]) {
        return;
    }
    [self.navSearchBar refreshMsdCount];

}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.dataController.view];
    [self.view addSubview:self.navSearchBar];
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
- (HomeNavigationBar *)navSearchBar{
    
    if (!_navSearchBar) {
        _navSearchBar = [HomeNavigationBar navigationBarWithBarStyle:BarStyle_White];
        _navSearchBar.tabbarIndex = 3;
    }
    
    return _navSearchBar;
}
- (DiscoverTabController *)dataController {
    if (!_dataController) {
        _dataController = [[DiscoverTabController alloc] init];
    }
    return _dataController;
}

@end
