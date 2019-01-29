//
//  QMPActivityCategoryViewController.m
//  CommonLibrary
//
//  Created by QMP on 2018/12/4.
//  Copyright © 2018 WSS. All rights reserved.
//

#import "QMPActivityCategoryViewController.h"
#import "QMPActivityCategoryListViewController.h"
#import "WMMenuItem+Font.h"
#import "QMPSetupCategoryViewController.h"
#import "QMPHomeFollowViewController.h"
#import "LoadingAnimator.h"
#import "PostActivityViewController.h"

@interface QMPActivityCategoryViewController ()
@property (nonatomic, strong) UIView *setupView;
@property (nonatomic, strong) UIView *line;
@property (nonatomic, strong) NSMutableArray *showThemes;
@property (nonatomic, strong) NSMutableArray *allThemes;
@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, strong) NSMutableArray *refreshVCS;
@property (nonatomic, strong) LoadingAnimator *loadAnimator;
@property (nonatomic, assign) BOOL needGo;
@property (nonatomic, assign) NSString *toGotagName;
@property (nonatomic, assign) NSString *toGoactivtyID;
@property (nonatomic, copy)   NSString *lastTitle;

@end

@implementation QMPActivityCategoryViewController
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [IQKeyboardManager sharedManager].enable = NO;
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [IQKeyboardManager sharedManager].enable = YES;
}

- (void)showToTag:(NSString*)tagName activityID:(NSString*)activityID{
    self.toGotagName = tagName;
    self.toGoactivtyID = activityID;
    
    NSInteger index = 0;
    if (self.showThemes.count <= 0) {
        self.needGo = YES;
        return;
    }
    for (NSDictionary *dict in self.showThemes) {
        NSString *name = dict[@"name"];
        if ([tagName isEqualToString:name]) {
            [self setSelectIndex:(int)index];
            break;
        }
        index++;
    }
}


- (void)scrollTop {
    QMPActivityCategoryListViewController *vc = (QMPActivityCategoryListViewController *)self.currentViewController;
    [vc.tableView.mj_header beginRefreshing];
}

- (instancetype)init {
    self = [super init];
    if(self) {
        self.automaticallyCalculatesItemWidths = YES;
        self.menuViewStyle = WMMenuViewStyleLine;
        self.menuViewLayoutMode = WMMenuViewLayoutModeLeft;
        self.titleSizeNormal = 15;
        self.titleSizeSelected = 15;
        self.titleColorSelected = HTColorFromRGB(0x006EDA);
        self.titleColorNormal = HTColorFromRGB(0x444444);
        self.itemMargin = 18;
        
        self.progressWidth = 20;
        self.progressColor = HTColorFromRGB(0x006EDA);
        self.progressHeight = 2;
        self.progressViewCornerRadius = 1;
        self.progressViewBottomSpace = 1;
        
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.menuView addSubview:self.setupView];
    [self.menuView addSubview:self.line];

    [self.loadAnimator showAnimatorInView:self.view];
    [self loadCategory];
}

-(LoadingAnimator *)loadAnimator{
    if (!_loadAnimator) {
        _loadAnimator = [[LoadingAnimator alloc]init];
    }
    return _loadAnimator;
}

- (void)menuView:(WMMenuView *)menu didSelesctedIndex:(NSInteger)index currentIndex:(NSInteger)currentIndex {
    [super menuView:menu didSelesctedIndex:index currentIndex:currentIndex];
    if (index == currentIndex) {
        QMPActivityCategoryListViewController *vc = (QMPActivityCategoryListViewController *)self.currentViewController;
        [vc.tableView.mj_header beginRefreshing];
    }
    [QMPEvent event:@"tab_activity_square_menuclick"];
}

