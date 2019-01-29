//
//  QMPTabbarController.m
//  qmp_ios
//
//  Created by QMP on 2018/11/5.
//  Copyright © 2018年 WSS. All rights reserved.
//

#import "QMPTabbarController.h"
#import <CommonLibrary/UITabBar+badge.h>
#import <CommonLibrary/MainNavViewController.h>
#import <CommonLibrary/MyViewController.h>
#import <CommonLibrary/VSTabBarFix.h>
#import <pop/POP.h>
#import <CommonLibrary/QMPDisCoverController.h>
#import "HomeViewController.h"
#import "TabbarActivityViewController.h"
#import <CommonLibrary/QMPCommunityController.h>

@interface QMPTabbarController (){
    NSInteger _oldSelectedIndex;
    NSDate *_lastDate;
    NSInteger *_lastIndex;
    NSArray *_animationArr;
}
@property (nonatomic, weak) TabbarActivityViewController *dataVC;
@end

@implementation QMPTabbarController

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"TabbarController 开始执行");

    VSTabBarFix *tabbar = [[VSTabBarFix alloc]init];
    [self setValue:tabbar forKey:@"tabBar"];
    
    self.tabBar.itemPositioning = UITabBarItemPositioningFill;
    [[UITabBar appearance] setTranslucent:NO];
    
    [self addChildViewControllers];
    
    _oldSelectedIndex = 0;
    NSLog(@"TabbarController 执行完了");

}


- (void)addChildViewControllers{
    
    HomeViewController *homeVC = [[HomeViewController alloc] init];
    MainNavViewController *homeNav = [[MainNavViewController alloc] initWithRootViewController:homeVC];
    homeNav.tabBarItem.tag = 10000;
    [self addChildViewController:homeNav image:@"home_tabbar_nor" selectedImage:@"home_tabbar_sel" title:@"首页"];
    
    
    TabbarActivityViewController *dataVC = [[TabbarActivityViewController alloc] init];
    MainNavViewController *dataNAV = [[MainNavViewController alloc] initWithRootViewController:dataVC];
    [self addChildViewController:dataNAV image:@"manager_tabbar_nor" selectedImage:@"manager_tabbar_sel" title:@"资讯"];
    dataNAV.tabBarItem.tag = 10001;
    self.dataVC = dataVC;
    
    //占位
    //    UIViewController *centerVC = [[UIViewController alloc] init];
    //    MainNavViewController *centerNAV = [[MainNavViewController alloc] initWithRootViewController:centerVC];
    //    [self addChildViewController:centerNAV image:@"" selectedImage:@"" title:@""];
    QMPCommunityController *communityVC = [[QMPCommunityController alloc] init];
    MainNavViewController *communityNAV = [[MainNavViewController alloc] initWithRootViewController:communityVC];
    [self addChildViewController:communityNAV image:@"social_tabbar_nol" selectedImage:@"social_tabbar_sel" title:@"社区"];
    communityNAV.tabBarItem.tag = 10002;
    self.dataVC = dataVC;
    
    QMPDisCoverController *discoverVC = [[QMPDisCoverController alloc]init];
    MainNavViewController *discoverNV = [[MainNavViewController alloc] initWithRootViewController:discoverVC];
    [self addChildViewController:discoverNV image:@"discover_tabbar_nor" selectedImage:@"discover_tabbar_sel" title:@"发现"];
    discoverNV.tabBarItem.tag = 10003;
    
    
    MyViewController *myVC = [[MyViewController alloc]init];
    [self addChildViewController:myVC image:@"my_tabbar_nor" selectedImage:@"my_tabbar_sel" title:@"我的"];
    MainNavViewController *myNav = [[MainNavViewController alloc] initWithRootViewController:myVC];
    myVC.tabBarItem.tag = 10004;
    
    
    self.viewControllers = @[homeNav,dataNAV, communityNAV,discoverNV,myNav];
}

- (void)selectHome{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"goHomeToRefresh" object:nil];
        [self performSelector:@selector(selectToHome) withObject:nil afterDelay:0.1];
    });
}


- (void)receiverQuitLoginNotificationToRefresh{
    [self.tabBar hideBadgeOnItemIndex:3];
    
}

