//
//  PersonAllBusinessRoleController.m
//  qmp_ios
//
//  Created by QMP on 2018/4/16.
//  Copyright © 2018年 Molly. All rights reserved.
//

#import "PersonAllBusinessRoleController.h"
#import "SPPageMenu.h"
#import "PersonModel.h"
#import "PersonRoleModel.h"
#import "PersonBusinessRoleController.h"
#import "GestureScrollView.h"

#define kPageMenuH 44.0
@interface PersonAllBusinessRoleController () <SPPageMenuDelegate, UIScrollViewDelegate> {
    CGFloat _top;
}
@property (nonatomic, strong) UIView *menuView;
@property (nonatomic, strong) SPPageMenu *pageMenu;
@property (nonatomic, strong) GestureScrollView *scrollView;

@property (nonatomic, strong) PersonBusinessRoleController *legalVC;        ///< 法人
@property (nonatomic, strong) PersonBusinessRoleController *shareholderVC;  ///< 股东
@property (nonatomic, strong) PersonBusinessRoleController *executivesVC;   ///< 高管

@property (nonatomic, strong) NSMutableArray *legalData;
@property (nonatomic, strong) NSMutableArray *shareholderData;
@property (nonatomic, strong) NSMutableArray *executivesVCData;

@property (nonatomic, strong) UIView *userHeaderView;
@property (nonatomic, weak) UIImageView *avatarView;
@property (nonatomic, weak) UILabel *placeLabel;
@property (nonatomic, weak) UILabel *nameLabel;
@end

@implementation PersonAllBusinessRoleController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (self.personModel) {
        self.title = [NSString stringWithFormat:@"%@的工商信息",self.personModel.name];
    }else{
        self.title = @"商业角色";
    }
    
    if (self.isNeedUserHeader) {
        _top = 80;
        [self.view addSubview:self.userHeaderView];
        
    }
    [self.view addSubview:self.scrollView];
    
    [self.view addSubview:self.menuView];
    [self.menuView addSubview:self.pageMenu];
    
    
    [self.scrollView addSubview:self.legalVC.view];
    [self.scrollView addSubview:self.shareholderVC.view];
    [self.scrollView addSubview:self.executivesVC.view];
    
    [self addChildViewController:self.legalVC];
    [self addChildViewController:self.shareholderVC];
    [self addChildViewController:self.executivesVC];
    
    [self loadData];
    
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadData {
    
    [self showHUD];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:self.personModel.uniq_hid?:@"" forKey:@"uniq_hid"];
    [dict setValue:@"1" forKey:@"debug"];

    [[NetworkManager sharedMgr] requestNewWithMethod:kHTTPPost URLString:@"person/personRole" HTTPBody:dict completeHandler:^(NSURLSessionDataTask *dataTask, id resultData, NSError *error) {
       
        [self hideHUD];
        NSDictionary *dataDic = resultData[@"list"];
        if (dataDic && [dataDic isKindOfClass:[NSDictionary class]] && dataDic[@"holderList"]) {
            NSMutableArray *arr1 = [NSMutableArray array];
            for (NSDictionary *dic in dataDic[@"holderList"]) {
                PersonRoleModel *person = [[PersonRoleModel alloc] initWithDictionary:dic error:nil];
                [arr1 addObject:person];
            }
            self.shareholderData = arr1;
            self.shareholderVC.datas = [NSMutableArray arrayWithArray:arr1];
            [self.shareholderVC.tableView reloadData];
            
            NSMutableArray *arr2 = [NSMutableArray array];
            for (NSDictionary *dic in dataDic[@"legalList"]) {
                PersonRoleModel *person = [[PersonRoleModel alloc] initWithDictionary:dic error:nil];
                [arr2 addObject:person];
            }
            self.legalData = arr2;
            self.legalVC.datas = [NSMutableArray arrayWithArray:arr2];
            [self.legalVC.tableView reloadData];
            
            NSMutableArray *arr3 = [NSMutableArray array];
            for (NSDictionary *dic in dataDic[@"officeList"]) {
                PersonRoleModel *person = [[PersonRoleModel alloc] initWithDictionary:dic error:nil];
                [arr3 addObject:person];
            }
            self.executivesVCData = arr3;
            self.executivesVC.datas = [NSMutableArray arrayWithArray:arr3];;
            [self.executivesVC.tableView reloadData];
            
            NSString *str1 = [NSString stringWithFormat:@"法人(%zd)", arr2.count];
            NSString *str2 = [NSString stringWithFormat:@"股东(%zd)", arr1.count];
            NSString *str3 = [NSString stringWithFormat:@"高管(%zd)", arr3.count];
            [self.pageMenu setTitle:str1 forItemAtIndex:0];
            [self.pageMenu setTitle:str2 forItemAtIndex:1];
            [self.pageMenu setTitle:str3 forItemAtIndex:2];
        } else {
            
        }
    }];
}
#pragma mark  mark - SPPageMenuDelegate
- (void)pageMenu:(SPPageMenu *)pageMenu itemSelectedFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    [self.scrollView setContentOffset:CGPointMake(SCREENW*toIndex, 0) animated:YES];
}
#pragma mark - Getter
- (UIView *)menuView {
    if (!_menuView) {
        _menuView = [[UIView alloc]initWithFrame:CGRectMake(0, _top, SCREENW, kPageMenuH)];
        _menuView.backgroundColor = [UIColor whiteColor];
        _menuView.layer.shadowColor = H9COLOR.CGColor;
        _menuView.layer.shadowOffset = CGSizeMake(0,3);
        _menuView.layer.shadowRadius = 3;
    }
    return _menuView;
}