- (BOOL)needInsertNew:(NSArray *)arr {
    NSInteger i = 0;
    for (NSDictionary *dict in self.showThemes) {
        NSString *ticket = dict[@"ticket"];
        if ([ticket isEqualToString:@"1"] || [ticket isEqualToString:@"2"] || [ticket isEqualToString:@"0"]) {
            i++;
        }
        
    }
    return i < 3;
}
- (BOOL)needInsertNew:(NSArray *)arr i:(NSString *)i {
    for (NSDictionary *dict in self.showThemes) {
        NSString *ticket = dict[@"name"];
        if ([ticket isEqualToString:i]) {
            return NO;
        }
    }
    return YES;
}
- (void)deleteAnonymous { //删除匿名和好看
    [self.showThemes enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSDictionary *  _Nonnull dict, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([dict[@"name"] isEqualToString:@"关注"]) {
            [self.showThemes removeObject:dict];
        }
        if ([dict[@"name"] isEqualToString:@"匿名"]) {
            [self.showThemes removeObject:dict];
        }
        if ([dict[@"name"] isEqualToString:@"好看"]){
            [self.showThemes removeObject:dict];
        }
    }];
}
- (void)loadCategory {
    
    NSDictionary *dic = @{};
    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"theme/showThemeList" HTTPBody:dic completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
        
        NSMutableArray *allThemes = [NSMutableArray array];
        NSMutableArray *themes = [NSMutableArray array];
        
        if (resultData && [resultData isKindOfClass:[NSArray class]]) {
            int i = 0;
            for (NSDictionary *dict in resultData) {
                [allThemes addObject:[NSMutableDictionary dictionaryWithDictionary:dict]];
                if (i < 8) {
                    [themes addObject:dict];
                }
                i++;
            }
        }
        
        self.allThemes = allThemes;
        NSArray *data = [NSKeyedUnarchiver unarchiveObjectWithFile:self.filePath];
        if (data && data.count > 0) {
            self.showThemes = [NSMutableArray arrayWithArray:[self fixNameOfTheme:data]];
            [self deleteAnonymous]; //删除4.8版本的匿名 好看
            [NSKeyedArchiver archiveRootObject:self.showThemes toFile:self.filePath];
        } else {
            self.showThemes = [NSMutableArray arrayWithArray:themes];
            [NSKeyedArchiver archiveRootObject:self.showThemes toFile:self.filePath];
        }
        
        [self reloadData];
        [self.loadAnimator dismissAnimatorInView:self.view];
        self.loadAnimator = nil;
        
        if (!self.setupView.superview) {
            [self.menuView addSubview:self.setupView];
            self.menuView.scrollView.contentInset = UIEdgeInsetsMake(3,-7, 0, 0);

        }
        if (!self.line.superview) {
            [self.menuView addSubview:self.line];
        }
        
        [self.menuView bringSubviewToFront:self.line];
        
        if (self.needGo) {
            self.needGo = NO;
            [self showToTag:self.toGotagName activityID:self.toGoactivtyID];
        }
    }];
    

}
- (NSArray *)fixNameOfTheme:(NSArray *)old {
    NSMutableArray *arr = [NSMutableArray array];
    for (NSDictionary *dict in old) {
        NSString *ticket = dict[@"ticket"];
        if (ticket.length == 1) {
            [arr addObject:dict];
            continue;
        }
        NSDictionary *dd = [self themeWtihTicket:ticket];
        if (dd) {
            [arr addObject:dd];
        }
    }
    return arr;
}
- (NSDictionary *)themeWtihTicket:(NSString *)ticket {
    for (NSDictionary *dict in self.allThemes) {
        NSString *newTicket = dict[@"ticket"];
        if ([newTicket isEqualToString:ticket]) {
            return dict;
        }
    }
    return nil;
}
- (NSInteger)numbersOfChildControllersInPageController:(WMPageController *)pageController {
    return self.showThemes.count;
}

- (__kindof UIViewController *)pageController:(WMPageController *)pageController viewControllerAtIndex:(NSInteger)index {

    NSDictionary *dict = self.showThemes[index];

    if ([dict[@"name"] isEqualToString:@"关注"]) {  //关注
        QMPHomeFollowViewController *vc = [[QMPHomeFollowViewController alloc] init];
        return vc;
    }

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
    return CGRectMake(0, 0, self.view.frame.size.width, 44);
}

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForContentView:(WMScrollView *)contentView {
    CGFloat originY = CGRectGetMaxY([self pageController:pageController preferredFrameForMenuView:self.menuView]);
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
