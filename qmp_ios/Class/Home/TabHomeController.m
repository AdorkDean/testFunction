//
//  TabHomeController.m
//  qmp_ios
//
//  Created by QMP on 2019/1/28.
//  Copyright © 2019 WSS. All rights reserved.
//

#import "TabHomeController.h"
#import <CommonLibrary/QMPActivityCategoryListViewController.h>
#import <CommonLibrary/WMPanGestureRecognizer.h>
#import <CommonLibrary/QMPSetupCategoryViewController.h>
#import <CommonLibrary/SPPageMenu.h>
#import "HomeHeaderView.h"
#import <CommonLibrary/MainSearchController.h>
#import <CommonLibrary/HomeNavigationBar.h>
#import "HomeHeaderView.h"
#import "Home3ViewController.h"
#import "Home5ViewController.h"
#import "Home6ViewController.h"
#import "HomeIPOViewController.h"
#import  <CommonLibrary/HomeAllViewController.h>
#import <CommonLibrary/ReportController.h>
#import  <CommonLibrary/InvestOpportunityViewController.h>

#import  <CommonLibrary/QMPOrganizationLibraryViewController.h>
#import  <CommonLibrary/QMPSecondaryMarketViewController.h>
#import  <CommonLibrary/QMPDataGraphViewController.h>
#import  <CommonLibrary/FinanceReportController.h>
#import  <CommonLibrary/InvestorsListController.h>
#import  <CommonLibrary/ProspectusListController.h>
#import  <CommonLibrary/ProductAlbumController.h>
#import  <CommonLibrary/FinanceReportController.h>
#import  <CommonLibrary/LoadingAnimator.h>
#import "QMPPhoneBindController.h"
#import <CommonLibrary/AppDelegateTool.h>

static CGFloat const kWMMenuViewHeight = 44.0;
@interface TabHomeController () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *setupView;
@property (nonatomic, strong) UIView *line;
@property (nonatomic, strong) NSMutableArray *showThemes;
@property (nonatomic, strong) NSMutableArray *allThemes;
@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, strong) NSMutableArray *refreshVCS;
@property (nonatomic, assign) BOOL needGo;
@property (nonatomic, assign) NSString *toGotagName;
@property (nonatomic, assign) NSString *toGoactivtyID;
@property (nonatomic, copy)   NSString *lastTitle;


@property (nonatomic, strong) NSArray *musicCategories;
@property (nonatomic, strong) WMPanGestureRecognizer *panGesture;
@property (nonatomic, assign) CGPoint lastPoint;
@property (nonatomic, strong) UIView *redView;
@end

@implementation TabHomeController

- (NSArray *)musicCategories {
    if (!_musicCategories) {
        _musicCategories = @[@"单曲", @"详情", @"歌词"];
    }
    return _musicCategories;
}

- (instancetype)init {
    if (self = [super init]) {
        self.titleSizeNormal = 15;
        self.titleSizeSelected = 15;
        self.menuViewStyle = WMMenuViewStyleLine;
        self.menuItemWidth = [UIScreen mainScreen].bounds.size.width / self.musicCategories.count;
        self.viewTop = kScreenTopHeight + kWMHeaderViewHeight;
        self.titleColorSelected = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
        self.titleColorNormal = [UIColor colorWithRed:0.4 green:0.8 blue:0.1 alpha:1.0];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"专辑";
    UIView *redView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenTopHeight, [UIScreen mainScreen].bounds.size.width, kWMHeaderViewHeight)];
    redView.backgroundColor = [UIColor redColor];
    self.redView = redView;
    [self.view addSubview:self.redView];
    self.panGesture = [[WMPanGestureRecognizer alloc] initWithTarget:self action:@selector(panOnView:)];
    [self.view addGestureRecognizer:self.panGesture];
}

- (void)panOnView:(WMPanGestureRecognizer *)recognizer {
    
    CGPoint currentPoint = [recognizer locationInView:self.view];
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.lastPoint = currentPoint;
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        CGPoint velocity = [recognizer velocityInView:self.view];
        CGFloat targetPoint = velocity.y < 0 ? kScreenTopHeight : kScreenTopHeight + kWMHeaderViewHeight;
        NSTimeInterval duration = fabs((targetPoint - self.viewTop) / velocity.y);
        
        if (fabs(velocity.y) * 1.0 > fabs(targetPoint - self.viewTop)) {
            NSLog(@"velocity: %lf", velocity.y);
            [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.viewTop = targetPoint;
            } completion:nil];
            
            return;
        }
        
    }
    CGFloat yChange = currentPoint.y - self.lastPoint.y;
    
    self.viewTop += yChange;
    self.lastPoint = currentPoint;
}