- (SPPageMenu *)pageMenu {
    if (!_pageMenu) {
        _pageMenu = [SPPageMenu pageMenuWithFrame:CGRectMake(0, 0, SCREENW, kPageMenuH) trackerStyle:SPPageMenuTrackerStyleLineAttachment];
        _pageMenu.itemTitleFont = PageMenuTitleFont;
        _pageMenu.selectedItemTitleColor = PageMenuTitleSelectColor;
        _pageMenu.unSelectedItemTitleColor = PageMenuTitleUnSelectColor;
        _pageMenu.tracker.backgroundColor = PageMenuTrackerColor;
        _pageMenu.bridgeScrollView = self.scrollView;
        [_pageMenu setItems:@[@"法人",@"股东",@"高管"] selectedItemIndex:0];
        _pageMenu.delegate = self;
        _pageMenu.dividingLine.image = [UIImage imageFromColor:LIST_LINE_COLOR andSize:CGSizeMake(SCREENW, 1)];
//        _pageMenu.itemPadding = 32*ratioWidth;
//        _pageMenu.contentInset = UIEdgeInsetsMake(0, 10, 0, -10);
        _pageMenu.permutationWay = SPPageMenuPermutationWayNotScrollEqualWidths;
//        
//        for (UIView *subV in _pageMenu.subviews) {
//            if ([subV isKindOfClass:NSClassFromString(@"SPPageMenuLine")]) {
//                subV.hidden = YES;
//            }
//        }
    }
    return _pageMenu;
}