- (void)selectToHome{
    
    self.selectedIndex = 0;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  添加子控制器
 *
 *  @param childViewController 子控制器
 *  @param image               tabBarItem正常状态图片
 *  @param selectedImage       tabBarItem选中状态图片
 *  @param title               标题
 */
- (void)addChildViewController:(UIViewController *)childViewController image:(NSString *)image selectedImage:(NSString *)selectedImage title:(NSString *)title {
    
    //标题
    childViewController.title = title;
    childViewController.view.backgroundColor = [UIColor whiteColor];
    
    //tabBarItem图片
    childViewController.tabBarItem.image =[[UIImage imageNamed:image] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    childViewController.tabBarItem.selectedImage = [[UIImage imageNamed:selectedImage] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [childViewController.tabBarItem setImageInsets:UIEdgeInsetsMake(-1.5, 0, 1.5, 0)];
    [childViewController.tabBarItem setTitlePositionAdjustment:UIOffsetMake(0, -4)];
    
    //tabBarItem字体的设置
    //正常状态
    NSMutableDictionary *normalText = [NSMutableDictionary dictionary];
    normalText[NSForegroundColorAttributeName] = H9COLOR;
    normalText[NSFontAttributeName] = [UIFont systemFontOfSize:10];
    [childViewController.tabBarItem setTitleTextAttributes:normalText forState:UIControlStateNormal];
    
    //    选中状态
    NSMutableDictionary *selectedText = [NSMutableDictionary dictionary];
    selectedText[NSForegroundColorAttributeName] = BLUE_TITLE_COLOR;
    selectedText[NSFontAttributeName] = [UIFont systemFontOfSize:10];
    [childViewController.tabBarItem setTitleTextAttributes:selectedText forState:UIControlStateSelected];
}


- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    
    //    if (![ToLogin canEnterDeep] && [viewController isKindOfClass:<#(__unsafe_unretained Class)#>]) {
    //
    //        return NO;
    //
    //    }else {
    //
    //        return YES;
    //    }
    return YES;
    
}
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    
    NSInteger nowSelect = item.tag - 10000;
    
    if (nowSelect != self.selectedIndex) {
        if (nowSelect == 0) {
            
            [QMPEvent event:@"home_tab_click"];
            
        }else if(nowSelect == 1){
            [QMPEvent event:@"news_tab_click"];
        }else if(nowSelect == 2){
            [QMPEvent event:@"tab_community_enter"];
        }else if(nowSelect == 3){
            [QMPEvent event:@"tab_discover_click"];
        }else if(nowSelect == 4){
            [QMPEvent event:@"me_tab_click"];
        }
    }
    if (_oldSelectedIndex != 3 && nowSelect == 3) {
        [QMPEvent beginEvent:@"tab_discover_timer"];
    }else if(_oldSelectedIndex == 3 && nowSelect != 3){
        [QMPEvent endEvent:@"tab_discover_timer"];
    }
    
    
    _oldSelectedIndex = nowSelect;
    [self animationWithIndex:nowSelect];
    if (nowSelect == self.selectedIndex && self.selectedIndex == 1) {
        [self.dataVC scrollTop];
    }
    if (nowSelect == self.selectedIndex && self.selectedIndex == 2) {
        QMPCommunityController *communityVC = [self.childViewControllers[2] childViewControllers].firstObject;
        [communityVC scrollTop];
    }
}

// 动画
- (void)animationWithIndex:(NSInteger) index {

    NSMutableArray * tabbarbuttonArray = [NSMutableArray array];
    for (UIView *tabBarButton in self.tabBar.subviews) {
        if ([tabBarButton isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
            for (UIView *btnSubV in tabBarButton.subviews) {
                if ([btnSubV isKindOfClass:NSClassFromString(@"UITabBarSwappableImageView")]) {
                    [tabbarbuttonArray addObject:btnSubV];
                }
            }
        }
    }
    if (index >= tabbarbuttonArray.count) {
        return;
    }
    UIView *view = tabbarbuttonArray[index];
    
    POPSpringAnimation* springAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    //它会先缩小到(0.5,0.5),然后再去放大到(1.0,1.0)
    springAnimation.fromValue = [NSValue valueWithCGPoint:CGPointMake(0.94, 0.94)];
    springAnimation.toValue =[NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)];
    springAnimation.springBounciness = 15;
    [view.layer pop_addAnimation:springAnimation forKey:@"SpringAnimation"];
    
}

-(BOOL)shouldAutorotate{
    return YES;
}
@end