// MARK: ChangeViewFrame (Animatable)
- (void)setViewTop:(CGFloat)viewTop {
    _viewTop = viewTop;
    
    if (_viewTop <= kScreenTopHeight) {
        _viewTop = kScreenTopHeight;
    }
    
    if (_viewTop > kWMHeaderViewHeight + kScreenTopHeight) {
        _viewTop = kWMHeaderViewHeight + kScreenTopHeight;
    }
    
    self.redView.frame = ({
        CGRect oriFrame = self.redView.frame;
        oriFrame.origin.y = _viewTop - kWMHeaderViewHeight;
        oriFrame;
    });
    
    [self forceLayoutSubviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Datasource & Delegate

- (NSInteger)numbersOfChildControllersInPageController:(WMPageController *)pageController {
    return self.showThemes.count;
}

- (__kindof UIViewController *)pageController:(WMPageController *)pageController viewControllerAtIndex:(NSInteger)index {
    
    NSDictionary *dict = self.showThemes[index];
    QMPActivityCategoryListViewController *vc = [[QMPActivityCategoryListViewController alloc] initWithTicket:dict[@"ticket"]];
    return vc;
}

- (NSString *)pageController:(WMPageController *)pageController titleAtIndex:(NSInteger)index {
    //    if (index == 0) {
    //        return @"关注";
    //    }
    NSDictionary *dict = self.showThemes[index];
    return dict[@"name"];
}

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForMenuView:(WMMenuView *)menuView {
    return CGRectMake(0, _viewTop, self.view.frame.size.width, kWMMenuViewHeight);
}

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForContentView:(WMScrollView *)contentView {
    CGFloat originY = _viewTop + kWMMenuViewHeight;
    return CGRectMake(0, originY, self.view.frame.size.width, self.view.frame.size.height - originY);
}

- (void)pageController:(WMPageController *)pageController willEnterViewController:(__kindof UIViewController *)viewController withInfo:(NSDictionary *)info {
    
}
- (void)pageController:(WMPageController *)pageController didEnterViewController:(__kindof UIViewController *)viewController withInfo:(NSDictionary *)info {
    [QMPEvent event:@"acvitity_headermenu_click" attributes:@{@"name":info[@"title"]}];
    
    if (_lastTitle) {
        [QMPEvent endEvent:@"acvitity_headermenu_timer" attributes:@{@"name":_lastTitle}];
    }
    
    [QMPEvent beginEvent:@"acvitity_headermenu_timer" attributes:@{@"name":info[@"title"]}];
    _lastTitle = info[@"title"];
}

- (CGFloat)menuView:(WMMenuView *)menu widthForItemAtIndex:(NSInteger)index {
    return [super menuView:menu widthForItemAtIndex:index]+2;
}
- (CGFloat)menuView:(WMMenuView *)menu itemMarginAtIndex:(NSInteger)index {
    if (index == self.showThemes.count) {
        return 52;
    }
    return 20;
}
- (UIView *)setupView {
    if (!_setupView) {
        _setupView = [[UIView alloc] init];
        _setupView.frame = CGRectMake(SCREENW-42, 4, 42, 40);
        _setupView.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.95];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, 42, 40);
        [button setImage:[BundleTool imageNamed:@"category_setup"] forState:UIControlStateNormal];
        [button setImage:[BundleTool imageNamed:@"category_setup"] forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(setupButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [_setupView addSubview:button];
    }
    return _setupView;
}
- (UIView *)line {
    if (!_line) {
        UIView *line = [[UIView alloc] init];
        line.frame = CGRectMake(0, 43, SCREENW, 1);
        //        line.backgroundColor = [UIColor whiteColor];
        line.backgroundColor = HTColorFromRGB(0xEEEEEE);
        _line = line;
    }
    return _line;
}
- (void)setupButtonClick {
    if (![ToLogin canEnterDeep]) {
        [ToLogin accessEnterDeep];
        return;
    }
    QMPSetupCategoryViewController *vc = [[QMPSetupCategoryViewController alloc] init];
    vc.showCategorys = self.showThemes;
    vc.allCategorys = self.allThemes;
    
    __weak typeof(self) weakSelf = self;
    vc.cateGrayDidSetup = ^(NSArray * _Nonnull items) {
        weakSelf.showThemes = [NSMutableArray arrayWithArray:items];
        [weakSelf reloadData];
        [NSKeyedArchiver archiveRootObject:weakSelf.showThemes toFile:weakSelf.filePath];
    };
    [self presentViewController:vc animated:YES completion:nil];
}
- (NSMutableArray *)showThemes {
    if (!_showThemes) {
        _showThemes = [NSMutableArray array];
    }
    return _showThemes;
}
- (NSString *)filePath {
    if (!_filePath) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        NSString *file = [[paths firstObject] stringByAppendingString:@"/Preferences/LocalCateGray.plist"];
        _filePath = file;
    }
    return _filePath;
}

@end