- (GestureScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[GestureScrollView alloc] init];
        _scrollView.frame = CGRectMake(0, kPageMenuH+_top, SCREENW, SCREENH-kPageMenuH-_top);
        _scrollView.delegate = self;
        _scrollView.pagingEnabled = YES;
        _scrollView.bounces = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.contentSize = CGSizeMake(SCREENW * 3, 0);

    }
    return _scrollView;
}
- (PersonBusinessRoleController *)legalVC {
    if (!_legalVC) {
        _legalVC = [[PersonBusinessRoleController alloc] init];
        _legalVC.view.frame = CGRectMake(0, 0, SCREENW, SCREENH-kPageMenuH-_top-kScreenTopHeight);
        _legalVC.type = PersonBusinessRoleControllerTypeLegal;
    }
    return _legalVC;
}
- (PersonBusinessRoleController *)shareholderVC {
    if (!_shareholderVC) {
        _shareholderVC = [[PersonBusinessRoleController alloc] init];
        _shareholderVC.view.frame = CGRectMake(SCREENW, 0, SCREENW, SCREENH-kPageMenuH-_top-kScreenTopHeight);
        _shareholderVC.type = PersonBusinessRoleControllerTypeShareholder;
    }
    return _shareholderVC;
}
- (PersonBusinessRoleController *)executivesVC {
    if (!_executivesVC) {
        _executivesVC = [[PersonBusinessRoleController alloc] init];
        _executivesVC.view.frame = CGRectMake(SCREENW*2, 0, SCREENW, SCREENH-kPageMenuH-_top-kScreenTopHeight);
        _executivesVC.type = PersonBusinessRoleControllerTypeExecutives;
    }
    return _executivesVC;
}
- (NSMutableArray *)legalData {
    if (!_legalData) {
        _legalData = [NSMutableArray array];
    }
    return _legalData;
}
- (NSMutableArray *)shareholderData {
    if (!_shareholderData) {
        _shareholderData = [NSMutableArray array];
    }
    return _shareholderData;
}
- (NSMutableArray *)executivesVCData {
    if (!_executivesVCData) {
        _executivesVCData = [NSMutableArray array];
    }
    return _executivesVCData;
}
- (UIView *)userHeaderView {
    if (!_userHeaderView) {
        _userHeaderView = [[UIView alloc] init];
        _userHeaderView.frame = CGRectMake(0, 0, SCREENW, _top);
        _userHeaderView.backgroundColor = [UIColor whiteColor];
        
        UIImageView *avatarView = [[UIImageView alloc] init];
        avatarView.frame = CGRectMake(20, 15, 45, 45);
        avatarView.layer.cornerRadius = 4;
        avatarView.clipsToBounds = YES;
        [_userHeaderView addSubview:avatarView];
        self.avatarView = avatarView;
        
        UILabel *placeLabel = [[UILabel alloc] init];
        placeLabel.frame = CGRectMake(0, 0, 45, 45);
        placeLabel.textColor = [UIColor whiteColor];
        placeLabel.layer.cornerRadius = 4;
        placeLabel.clipsToBounds = YES;
        placeLabel.textAlignment =NSTextAlignmentCenter;
        placeLabel.font = [UIFont boldSystemFontOfSize:20];
        [avatarView addSubview:placeLabel];
        self.placeLabel = placeLabel;
        
        UILabel *nameLabel = [[UILabel alloc] init];
        nameLabel.frame = CGRectMake(20+44+15, (_top-20)/2.0, 300, 20);
        nameLabel.font = [UIFont systemFontOfSize:16];
        nameLabel.textColor = NV_TITLE_COLOR;
        [_userHeaderView addSubview:nameLabel];
        nameLabel.centerY = avatarView.centerY;
        self.nameLabel = nameLabel;
        
        if ([PublicTool isNull:self.personModel.icon] && ![PublicTool isNull:self.personModel.name]) {
            placeLabel.backgroundColor =  RANDOM_COLORARR[0];
            placeLabel.text = [self.personModel.name substringWithRange:NSMakeRange(0, 1)];
        }else if(![PublicTool isNull:self.personModel.icon]){
            [avatarView sd_setImageWithURL:[NSURL URLWithString:self.personModel.icon] placeholderImage:[BundleTool imageNamed:@"heading"]];
        }
        nameLabel.text = self.personModel.name;
        
        //线
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, _top-5, SCREENW, 5)];
        line.backgroundColor = TABLEVIEW_COLOR;
        [_userHeaderView addSubview:line];
    }
    return _userHeaderView;
}
@end
